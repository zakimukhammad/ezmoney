import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/transaction_provider.dart';

import '../providers/account_provider.dart';
import '../providers/db_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataService {
  final TransactionProvider _txProvider = TransactionProvider();
  final AccountProvider _accProvider = AccountProvider();

  Future<void> exportToExcel() async {
    // Request permission
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }

      if (!status.isGranted) {
        var storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
        }

        if (!storageStatus.isGranted) {
          Get.snackbar(
            "Permission Denied",
            "Storage permission is required to export to Downloads/Documents.",
          );
          return;
        }
      }
    }

    var excel = Excel.createExcel();
    // We will rename/delete default sheet later or just let it be if we use it.
    // Excel pkg usually starts with 'Sheet1'.

    final db = await DatabaseProvider.db.database;
    final tables = ['Transaction', 'Account', 'Category', 'AccountType'];

    // Track if we wrote any data to avoid saving empty file if something goes wrong
    bool hasData = false;

    for (var tableName in tables) {
      var data = await db.query(tableName);
      if (data.isNotEmpty) {
        hasData = true;
        // Create/Get sheet
        // excel[tableName] creates it if it doesn't exist
        Sheet sheet = excel[tableName];

        // Headers (keys from first row)
        List<String> headers = data.first.keys.toList();

        // Convert headers to TextCellValue
        List<CellValue> headerCells = headers
            .map((h) => TextCellValue(h))
            .toList();
        sheet.appendRow(headerCells);

        // Data
        for (var row in data) {
          List<CellValue> rowCells = headers.map((h) {
            var value = row[h];
            if (value == null) return TextCellValue('');
            if (value is int) return IntCellValue(value);
            if (value is double) return DoubleCellValue(value);
            return TextCellValue(value.toString());
          }).toList();
          sheet.appendRow(rowCells);
        }
      }
    }

    // Remove the default 'Sheet1' if it's empty and we created others,
    // but the library behavior on deleting the only sheet might be tricky.
    // For safety, if we have our own sheets, we can try to delete 'Sheet1' if it exists and is empty.
    // However, simplicity first: just leave it or rename it if used.
    // If 'Transaction' was valid, it created 'Transaction' sheet. 'Sheet1' remains.
    // Let's remove 'Sheet1' if it exists and is not in our tables list.
    if (excel.sheets.containsKey('Sheet1') && !tables.contains('Sheet1')) {
      excel.delete('Sheet1');
    }

    if (!hasData) {
      Get.snackbar("Export Empty", "No data found to export in any table.");
      return;
    }

    // Save
    var fileBytes = excel.save();
    if (fileBytes != null) {
      String? directory;
      if (Platform.isAndroid) {
        directory = "/storage/emulated/0/Download";
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

      final db = await DatabaseProvider.db.database;

      // Order matters for Foreign Keys: AccountType -> Category -> Account -> Transaction
      // Although SQLite fk constraints might not be strictly enforced unless enabled, logic dictates this order.
      final tables = ['AccountType', 'Category', 'Account', 'Transaction'];

      int totalInserted = 0;

      for (var tableName in tables) {
        if (excel.tables.keys.contains(tableName)) {
          var tableSheet = excel.tables[tableName];
          if (tableSheet == null || tableSheet.rows.isEmpty) continue;

          var rows = tableSheet.rows;
          // First row is headers
          var headers = rows.first
              .map((e) => e?.value?.toString() ?? '')
              .toList();

          if (headers.isEmpty) continue;

          for (int i = 1; i < rows.length; i++) {
            var row = rows[i];
            Map<String, dynamic> rowData = {};

            for (int k = 0; k < headers.length; k++) {
              if (k < row.length) {
                var cellValue = row[k]?.value;
                // Handle basic types if needed, though sqflite handles dynamic well usually.
                // We might need to ensure 'id' is treated as such if we want to keep it,
                // but usually auto-increment will override if we don't force it.
                // If we want to RESTORE exactly, we should insert the ID too.
                rowData[headers[k]] = cellValue;
              }
            }

            if (rowData.isNotEmpty) {
              try {
                // specific conflict handling could be added here
                await db.insert(
                  tableName,
                  rowData,
                  conflictAlgorithm: ConflictAlgorithm.replace,
                );
                totalInserted++;
              } catch (e) {
                print("Error inserting into $tableName: $e");
              }
            }
          }
        }
      }
      Get.snackbar(
        "Import Completed",
        "Processed $totalInserted records across all tables.",
      );
      // Refresh providers to show new data
      _txProvider.getAllTransactions();
      _accProvider.getAllAccounts();
    }
  }
}
