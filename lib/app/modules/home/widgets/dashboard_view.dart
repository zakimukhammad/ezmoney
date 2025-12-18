import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home_controller.dart';
import '../../../utils/formatters.dart';
// For Dashboard widgets like Card, we can keep here.

class DashboardView extends GetView<HomeController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Balance Card
          Card(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Text(
                      CurrencyFormatter.format(controller.totalBalance.value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Income',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Obx(
                            () => Text(
                              '+${CurrencyFormatter.format(controller.totalIncome.value)}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Expense',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Obx(
                            () => Text(
                              '-${CurrencyFormatter.format(controller.totalExpense.value)}',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Navigation Shortcuts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShortcut(
                Icons.account_balance_wallet,
                'Accounts',
                () => Get.toNamed('/account'),
              ),
              _buildShortcut(
                Icons.category,
                'Categories',
                () => Get.toNamed('/category'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Transactions
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Obx(
            () => controller.recentTransactions.isEmpty
                ? const Text("No recent transactions")
                : Column(
                    children: controller.recentTransactions
                        .map(
                          (tx) => ListTile(
                            leading: Icon(
                              tx.type == 'income'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: tx.type == 'income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(tx.note.isEmpty ? tx.type : tx.note),
                            subtitle: Text(tx.date),
                            trailing: Text(
                              CurrencyFormatter.format(tx.amount),
                              style: TextStyle(
                                color: tx.type == 'income'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcut(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 25, child: Icon(icon)),
          const SizedBox(height: 5),
          Text(label),
        ],
      ),
    );
  }
}
