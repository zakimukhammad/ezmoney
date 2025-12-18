import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account_model.dart';
import 'account_controller.dart';

class AddEditAccountView extends GetView<AccountController> {
  final Account? account;
  const AddEditAccountView({super.key, this.account});

  @override
  Widget build(BuildContext context) {
    final isEditing = account != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Account' : 'Add Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: controller.balanceController,
                decoration: const InputDecoration(labelText: 'Current Balance'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedType.value,
                  items: ['Cash', 'Bank', 'E-Wallet', 'Card']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) => controller.selectedType.value = val!,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    controller.updateAccount(account!);
                  } else {
                    controller.addAccount();
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
