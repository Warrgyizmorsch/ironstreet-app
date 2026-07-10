import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iron_street_app/app/data/models/category_model.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/modules/home/home_controller.dart';

class CategoryController extends GetxController {
  final homeController = Get.find<HomeController>();

  // Delegate WooCommerce observables and scroll controller
  RxList<ProductListModel> get products => homeController.products;
  RxBool get isProductsLoading => homeController.isProductsLoading;
  RxBool get isFetchingMoreProducts => homeController.isFetchingMoreProducts;
  RxBool get hasMoreProducts => homeController.hasMoreProducts;
  RxInt get activeProductCategoryId => homeController.activeProductCategoryId;
  RxList<CategoryModel> get allCategories => homeController.allCategories;
  ScrollController get scrollController => homeController.scrollController;

  // Get the main category ID. If the active category has a parent, returns the parent.
  int get rootCategoryId {
    final activeId = activeProductCategoryId.value;
    if (activeId == 0) return 0;
    
    final activeCat = allCategories.firstWhereOrNull((c) => c.id == activeId);
    if (activeCat != null && activeCat.parentId > 0) {
      return activeCat.parentId;
    }
    return activeId;
  }

  // Get sibling subcategories under the root category
  List<CategoryModel> get siblingSubcategories {
    final rootId = rootCategoryId;
    if (rootId == 0) return [];
    return allCategories.where((cat) => cat.parentId == rootId).toList();
  }

  // Local Sort and Price Filter states
  var selectedPriceFilter = 'All'.obs;
  var activeSortType = 'default'.obs;

  List<ProductListModel> get sortedAndFilteredProducts {
    List<ProductListModel> list = List<ProductListModel>.from(homeController.products);

    // Apply price filter locally
    if (selectedPriceFilter.value == 'under_10k') {
      list = list.where((p) => p.price < 10000).toList();
    } else if (selectedPriceFilter.value == '10k_20k') {
      list = list.where((p) => p.price >= 10000 && p.price <= 20000).toList();
    } else if (selectedPriceFilter.value == 'over_20k') {
      list = list.where((p) => p.price > 20000).toList();
    }

    // Apply sorting locally
    if (activeSortType.value == 'price_low_high') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (activeSortType.value == 'price_high_low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (activeSortType.value == 'rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  void fetchProductsByCategory(int categoryId) {
    homeController.fetchProductsByCategory(categoryId);
    // Reset filters
    selectedPriceFilter.value = 'All';
    activeSortType.value = 'default';
  }
}
