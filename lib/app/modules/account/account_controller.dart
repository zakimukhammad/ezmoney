import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account_model.dart';
import '../../data/providers/account_provider.dart';

class AccountController extends GetxController {
  final AccountProvider provider = AccountProvider();
  final accounts = <Account>[].obs;

  // Form handling
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  final selectedType = 'Cash'.obs;
  final selectedColor = 0xFF2196F3.obs; // Blue default
  final selectedIcon = 0xe04f.obs; // wallet icon

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
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
    selectedType.value = 'Cash';
  }

  void populateForm(Account account) {
    nameController.text = account.name;
    balanceController.text = account.balance.toString();
    selectedType.value = account.type;
    selectedColor.value = account.color;
    selectedIcon.value = account.icon;
  }
}
