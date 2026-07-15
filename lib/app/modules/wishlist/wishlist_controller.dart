import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iron_street_app/app/data/local/session_manager.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/repositories/wishlist_repository/wishlist_repository.dart';

class WishlistController extends GetxController {
  final WishlistRepository wishlistRepository = Get.find<WishlistRepository>();

  final SessionManager _sessionManager = Get.find<SessionManager>();

  final RxList<ProductListModel> wishlistItems = <ProductListModel>[].obs;
  var wishlistId = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWishlistFromServer();
  }

  Future<void> fetchWishlistFromServer() async {
    if (_sessionManager.isLoggedIn()) {
      try {
        isLoading.value = true;
        final data = await wishlistRepository.fetchWishlist();
        wishlistId.value = data['wishlist_id'] ?? 0;
        wishlistItems.assignAll(data['items'] ?? []);
      } catch (e) {
        // Fail silently to keep UX smooth
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> toggleWishlist(ProductListModel product) async {
    final exists = wishlistItems.any((item) => item.id == product.id);

    // Optimistic UI updates
    if (exists) {
      wishlistItems.removeWhere((item) => item.id == product.id);
      Get.snackbar(
        'Removed from Wishlist',
        '${product.name} removed.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } else {
      wishlistItems.add(product);
      Get.snackbar(
        'Added to Wishlist',
        '${product.name} added! ❤️',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }

    if (_sessionManager.isLoggedIn()) {
      try {
        if (exists) {
          await wishlistRepository.removeFromWishlist(
            productId: product.id,
            wishlistId: wishlistId.value,
          );
        } else {
          await wishlistRepository.addToWishlist(
            productId: product.id,
            wishlistId: wishlistId.value,
          );
        }
      } catch (e) {
        // Revert local state on failure
        if (exists) {
          wishlistItems.add(product);
        } else {
          wishlistItems.removeWhere((item) => item.id == product.id);
        }
        Get.snackbar(
          'Sync Failed',
          'Could not synchronize wishlist with server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFC62828),
        );
      }
    }
  }

  bool isInWishlist(int productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  void clearWishlist() {
    wishlistItems.clear();
    wishlistId.value = 0;
  }
}