import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'account_controller.dart';
import 'add_edit_account_view.dart';
import '../../utils/formatters.dart';
import '../../utils/icon_helper.dart';
import '../account_type/account_type_view.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Get.to(() => const AccountTypeView()),
            tooltip: 'Manage Account Types',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.accounts.isEmpty) {
          return const Center(child: Text("No accounts found"));
        }
        final grouped = controller.groupedAccounts;
        return ListView.builder(
          itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            String type = grouped.keys.elementAt(index);
            List<dynamic> accounts = grouped[type]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(
                          controller.getGroupTotal(type),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: accounts.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final account = accounts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(account.color),
                        child: Icon(
                          IconHelper.getIcon(account.icon),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(account.name),
                      subtitle: Text(account.type),
                      trailing: Text(
                        CurrencyFormatter.format(account.balance),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
              ],
            );
          },
        );
      }),
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
