import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'category_controller.dart';
import 'add_edit_category_view.dart';
import '../../utils/icon_helper.dart';

class CategoryView extends GetView<CategoryController> {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Obx(
        () => controller.categories.isEmpty
            ? Center(child: Text("No categories found"))
            : ListView.separated(
                itemCount: controller.categories.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final category = controller.categories[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(category.color),
                      child: Icon(
                        IconHelper.getIcon(category.icon),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(category.name),
                    subtitle: Text(category.type.toUpperCase()),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      controller.populateForm(category);
                      Get.to(() => AddEditCategoryView(category: category));
                    },
                    onLongPress: () {
                      Get.defaultDialog(
                        title: "Delete Category",
                        middleText:
                            "Are you sure you want to delete this category?",
                        textConfirm: "Delete",
                        textCancel: "Cancel",
                        onConfirm: () {
                          controller.deleteCategory(category.id!);
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
          Get.to(() => const AddEditCategoryView());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
