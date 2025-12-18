import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/providers/category_provider.dart';

class CategoryController extends GetxController {
  final CategoryProvider provider = CategoryProvider();
  final categories = <Category>[].obs;

  // Form
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final selectedType = 'expense'.obs; // 'income' or 'expense'
  final selectedColor = 0xFF4CAF50.obs;
  final selectedIcon = 0xe57f.obs; // star? or category

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() async {
    var list = await provider.getAllCategories();
    categories.assignAll(list);
  }

  Future<void> addCategory() async {
    if (formKey.currentState!.validate()) {
      final category = Category(
        name: nameController.text,
        type: selectedType.value,
        icon: selectedIcon.value,
        color: selectedColor.value,
      );
      await provider.addCategory(category);
      loadCategories();
      Get.back();
      resetForm();
    }
  }

  Future<void> updateCategory(Category category) async {
    if (formKey.currentState!.validate()) {
      category.name = nameController.text;
      category.type = selectedType.value;
      category.icon = selectedIcon.value;
      category.color = selectedColor.value;

      await provider.updateCategory(category);
      loadCategories();
      Get.back();
      resetForm();
    }
  }

  Future<void> deleteCategory(int id) async {
    await provider.deleteCategory(id);
    loadCategories();
  }

  void resetForm() {
    nameController.clear();
    selectedType.value = 'expense';
  }

  void populateForm(Category category) {
    nameController.text = category.name;
    selectedType.value = category.type;
    selectedColor.value = category.color;
    selectedIcon.value = category.icon;
  }
}
