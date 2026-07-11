import 'package:get/get.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_response_model.dart';
import '../../data/repositories/main_repositories.dart';

class CartItem {
  final Product product;
  RxInt quantity;
  final String key; // Unique key identifying the cart item in WooCommerce

  CartItem({
    required this.product,
    required int qty,
    required this.key,
  }) : quantity = qty.obs;
}

class CartController extends GetxController {
  final MainRepositories repositories = Get.isRegistered<MainRepositories>()
      ? Get.find<MainRepositories>()
      : Get.put(MainRepositories());

  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  int get totalCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity.value);

  double get subtotal => cartItems.fold(
      0.0, (sum, item) => sum + (item.product.price * item.quantity.value));

  double get oldSubtotal => cartItems.fold(
      0.0, (sum, item) => sum + (item.product.oldPrice * item.quantity.value));

  double get discountAmount => oldSubtotal - subtotal;

  double get deliveryPrice => subtotal > 15000 ? 0.0 : 499.0;

  double get totalAmount => subtotal + deliveryPrice;

  // Fetch the live WooCommerce cart
  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      final response = await repositories.getCart();
      if (response != null) {
        final cartResp = CartResponseModel.fromJson(response);
        final List<CartItem> items = cartResp.items.map((itemModel) {
          return CartItem(
            product: itemModel.toProduct(),
            qty: itemModel.quantity,
            key: itemModel.key,
          );
        }).toList();
        cartItems.assignAll(items);
      }
    } catch (e) {
      // Fail silently to keep UX smooth, or show details if required
    } finally {
      isLoading.value = false;
    }
  }

  // Add a product to the WooCommerce cart
  Future<void> addToCart(Product product, {int qty = 1}) async {
    try {
      final response = await repositories.addToCart(
        productId: int.tryParse(product.id) ?? 0,
        quantity: qty,
      );
      if (response != null) {
        final cartResp = CartResponseModel.fromJson(response);
        final List<CartItem> items = cartResp.items.map((itemModel) {
          return CartItem(
            product: itemModel.toProduct(),
            qty: itemModel.quantity,
            key: itemModel.key,
          );
        }).toList();
        cartItems.assignAll(items);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add item to cart: $e');
    }
  }

  // Update item quantity in WooCommerce cart
  Future<void> updateQuantity(String productId, int delta) async {
    final item = cartItems.firstWhereOrNull((item) => item.product.id == productId);
    if (item != null) {
      int nextQty = item.quantity.value + delta;
      if (nextQty <= 0) {
        await removeItem(productId);
      } else {
        try {
          final response = await repositories.updateCartItem(
            key: item.key,
            quantity: nextQty,
          );
          if (response != null) {
            final cartResp = CartResponseModel.fromJson(response);
            final List<CartItem> items = cartResp.items.map((itemModel) {
              return CartItem(
                product: itemModel.toProduct(),
                qty: itemModel.quantity,
                key: itemModel.key,
              );
            }).toList();
            cartItems.assignAll(items);
          }
        } catch (e) {
          Get.snackbar('Error', 'Failed to update quantity: $e');
        }
      }
    }
  }

  // Remove an item from the WooCommerce cart
  Future<void> removeItem(String productId) async {
    final item = cartItems.firstWhereOrNull((item) => item.product.id == productId);
    if (item != null) {
      try {
        final response = await repositories.removeCartItem(key: item.key);
        if (response != null) {
          final cartResp = CartResponseModel.fromJson(response);
          final List<CartItem> items = cartResp.items.map((itemModel) {
            return CartItem(
              product: itemModel.toProduct(),
              qty: itemModel.quantity,
              key: itemModel.key,
            );
          }).toList();
          cartItems.assignAll(items);
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to remove item: $e');
      }
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  bool isInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }
}
