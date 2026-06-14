/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:get/get.dart';
import '../../data/models/product_model.dart';

class WishlistController extends GetxController {
  var wishlistItems = <Product>[].obs;

  bool isWishlisted(String productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  void toggleWishlist(Product product) {
    if (isWishlisted(product.id)) {
      wishlistItems.removeWhere((item) => item.id == product.id);
      Get.snackbar(
        'Removed from Wishlist',
        '${product.name} removed from wishlist.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } else {
      wishlistItems.add(product);
      Get.snackbar(
        'Added to Wishlist',
        '${product.name} added to wishlist! ❤️',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }
}
