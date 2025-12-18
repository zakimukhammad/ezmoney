import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import 'transaction_controller.dart';

class AddEditTransactionView extends GetView<TransactionController> {
  final TransactionModel? transaction;
  const AddEditTransactionView({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    final isEditing = transaction != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              // Type Selector
              Obx(
                () => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'income', label: Text('Income')),
                    ButtonSegment(value: 'expense', label: Text('Expense')),
                    ButtonSegment(value: 'transfer', label: Text('Transfer')),
                  ],
                  selected: {controller.selectedType.value},
                  onSelectionChanged: (Set<String> newSelection) {
                    controller.onTypeChanged(newSelection.first);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: controller.amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),

              // Date Picker
              Obx(
                () => ListTile(
                  title: Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(controller.selectedDate.value)}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: controller.selectedDate.value,
                    );
                    if (picked != null) controller.selectedDate.value = picked;
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Account Selection (Source)
              Obx(
                () => DropdownButtonFormField<int>(
                  initialValue: controller.selectedAccountId.value,
                  items: controller.accounts
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)),
                      )
                      .toList(),
                  onChanged: (val) => controller.selectedAccountId.value = val,
                  decoration: InputDecoration(
                    labelText: controller.selectedType.value == 'transfer'
                        ? 'From Account'
                        : 'Account',
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Transfer Destination Account
              Obx(
                () => Visibility(
                  visible: controller.selectedType.value == 'transfer',
                  child: DropdownButtonFormField<int>(
                    initialValue: controller.selectedTransferAccountId.value,
                    items: controller.accounts
                        .where(
                          (e) => e.id != controller.selectedAccountId.value,
                        ) // Exclude source if possible, but Obx might not update fast enough without logic
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        controller.selectedTransferAccountId.value = val,
                    decoration: const InputDecoration(labelText: 'To Account'),
                  ),
                ),
              ),

              // Category Selection (Hidden for Transfer)
              Obx(
                () => Visibility(
                  visible: controller.selectedType.value != 'transfer',
                  child: DropdownButtonFormField<int>(
                    initialValue: controller.selectedCategoryId.value,
                    items: controller.categories
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        controller.selectedCategoryId.value = val,
                    decoration: const InputDecoration(labelText: 'Category'),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Note
              TextFormField(
                controller: controller.noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    // For editing, we need logic to pass new object and old object
                    // But here we construct new object from form
                    // We need the old object to revert. `transaction` is the old object.
                    // We should probably construct the new one inside controller using form values.
                    // And pass old one too.
                    // Wait, controller.updateTransaction(newTx, oldTx)

                    final newTx = TransactionModel(
                      id: transaction!.id,
                      accountId: controller.selectedAccountId.value!,
                      categoryId: controller.selectedType.value == 'transfer'
                          ? null
                          : controller.selectedCategoryId.value,
                      transferAccountId:
                          controller.selectedType.value == 'transfer'
                          ? controller.selectedTransferAccountId.value
                          : null,
                      amount: double.parse(
                        controller.amountController.text.replaceAll(',', ''),
                      ),
                      date: DateFormat(
                        'yyyy-MM-dd',
                      ).format(controller.selectedDate.value),
                      note: controller.noteController.text,
                      type: controller.selectedType.value,
                      createdAt: transaction!.createdAt,
                    );

                    controller.updateTransaction(newTx, transaction!);
                  } else {
                    controller.addTransaction();
                  }
                },
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
