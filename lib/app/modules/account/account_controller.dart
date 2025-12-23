import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/account_provider.dart';
import '../../data/providers/account_type_provider.dart';
import '../../data/providers/transaction_provider.dart';

class AccountController extends GetxController {
  final AccountProvider provider = AccountProvider();
  final AccountTypeProvider typeProvider = AccountTypeProvider();
  final TransactionProvider transactionProvider = TransactionProvider();
  final accounts = <Account>[].obs;
  final availableAccountTypes = <String>[].obs;

  // Form handling
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final selectedType =
      ''.obs; // Empty initially, will bet set after loading types
  final selectedColor = 0xFF2196F3.obs; // Blue default
  final selectedIcon = 0xe04f.obs; // wallet icon

  Map<String, List<Account>> get groupedAccounts {
    final grouped = <String, List<Account>>{};
    for (var account in accounts) {
      if (!grouped.containsKey(account.type)) {
        grouped[account.type] = [];
      }
      grouped[account.type]!.add(account);
    }
    return grouped;
  }

  double getGroupTotal(String type) {
    return accounts
        .where((a) => a.type == type)
        .fold(0.0, (sum, item) => sum + item.balance);
  }

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
    loadAccountTypes();
  }

  void loadAccountTypes() async {
    var types = await typeProvider.getAllAccountTypes();
    if (types.isNotEmpty) {
      availableAccountTypes.assignAll(types.map((e) => e.name).toList());
      if (selectedType.value.isEmpty) {
        selectedType.value = availableAccountTypes.first;
      }
    } else {
      // Fallback if no types found (shouldn't happen due to migration seeding)
      availableAccountTypes.assignAll(['Cash', 'Bank']);
      selectedType.value = 'Cash';
    }
  }

  void loadAccounts() async {
    var list = await provider.getAllAccounts();
    accounts.assignAll(list);
  }

  Future<void> addAccount() async {
    if (formKey.currentState!.validate()) {
      final account = Account(
        name: nameController.text,
        type: selectedType.value,
        icon: selectedIcon.value,
        color: selectedColor.value,
        balance:
            double.tryParse(balanceController.text.replaceAll(',', '')) ?? 0.0,
      );
      await provider.addAccount(account);
      loadAccounts();
      Get.back();
      resetForm();
    }
  }

  Future<void> updateAccount(Account account) async {
    if (formKey.currentState!.validate()) {
      // Get the old balance before updating
      final oldBalance = account.balance;

      account.name = nameController.text;
      account.type = selectedType.value;
      account.icon = selectedIcon.value;
      account.color = selectedColor.value;
      account.balance =
          double.tryParse(balanceController.text.replaceAll(',', '')) ??
          account.balance;

      // Calculate the difference
      final newBalance = account.balance;
      final difference = newBalance - oldBalance;

      // Update the account first
      await provider.updateAccount(account);

      // If there's a balance change, record it as a transaction
      if (difference != 0) {
        final now = DateTime.now();
        final dateOnly = DateTime(
          now.year,
          now.month,
          now.day,
        ).toIso8601String().split('T')[0];

        final transaction = TransactionModel(
          accountId: account.id!,
          categoryId: null, // No category for balance adjustments
          transferAccountId: null,
          amount: difference.abs(),
          date: dateOnly,
          note: 'Difference',
          type: difference > 0 ? 'income' : 'expense',
          createdAt: DateTime.now().toIso8601String(),
        );

        await transactionProvider.addTransaction(transaction);
      }

      loadAccounts();
      Get.back();
      resetForm();
    }
  }

  Future<void> deleteAccount(int id) async {
    await provider.deleteAccount(id);
    loadAccounts();
  }

  void resetForm() {
    nameController.clear();
    balanceController.clear();
    if (availableAccountTypes.isNotEmpty) {
      selectedType.value = availableAccountTypes.first;
    }
  }

  void populateForm(Account account) {
    nameController.text = account.name;
    balanceController.text = account.balance.toString();
    selectedType.value = account.type;
    selectedColor.value = account.color;
    selectedIcon.value = account.icon;
  }
}
