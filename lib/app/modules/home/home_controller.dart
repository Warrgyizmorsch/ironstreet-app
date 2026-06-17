import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iron_street_app/app/data/models/category_model.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/repositories/main_repositories.dart';

class HomeController extends GetxController {
  final MainRepositories repositories;
  HomeController({required this.repositories});
  @override
  void onInit() {
    super.onInit();
    _startTimer();
    fetchCategories();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadMoreProducts();
      }
    });
    fetchProductsByCategory(0);
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

  var products = <ProductListModel>[].obs;
  var isProductsLoading = false.obs; // For the initial page 1 load
  var isFetchingMoreProducts = false.obs; // For loading page 2, 3...
  var hasMoreProducts = true.obs;
  int productPage = 1;
  var activeProductCategoryId = 0.obs;

  final ScrollController scrollController = ScrollController();

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;

      dynamic response =
          await repositories.fetchCategories(page: 1, perPage: 100);

      List<CategoryModel> fetchedCats = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();

      allCategories.assignAll(fetchedCats);

      // 1. Create a custom "All" Category Model
      final allTab = CategoryModel(
        id: 0, // Use 0 as the ID for "All"
        name: 'All',
        slug: 'all',
        parentId: -1, // Set to -1 so it doesn't conflict with parent == 0
        count: 0, description: '',
      );

      // 2. Build the Main Categories list, starting with the "All" tab
      List<CategoryModel> mains = [allTab];
      mains.addAll(allCategories.where((cat) => cat.parentId == 0).toList());

      mainCategories.assignAll(mains);

      // 3. Auto-select the "All" tab (ID: 0) by default
      selectMainCategory(0);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchProductsByCategory(int categoryId) async {
    try {
      activeProductCategoryId.value = categoryId;
      productPage = 1;
      hasMoreProducts.value = true;
      isProductsLoading.value = true;
      products.clear(); // Clear old products

      // Fetch Page 1
      dynamic response = await repositories.fetchProductsByCategory(
        categoryId: activeProductCategoryId.value,
        page: productPage,
        perPage: 10,
      );

      List<ProductListModel> fetchedProducts = (response as List)
          .map((json) => ProductListModel.fromJson(json))
          .toList();

      products.assignAll(fetchedProducts);

      // If we got less than 10, there is no page 2
      if (fetchedProducts.length < 10) {
        hasMoreProducts.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load products');
    } finally {
      isProductsLoading.value = false;
    }
  }

  Future<void> loadMoreProducts() async {
    // Stop if already fetching or if no more data exists
    if (isFetchingMoreProducts.value || !hasMoreProducts.value) return;

    try {
      isFetchingMoreProducts.value = true;
      productPage++; // Go to next page

      dynamic response = await repositories.fetchProductsByCategory(
        categoryId: activeProductCategoryId.value,
        page: productPage,
        perPage: 10,
      );

      List<ProductListModel> newProducts = (response as List)
          .map((json) => ProductListModel.fromJson(json))
          .toList();

      if (newProducts.isEmpty) {
        hasMoreProducts.value = false; // We reached the end of the catalog
      } else {
        products.addAll(newProducts); // Add new items to the bottom of the list
      }
    } catch (e) {
      productPage--; // Revert page count if the API call fails
      Get.snackbar('Error', 'Failed to load more products');
    } finally {
      isFetchingMoreProducts.value = false;
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

    if (mainId == 0) {
      // IF "ALL" IS SELECTED:
      // Show every category that is NOT a main tab (parent != 0)
      subCategories
          .assignAll(allCategories.where((cat) => cat.parentId != 0).toList());
    } else {
      // IF A SPECIFIC TAB IS SELECTED:
      // Use the recursive helper method to find its nested subcategories
      List<CategoryModel> allNestedCategories = _getAllDescendants(mainId);
      subCategories.assignAll(allNestedCategories);
    }
  }

  List<CategoryModel> _getAllDescendants(int parentId) {
    List<CategoryModel> directChildren =
        allCategories.where((cat) => cat.parentId == parentId).toList();

    List<CategoryModel> result = List.from(directChildren);

    for (var child in directChildren) {
      result.addAll(_getAllDescendants(child.id));
    }

    return result;
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
