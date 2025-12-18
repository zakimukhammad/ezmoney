import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'account_controller.dart';
import 'add_edit_account_view.dart';
import '../../utils/formatters.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Obx(
        () => controller.accounts.isEmpty
            ? Center(child: Text("No accounts found"))
            : ListView.separated(
                itemCount: controller.accounts.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final account = controller.accounts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(account.color),
                      child: Icon(
                        IconData(account.icon, fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(account.name),
                    subtitle: Text(account.type),
                    trailing: Text(
                      CurrencyFormatter.format(account.balance),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      controller.populateForm(account);
                      Get.to(() => AddEditAccountView(account: account));
                    },
                    onLongPress: () {
                      Get.defaultDialog(
                        title: "Delete Account",
                        middleText:
                            "Are you sure you want to delete this account?",
                        textConfirm: "Delete",
                        textCancel: "Cancel",
                        onConfirm: () {
                          controller.deleteAccount(account.id!);
                          Get.back();
                        },
                      );
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.resetForm();
          Get.to(() => const AddEditAccountView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
