import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account_type_model.dart';
import '../../data/providers/account_type_provider.dart';

class AccountTypeController extends GetxController {
  final AccountTypeProvider provider = AccountTypeProvider();
  final accountTypes = <AccountType>[].obs;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAccountTypes();
  }

  void loadAccountTypes() async {
    var list = await provider.getAllAccountTypes();
    accountTypes.assignAll(list);
  }

  Future<void> addAccountType() async {
    if (formKey.currentState!.validate()) {
      final type = AccountType(name: nameController.text);
      // Check for duplicate locally for better UX, though DB handles unique constraint
      if (accountTypes.any(
        (t) => t.name.toLowerCase() == type.name.toLowerCase(),
      )) {
        Get.snackbar('Error', 'Account type already exists');
        return;
      }

      await provider.addAccountType(type);
      loadAccountTypes();
      Get.back();
      nameController.clear();
    }
  }

  Future<void> updateAccountType(AccountType type) async {
    if (formKey.currentState!.validate()) {
      // Check if name changed and conflicts
      if (accountTypes.any(
        (t) =>
            t.id != type.id &&
            t.name.toLowerCase() == nameController.text.toLowerCase(),
      )) {
        Get.snackbar('Error', 'Account type already exists');
        return;
      }

      type.name = nameController.text;
      await provider.updateAccountType(type);
      loadAccountTypes();
      Get.back();
      nameController.clear();
    }
  }

  Future<void> deleteAccountType(int id) async {
    // Ideally check for dependencies (accounts using this type) before deleting
    await provider.deleteAccountType(id);
    loadAccountTypes();
  }

  void populateForm(AccountType type) {
    nameController.text = type.name;
  }
}
