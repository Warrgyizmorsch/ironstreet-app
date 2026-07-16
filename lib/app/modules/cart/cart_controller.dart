import 'package:get/get.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_response_model.dart';
import '../../data/repositories/cart_repository/cart_repository.dart';
import '../address/address_controller.dart';

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
  final CartRepository cartRepository = Get.find<CartRepository>();

  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;

  // Live WooCommerce Cart totals
  var subtotalValue = 0.0.obs;
  var deliveryPriceValue = 0.0.obs;
  var totalTaxValue = 0.0.obs;
  var totalAmountValue = 0.0.obs;
  var totalDiscountValue = 0.0.obs;

  // WooCommerce addresses from the cart
  var shippingAddress = Rxn<CartAddressModel>();
  var billingAddress = Rxn<CartAddressModel>();

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController());
    }
    fetchCart();
  }

  int get totalCount =>
      cartItems.fold(0, (sum, item) => sum + item.quantity.value);

  double get subtotal => subtotalValue.value;
  double get oldSubtotal => subtotalValue.value + totalDiscountValue.value;
  double get discountAmount => totalDiscountValue.value;
  double get deliveryPrice => deliveryPriceValue.value;
  double get totalTax => totalTaxValue.value;
  double get totalAmount => totalAmountValue.value;

  void _updateTotals(CartTotalsModel totals) {
    subtotalValue.value = totals.totalItems;
    deliveryPriceValue.value = totals.totalShipping;
    totalTaxValue.value = totals.totalTax;
    totalAmountValue.value = totals.totalPrice;
    totalDiscountValue.value = totals.totalDiscount;
  }

  void _updateAddresses(CartResponseModel cartResp) {
    shippingAddress.value = cartResp.shippingAddress;
    billingAddress.value = cartResp.billingAddress;

    // Sync back to AddressController
    if (Get.isRegistered<AddressController>() && cartResp.shippingAddress != null) {
      Get.find<AddressController>().syncFromWooCommerce(cartResp.shippingAddress);
    }
  }

  // Fetch the live WooCommerce cart
  Future<void> fetchCart() async {
    try {
      isLoading.value = true;
      final response = await cartRepository.getCart();
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
        _updateTotals(cartResp.totals);
        _updateAddresses(cartResp);
      }
    } catch (e) {
      // Fail silently to keep UX smooth
    } finally {
      isLoading.value = false;
    }
  }

  // Add a product to the WooCommerce cart
  Future<void> addToCart(Product product, {int qty = 1}) async {
    try {
      final response = await cartRepository.addToCart(
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
        _updateTotals(cartResp.totals);
        _updateAddresses(cartResp);
      }
    } catch (e) {
      CustomToast.show('Failed to add item to cart: $e', isError: true);
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
          final response = await cartRepository.updateCartItem(
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
            _updateTotals(cartResp.totals);
          }
        } catch (e) {
          CustomToast.show('Failed to update quantity: $e', isError: true);
        }
      }
    }
  }

  // Remove an item from the WooCommerce cart
  Future<void> removeItem(String productId) async {
    final item = cartItems.firstWhereOrNull((item) => item.product.id == productId);
    if (item != null) {
      try {
        final response = await cartRepository.removeCartItem(key: item.key);
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
          _updateTotals(cartResp.totals);
        }
      } catch (e) {
        CustomToast.show('Failed to remove item: $e', isError: true);
      }
    }
  }

  void clearCart() {
    cartItems.clear();
    subtotalValue.value = 0.0;
    deliveryPriceValue.value = 0.0;
    totalTaxValue.value = 0.0;
    totalAmountValue.value = 0.0;
    totalDiscountValue.value = 0.0;
  }

  bool isInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }
}
