import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'account_type_controller.dart';
import 'add_edit_account_type_view.dart';

class AccountTypeView extends GetView<AccountTypeController> {
  const AccountTypeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ideally this binding should be done in a Route/Binding class, but for simplicity here:
    // We can assume the controller is provided by the navigator or we put it here if lazy.
    Get.put(AccountTypeController());

    return Scaffold(
      appBar: AppBar(title: const Text('Account Types')),
      body: Obx(
        () => controller.accountTypes.isEmpty
            ? Center(child: Text("No account types found"))
            : ListView.separated(
                itemCount: controller.accountTypes.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final type = controller.accountTypes[index];
                  return ListTile(
                    title: Text(type.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Get.to(
                              () => AddEditAccountTypeView(accountType: type),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Get.defaultDialog(
                              title: "Delete Account Type",
                              middleText:
                                  "Are you sure? This might affect accounts using this type.",
                              textConfirm: "Delete",
                              textCancel: "Cancel",
                              onConfirm: () {
                                controller.deleteAccountType(type.id!);
                                Get.back();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const AddEditAccountTypeView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
