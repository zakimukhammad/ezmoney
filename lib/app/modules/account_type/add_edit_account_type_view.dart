import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account_type_model.dart';
import 'account_type_controller.dart';

class AddEditAccountTypeView extends GetView<AccountTypeController> {
  final AccountType? accountType;
  const AddEditAccountTypeView({super.key, this.accountType});

  @override
  Widget build(BuildContext context) {
    // If controller is not registered yet (e.g. direct nav), find or put likely needed here
    // but usually GetView expects it to be there.
    // Since we might use bindings, we assume controller is available.
    // If accountType is passed, populate form.
    if (accountType == null) {
      controller.nameController.clear();
    } else {
      controller.populateForm(accountType!);
    }

    final isEditing = accountType != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Account Type' : 'Add Account Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    controller.updateAccountType(accountType!);
                  } else {
                    controller.addAccountType();
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
