import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'transaction_controller.dart';
import 'add_edit_transaction_view.dart'; // We will create this next
import '../../utils/formatters.dart';

class TransactionView extends GetView<TransactionController> {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Obx(
        () => controller.transactions.isEmpty
            ? Center(child: Text("No transactions found"))
            : ListView.builder(
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final tx = controller.transactions[index];
                  // Simple list item for now
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tx.type == 'income'
                            ? Colors.green
                            : (tx.type == 'expense' ? Colors.red : Colors.blue),
                        child: Icon(
                          tx.type == 'income'
                              ? Icons.arrow_downward
                              : (tx.type == 'expense'
                                    ? Icons.arrow_upward
                                    : Icons.swap_horiz),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(tx.note.isEmpty ? (tx.type) : tx.note),
                      subtitle: Text(
                        DateFormat(
                          'MMM dd, yyyy',
                        ).format(DateTime.parse(tx.date)),
                      ),
                      trailing: Text(
                        '${tx.type == 'expense' ? '-' : (tx.type == 'income' ? '+' : '')}${CurrencyFormatter.format(tx.amount)}',
                        style: TextStyle(
                          color: tx.type == 'income'
                              ? Colors.green
                              : (tx.type == 'expense'
                                    ? Colors.red
                                    : Colors.blue),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onLongPress: () {
                        Get.defaultDialog(
                          title: "Delete Transaction",
                          middleText:
                              "Delete this transaction? Balance will be reverted.",
                          textConfirm: "Delete",
                          textCancel: "Cancel",
                          onConfirm: () {
                            controller.deleteTransaction(tx);
                            Get.back();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.resetForm();
          Get.to(() => const AddEditTransactionView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
