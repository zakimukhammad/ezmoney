import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account_model.dart';
import '../../data/providers/account_provider.dart';
import '../../data/providers/account_type_provider.dart';

class AccountController extends GetxController {
  final AccountProvider provider = AccountProvider();
  final AccountTypeProvider typeProvider = AccountTypeProvider();
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
      account.name = nameController.text;
      account.type = selectedType.value;
      account.icon = selectedIcon.value;
      account.color = selectedColor.value;
      account.balance =
          double.tryParse(balanceController.text.replaceAll(',', '')) ??
          account.balance;

      await provider.updateAccount(account);
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
