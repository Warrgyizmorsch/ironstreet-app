/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/dummy_data.dart';

class CategoryController extends GetxController {
  var selectedCategory = 'All'.obs;
  var sortBy = 'rating'.obs; // rating, priceLowHigh, priceHighLow
  var searchQuery = ''.obs;

  List<Product> get filteredProducts {
    return allAvailableProducts.where((p) {
      final matchesCat = selectedCategory.value == 'All' ||
          p.category.toLowerCase() == selectedCategory.value.toLowerCase();
      final matchesSearch = p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.brand.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          p.material.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  List<Product> get sortedProducts {
    var items = List<Product>.from(filteredProducts);
    if (sortBy.value == 'rating') {
      items.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy.value == 'priceLowHigh') {
      items.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy.value == 'priceHighLow') {
      items.sort((a, b) => b.price.compareTo(a.price));
    }
    return items;
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void updateSort(String order) {
    sortBy.value = order;
  }
}
