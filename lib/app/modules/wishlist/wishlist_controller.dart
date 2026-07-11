

import 'package:get/get.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';

// class WishlistController extends GetxController {
//   var wishlistItems = <Product>[].obs;

//   bool isWishlisted(String productId) {
//     return wishlistItems.any((item) => item.id == productId);
//   }

//   void toggleWishlist(Product product) {
//     if (isWishlisted(product.id)) {
//       wishlistItems.removeWhere((item) => item.id == product.id);
//       Get.snackbar(
//         'Removed from Wishlist',
//         '${product.name} removed from wishlist.',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 1),
//       );
//     } else {
//       wishlistItems.add(product);
//       Get.snackbar(
//         'Added to Wishlist',
//         '${product.name} added to wishlist! ❤️',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 1),
//       );
//     }
//   }
// }
class WishlistController extends GetxController {
  final RxList<ProductListModel> wishlistItems = <ProductListModel>[].obs;

  void toggleWishlist(ProductListModel product) {
    final exists = wishlistItems.any((item) => item.id == product.id);

    if (exists) {
      wishlistItems.removeWhere((item) => item.id == product.id);
    } else {
      wishlistItems.add(product);
    }
  }

  bool isInWishlist(int productId) {
    return wishlistItems.any((item) => item.id == productId);
  }
}