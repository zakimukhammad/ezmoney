import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/account_model.dart';
import '../../data/models/category_model.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/account_provider.dart';
import '../../data/providers/category_provider.dart';

class TransactionController extends GetxController {
  final TransactionProvider transactionProvider = TransactionProvider();
  final AccountProvider accountProvider = AccountProvider();
  final CategoryProvider categoryProvider = CategoryProvider();

  final transactions = <TransactionModel>[].obs;
  final accounts = <Account>[].obs;
  final categories = <Category>[].obs; // Current type's categories

  // Form
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final selectedDate = DateTime.now().obs;
  final selectedType = 'expense'.obs; // income, expense, transfer
  final selectedAccountId = Rxn<int>(); // Source for transfer
  final selectedTransferAccountId = Rxn<int>(); // Destination for transfer
  final selectedCategoryId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    await loadTransactions();
    await loadAccounts();
    await loadCategories(); // Load initial categories based on type
  }

  Future<void> loadTransactions() async {
    var list = await transactionProvider.getAllTransactions();
    transactions.assignAll(list);
  }

  Future<void> loadAccounts() async {
    var list = await accountProvider.getAllAccounts();
    accounts.assignAll(list);
  }

  Future<void> loadCategories() async {
    if (selectedType.value == 'transfer') {
      categories.clear();
      return;
    }
    var list = await categoryProvider.getCategoriesByType(selectedType.value);
    categories.assignAll(list);
  }

  void onTypeChanged(String type) {
    selectedType.value = type;
    selectedCategoryId.value = null; // Reset category
    // selectedTransferAccountId.value = null; // Keep or reset?
    loadCategories();
  }

  Future<void> addTransaction() async {
    if (!validateForm()) return;

    final transaction = TransactionModel(
      accountId: selectedAccountId.value!,
      categoryId: selectedType.value == 'transfer'
          ? null
          : selectedCategoryId.value,
      transferAccountId: selectedType.value == 'transfer'
          ? selectedTransferAccountId.value
          : null,
      amount: double.parse(amountController.text.replaceAll(',', '')),
      date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
      note: noteController.text,
      type: selectedType.value,
      createdAt: DateTime.now().toIso8601String(),
    );

    // Update Balance logic
    await applyBalance(transaction);
    await transactionProvider.addTransaction(transaction);

    loadTransactions();
    loadAccounts(); // Refresh accounts to show new balance
    Get.back();
    resetForm();
  }

  Future<void> deleteTransaction(TransactionModel transaction) async {
    await revertBalance(transaction);
    await transactionProvider.deleteTransaction(transaction.id!);
    loadTransactions();
    loadAccounts();
  }

  Future<void> updateTransaction(
    TransactionModel newTx,
    TransactionModel oldTx,
  ) async {
    await revertBalance(oldTx);
    await applyBalance(newTx);
    await transactionProvider.updateTransaction(newTx);
    loadTransactions();
    loadAccounts();
    Get.back();
    resetForm();
  }

  Future<void> applyBalance(TransactionModel tx) async {
    final account = accounts.firstWhere(
      (element) => element.id == tx.accountId,
    );
    if (tx.type == 'income') {
      account.balance += tx.amount;
      await accountProvider.updateAccount(account);
    } else if (tx.type == 'expense') {
      account.balance -= tx.amount;
      await accountProvider.updateAccount(account);
    } else if (tx.type == 'transfer' && tx.transferAccountId != null) {
      account.balance -= tx.amount;
      await accountProvider.updateAccount(account);

      final targetAccount = accounts.firstWhere(
        (element) => element.id == tx.transferAccountId,
      );
      targetAccount.balance += tx.amount;
      await accountProvider.updateAccount(targetAccount);
    }
  }

  Future<void> revertBalance(TransactionModel tx) async {
    final account = accounts.firstWhere(
      (element) => element.id == tx.accountId,
    );
    if (tx.type == 'income') {
      account.balance -= tx.amount;
      await accountProvider.updateAccount(account);
    } else if (tx.type == 'expense') {
      account.balance += tx.amount;
      await accountProvider.updateAccount(account);
    } else if (tx.type == 'transfer' && tx.transferAccountId != null) {
      account.balance += tx.amount;
      await accountProvider.updateAccount(account);

      final targetAccount = accounts.firstWhere(
        (element) => element.id == tx.transferAccountId,
      );
      targetAccount.balance -= tx.amount;
      await accountProvider.updateAccount(targetAccount);
    }
  }

  bool validateForm() {
    if (!formKey.currentState!.validate()) return false;
    if (selectedAccountId.value == null) {
      Get.snackbar('Error', 'Please select an account');
      return false;
    }
    if (selectedType.value != 'transfer' && selectedCategoryId.value == null) {
      Get.snackbar('Error', 'Please select a category');
      return false;
    }
    if (selectedType.value == 'transfer' &&
        selectedTransferAccountId.value == null) {
      Get.snackbar('Error', 'Please select a destination account');
      return false;
    }
    if (selectedType.value == 'transfer' &&
        selectedAccountId.value == selectedTransferAccountId.value) {
      Get.snackbar('Error', 'Source and Destination cannot be same');
      return false;
    }
    return true;
  }

  void resetForm() {
    amountController.clear();
    noteController.clear();
    selectedDate.value = DateTime.now();
    selectedType.value = 'expense';
    selectedAccountId.value = null;
    selectedCategoryId.value = null;
    selectedTransferAccountId.value = null;
    loadCategories();
  }

  void populateForm(TransactionModel tx) {
    amountController.text = tx.amount.toString();
    noteController.text = tx.note;
    selectedDate.value = DateTime.parse(tx.date);
    selectedType.value = tx.type;
    selectedAccountId.value = tx.accountId;
    selectedCategoryId.value = tx.categoryId;
    selectedTransferAccountId.value = tx.transferAccountId;
    loadCategories();
  }
}
