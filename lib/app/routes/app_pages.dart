import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/account/account_binding.dart';
import '../modules/account/account_view.dart';
import '../modules/category/category_binding.dart';
import '../modules/category/category_view.dart';
import '../modules/transaction/transaction_binding.dart';
import '../modules/transaction/transaction_view.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.ACCOUNT,
      page: () => const AccountView(),
      binding: AccountBinding(),
    ),
    GetPage(
      name: Routes.CATEGORY,
      page: () => const CategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.ADD_TRANSACTION, // Using the route name from Routes class
      page: () =>
          const TransactionView(), // Or AddEditTransactionView if we want direct access
      binding: TransactionBinding(),
    ),
  ];
}
