import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iron_street_app/app/data/models/category_model.dart';
import 'package:iron_street_app/app/data/repositories/main_repositories.dart';

class HomeController extends GetxController {
  final MainRepositories repositories;
  HomeController({required this.repositories});
  @override
  void onInit() {
    super.onInit();
    _startTimer();
    fetchCategories();
  }

  // Navigation State
  var currentIndex = 0.obs;

  // Selected subcategory for filtering (All, Living, Bedroom, Dining)
  var selectedSubCategory = 'All'.obs;

  // Search filter query
  var searchQuery = ''.obs;

  // Scaffold key for drawer
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Timer Countdown state (simulating real-time lightning deal)
  var minutes = 14.obs;
  var seconds = 59.obs;

  var isCategoriesLoading = true.obs;
  var allCategories = <CategoryModel>[].obs;
  var mainCategories = <CategoryModel>[].obs;
  var subCategories = <CategoryModel>[].obs;

  var selectedMainCatId = 0.obs;

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;

      dynamic response =
          await repositories.fetchCategories(page: 1, perPage: 100);

      List<CategoryModel> fetchedCats = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      allCategories.assignAll(fetchedCats);

      // 1. Filter out ONLY the Main Categories (parent == 0)
      mainCategories
          .assignAll(allCategories.where((cat) => cat.parentId == 0).toList());

      // 2. Select the first Main Category automatically (e.g., "Bedroom")
      if (mainCategories.isNotEmpty) {
        selectMainCategory(mainCategories.first.id);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        if (minutes.value > 0) {
          minutes.value--;
          seconds.value = 59;
        } else {
          // Restart timer loop for mock realism
          minutes.value = 15;
          seconds.value = 0;
        }
      }
      _startTimer();
    });
  }

  void selectMainCategory(int mainId) {
    selectedMainCatId.value = mainId;

    // Find all subcategories where the parent matches the tapped tab
    subCategories.assignAll(
        allCategories.where((cat) => cat.parentId == mainId).toList());
  }

  void onTabChanged(int index) {
    currentIndex.value = index;
    // Clear search when manually routing via bottom nav
    searchQuery.value = '';
  }

  void selectSubCategory(String category) {
    selectedSubCategory.value = category;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }
}
