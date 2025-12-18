import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';
import '../providers/account_provider.dart';

class DataService {
  final TransactionProvider _txProvider = TransactionProvider();
  final AccountProvider _accProvider = AccountProvider();

  Future<void> exportToExcel() async {
    // Request permission (mostly for Android < 11 or generic storage access)
    // For modern Android, scoped storage or Documents/Downloads is better.
    // We'll try to write to ExternalStorageDirectory or ApplicationDocumentsDirectory.

    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar(
          "Permission Denied",
          "Storage permission is required to export.",
        );
        return;
      }
    }

    var excel = Excel.createExcel();
    Sheet sheet = excel['Transactions'];

    // Headers
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Amount'),
      TextCellValue('Note'),
    ]);

    var transactions = await _txProvider.getAllTransactions();
    for (var tx in transactions) {
      sheet.appendRow([
        IntCellValue(tx.id!),
        TextCellValue(tx.date),
        TextCellValue(tx.type),
        DoubleCellValue(tx.amount),
        TextCellValue(tx.note),
      ]);
    }

    // Save
    var fileBytes = excel.save();
    if (fileBytes != null) {
      String? directory;
      if (Platform.isAndroid) {
        directory = "/storage/emulated/0/Download"; // Direct to Downloads
      } else {
        directory = (await getApplicationDocumentsDirectory()).path;
      }

      final String path =
          "$directory/EzMoney_Export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx";
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      Get.snackbar("Export Success", "File saved to $path");
    }
  }

  Future<void> importFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      int count = 0;

      // Pre-fetch for mapping
      var accounts = await _accProvider.getAllAccounts();
      if (accounts.isEmpty) return; // Cannot import without accounts
      int defaultAccountId = accounts.first.id!;

      for (var table in excel.tables.keys) {
        if (table == 'Transactions') {
          var rows = excel.tables[table]!.rows;
          if (rows.isEmpty) continue;

          for (int i = 1; i < rows.length; i++) {
            var row = rows[i];
            try {
              String date =
                  row[1]?.value?.toString() ?? DateTime.now().toIso8601String();
              String type = row[2]?.value?.toString() ?? 'expense';
              double amount =
                  double.tryParse(row[3]?.value?.toString() ?? '0') ?? 0.0;
              String note = row[4]?.value?.toString() ?? '';

              final tx = TransactionModel(
                accountId: defaultAccountId, // Default to first account
                amount: amount,
                date: date,
                note: note,
                type: type,
                createdAt: DateTime.now().toIso8601String(),
              );

              await _txProvider.addTransaction(tx);
              count++;
            } catch (e) {
              print("Error parsing row: $e");
            }
          }
        }
      }
      Get.snackbar("Import Completed", "Imported $count transactions");
    }
  }
}
