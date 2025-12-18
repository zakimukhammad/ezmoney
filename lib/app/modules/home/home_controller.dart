import 'package:get/get.dart';
import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';
import '../../data/providers/account_provider.dart';
import '../../data/providers/category_provider.dart';

class HomeController extends GetxController {
  final TransactionProvider txProvider = TransactionProvider();
  final AccountProvider accProvider = AccountProvider();

  final selectedIndex = 0.obs;

  // Dashboard Data
  final totalBalance = 0.0.obs;
  final totalIncome = 0.0.obs; // This month
  final totalExpense = 0.0.obs; // This month
  final recentTransactions = <TransactionModel>[].obs;

  // Stats Data
  final statsType = 'Monthly'.obs; // Daily, Weekly, Monthly
  final groupedStats = <String, double>{}.obs; // Category Name -> Amount

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  void loadDashboard() async {
    // Balance
    var accounts = await accProvider.getAllAccounts();
    totalBalance.value = accounts.fold(0, (sum, item) => sum + item.balance);

    // Recent Transactions
    var allTx = await txProvider.getAllTransactions();
    recentTransactions.assignAll(allTx.take(5).toList());

    // Income/Expense This Month
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Filter for this month
    var thisMonthTx = allTx.where((tx) {
      final date = DateTime.parse(tx.date);
      return date.isAfter(startOfMonth) || date.isAtSameMomentAs(startOfMonth);
    }).toList();

    totalIncome.value = thisMonthTx
        .where((tx) => tx.type == 'income')
        .fold(0, (sum, item) => sum + item.amount);

    totalExpense.value = thisMonthTx
        .where((tx) => tx.type == 'expense')
        .fold(0, (sum, item) => sum + item.amount);
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
    if (index == 0) loadDashboard();
    if (index == 1) loadStats();
  }

  void loadStats() async {
    var allTx = await txProvider.getAllTransactions();
    var categories = await CategoryProvider()
        .getAllCategories(); // Need this for names if not joined.
    // Better to have map of id -> category name
    var catMap = {for (var e in categories) e.id: e.name};

    DateTime now = DateTime.now();
    DateTime start, end;

    if (statsType.value == 'Weekly') {
      start = now.subtract(Duration(days: now.weekday - 1));
      end = start.add(const Duration(days: 7));
    } else if (statsType.value == 'Daily') {
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
    } else {
      // Monthly
      start = DateTime(now.year, now.month, 1);
      end = DateTime(now.year, now.month + 1, 1);
    }

    var filteredTx = allTx.where((tx) {
      if (tx.type != 'expense') return false; // Stats often focus on expense
      var date = DateTime.parse(tx.date);
      return date.isAfter(start.subtract(Duration(seconds: 1))) &&
          date.isBefore(end);
    }).toList();

    var stats = <String, double>{};
    for (var tx in filteredTx) {
      if (tx.categoryId == null) continue;
      String catName = catMap[tx.categoryId] ?? 'Unknown';
      stats[catName] = (stats[catName] ?? 0) + tx.amount;
    }
    groupedStats.assignAll(stats);
  }
}
