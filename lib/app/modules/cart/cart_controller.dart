/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:get/get.dart';
import '../../data/models/product_model.dart';

class CartItem {
  final Product product;
  RxInt quantity;

  CartItem({required this.product, required int qty}) : quantity = qty.obs;
}

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;

  int get totalCount => cartItems.fold(0, (sum, item) => sum + item.quantity.value);

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity.value));

  double get oldSubtotal => cartItems.fold(0.0, (sum, item) => sum + (item.product.oldPrice * item.quantity.value));

  double get discountAmount => oldSubtotal - subtotal;

  double get deliveryPrice => subtotal > 15000 ? 0.0 : 499.0;

  double get totalAmount => subtotal + deliveryPrice;

  void addToCart(Product product) {
    var existingItem = cartItems.firstWhereOrNull((item) => item.product.id == product.id);
    if (existingItem != null) {
      existingItem.quantity.value++;
    } else {
      cartItems.add(CartItem(product: product, qty: 1));
    }
    Get.snackbar(
      'Added to Cart',
      '${product.name} is added to your shopping bag!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void updateQuantity(String productId, int delta) {
    var item = cartItems.firstWhereOrNull((item) => item.product.id == productId);
    if (item != null) {
      int nextQty = item.quantity.value + delta;
      if (nextQty <= 0) {
        removeItem(productId);
      } else {
        item.quantity.value = nextQty;
      }
    }
  }

  void removeItem(String productId) {
    cartItems.removeWhere((item) => item.product.id == productId);
  }

  void clearCart() {
    cartItems.clear();
  }
}
