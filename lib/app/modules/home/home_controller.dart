// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iron_street_app/app/data/models/category_model.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/models/product_tag_model.dart';
import 'package:iron_street_app/app/data/repositories/category_repository/category_repository.dart';
import 'package:iron_street_app/app/data/repositories/product_repository/product_repository.dart';

class HomeController extends GetxController {

  final CategoryRepository categoryRepository = Get.find<CategoryRepository>();

  final ProductRepository productRepository = Get.find<ProductRepository>();
  @override
  void onInit() {
    super.onInit();
    _startTimer();
    debounce<String>(
      searchQuery,
      (value) {
        handleSearch(value);
      },
      time: const Duration(milliseconds: 500),
    );
    setupScrollListener();

    // fetchCategories();
    // fetchCustomerFavoriteProducts();
    // fetchBestSellingChairs();
    // fetchOutdoorFurnitureProducts();
    // fetchAllTagProductSections();

    // fetchProductsByCategory(0);
    loadInitialData();
  }

  // Navigation State
  var currentIndex = 0.obs;

  // Selected subcategory for filtering (All, Living, Bedroom, Dining)
  var selectedSubCategory = 'All'.obs;

  // Scaffold key for drawer
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Timer Countdown state (simulating real-time lightning deal)
  var minutes = 14.obs;
  var seconds = 59.obs;

  var isCategoriesLoading = true.obs;
  var isCustomerFavoritesLoading = false.obs;
  var isBestSellingChairsLoading = false.obs;
  var isOutdoorFurnitureLoading = false.obs;
  final isSearchLoading = false.obs;
  var isProductsLoading = false.obs; // For the initial page 1 load
  var isFetchingMoreProducts = false.obs; // For loading page 2, 3...
  var hasMoreProducts = true.obs;
  final searchQuery = ''.obs;
  final isSearchMode = false.obs;
  int searchPage = 1;
  bool hasMoreSearchProducts = true;
  final int searchPerPage = 20;

  var isTagsLoading = false.obs;
  var productTags = <ProductTagModel>[].obs;
  final tagProductsMap = <int, List<ProductListModel>>{}.obs;
  final tagLoadingMap = <int, bool>{}.obs;

  var allCategories = <CategoryModel>[].obs;
  var mainCategories = <CategoryModel>[].obs;
  var subCategories = <CategoryModel>[].obs;
  var customerFavoriteProducts = <ProductListModel>[].obs;
  var bestSellingChairs = <ProductListModel>[].obs;
  var outdoorFurnitureProducts = <ProductListModel>[].obs;
  final searchProductsList = <ProductListModel>[].obs;
  var products = <ProductListModel>[].obs;

  var selectedMainCatId = 0.obs;

  int productPage = 1;
  var activeProductCategoryId = 0.obs;

  final searchText = ''.obs;

  final ScrollController scrollController = ScrollController();
  final List<int> customerFavoriteIds = [
    13813,
    13808,
    15697,
    16313,
    16190,
  ];

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 250) {
        if (isSearchMode.value) {
          fetchSearchProducts(reset: false);
        } else {
          loadMoreProducts();
        }
      }
    });
  }

  Future<void> loadInitialData() async {
    try {
      await Future.wait([
        fetchCategories(),
        fetchCustomerFavoriteProducts(),
        fetchBestSellingChairs(),
        fetchOutdoorFurnitureProducts(),
        fetchAllTagProductSections(),
      ]);

      await fetchProductsByCategory(0);
    } catch (e) {
      print('Home init error: $e');
    }
  }

  Future<void> handleSearch(String value) async {
    final query = value.trim();

    if (query.isEmpty) {
      if (isSearchMode.value) {
        isSearchMode.value = false;

        // Back to selected category products
        await fetchProductsByCategory(activeProductCategoryId.value);
      }
      return;
    }

    isSearchMode.value = true;
    await fetchSearchProducts(reset: true);
  }

  Future<void> fetchSearchProducts({bool reset = false}) async {
    try {
      final query = searchQuery.value.trim();

      if (query.isEmpty) return;

      if (reset) {
        searchPage = 1;
        hasMoreSearchProducts = true;
        products.clear();
        isProductsLoading.value = true;
      } else {
        if (!hasMoreSearchProducts || isFetchingMoreProducts.value) return;
        isFetchingMoreProducts.value = true;
      }

      final result = await productRepository.searchProducts(
        query: query,
        page: searchPage,
        perPage: searchPerPage,
      );

      if (reset) {
        products.assignAll(result);
      } else {
        products.addAll(result);
      }

      if (result.length < searchPerPage) {
        hasMoreSearchProducts = false;
      } else {
        searchPage++;
      }
    } catch (e) {
      log('Search products error: $e');
    } finally {
      isProductsLoading.value = false;
      isFetchingMoreProducts.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;

    if (value.trim().isNotEmpty) {
      currentIndex.value = 1;
    }
  }

  void onCategoryTap(int categoryId) {
    isSearchMode.value = false;

    if (searchQuery.value.isNotEmpty) {
      searchQuery.value = '';
    }

    fetchProductsByCategory(categoryId);
  }

  Future<void> fetchCategories() async {
    try {
      isCategoriesLoading.value = true;

      dynamic response = await categoryRepository.fetchCategories(
        page: 1,
        perPage: 100,
      );

      List<CategoryModel> fetchedCats = (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .where((cat) => cat.count > 0)
          .toList();

      allCategories.assignAll(fetchedCats);

      final allTab = CategoryModel(
        id: 0,
        name: 'All',
        slug: 'all',
        parentId: -1,
        count: 0,
        image: '',
      );

      List<CategoryModel> mains = [allTab];

      mains.addAll(
        allCategories.where((cat) => cat.parentId == 0).toList(),
      );

      mainCategories.assignAll(mains);

      selectMainCategory(0);
    } catch (e) {
      log('Error fetching categories: $e');
      Get.snackbar('Error', 'Failed to load categories');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

// 1.when a user taps a CategoryCard
  Future<void> fetchProductsByCategory(int categoryId) async {
    try {
      activeProductCategoryId.value = categoryId;
      productPage = 1;
      hasMoreProducts.value = true;
      isProductsLoading.value = true;
      products.clear(); // Clear old products

      // Fetch Page 1
      dynamic response = await categoryRepository.fetchProductsByCategory(
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

      dynamic response = await categoryRepository.fetchProductsByCategory(
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

  Future<void> fetchCustomerFavoriteProducts() async {
    try {
      isCustomerFavoritesLoading.value = true;

      final response = await productRepository.fetchRelatedProductsByIds(
        productIds: customerFavoriteIds,
      );

      final products =
          (response as List).map((e) => ProductListModel.fromJson(e)).toList();

      customerFavoriteProducts.assignAll(products);
    } catch (e) {
      log('Customer favorite products error: $e');
    } finally {
      isCustomerFavoritesLoading.value = false;
    }
  }

  Future<void> fetchBestSellingChairs() async {
    try {
      isBestSellingChairsLoading.value = true;

      final response = await categoryRepository.fetchProductsByCategory(
        categoryId: 203,
        perPage: 10,
        page: 1,
      );

      final products =
          (response as List).map((e) => ProductListModel.fromJson(e)).toList();

      bestSellingChairs.assignAll(products);
    } catch (e) {
      log('Best Selling Chairs error: $e');
    } finally {
      isBestSellingChairsLoading.value = false;
    }
  }

  Future<void> fetchOutdoorFurnitureProducts() async {
    try {
      isOutdoorFurnitureLoading.value = true;

      final response = await categoryRepository.fetchProductsByCategory(
        categoryId: 141,
        perPage: 10,
        page: 1,
      );

      final products =
          (response as List).map((e) => ProductListModel.fromJson(e)).toList();

      outdoorFurnitureProducts.assignAll(products);
    } catch (e) {
      log('Outdoor furniture error: $e');
    } finally {
      isOutdoorFurnitureLoading.value = false;
    }
  }

  Future<void> fetchAllTagProductSections() async {
    try {
      isTagsLoading.value = true;

      final tags = await productRepository.getProductTags();

      // only tags that have products
      final activeTags = tags.where((tag) => tag.count > 1).toList();
      productTags.assignAll(activeTags);

      log('Fetched tags: ${productTags.length}');

      // fetch products for every tag
      await Future.wait(
        activeTags.map((tag) => fetchProductsForTag(tag.id)),
      );
    } catch (e) {
      log('Error fetching tag sections: $e');
    } finally {
      isTagsLoading.value = false;
    }
  }

  Future<void> fetchProductsForTag(int tagId) async {
    try {
      tagLoadingMap[tagId] = true;
      tagLoadingMap.refresh();

      final products = await productRepository.getProductsByTag(
        tagId: tagId,
        perPage: 10,
      );

      tagProductsMap[tagId] = products;
      tagProductsMap.refresh();

      log('Tag $tagId products: ${products.length}');
    } catch (e) {
      log('Error fetching products for tag $tagId: $e');
    } finally {
      tagLoadingMap[tagId] = false;
      tagLoadingMap.refresh();
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

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
