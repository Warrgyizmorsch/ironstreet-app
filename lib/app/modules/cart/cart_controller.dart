import 'package:get/get.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_response_model.dart';
import '../../data/repositories/cart_repository/cart_repository.dart';
import '../../data/repositories/delivery_repository/delivery_repository.dart';
import '../address/address_controller.dart';

class CartItem {
  final Product product;
  RxInt quantity;
  final String key; // Unique key identifying the cart item in WooCommerce
  final double? weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;

  CartItem({
    required this.product,
    required int qty,
    required this.key,
    this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
  }) : quantity = qty.obs;
}

class CartController extends GetxController {
  final CartRepository cartRepository = Get.find<CartRepository>();
  final DeliveryRepository _deliveryRepository = DeliveryRepository();

  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;
  var isCalculatingDelivery = false.obs;

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
    if (Get.isRegistered<AddressController>() &&
        cartResp.shippingAddress != null) {
      Get.find<AddressController>()
          .syncFromWooCommerce(cartResp.shippingAddress);
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
            weightKg: itemModel.weightKg,
            lengthCm: itemModel.lengthCm,
            widthCm: itemModel.widthCm,
            heightCm: itemModel.heightCm,
          );
        }).toList();
        cartItems.assignAll(items);
        _updateTotals(cartResp.totals);
        _updateAddresses(cartResp);
        calculateDelhiveryShippingCharge();
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
            weightKg: itemModel.weightKg,
            lengthCm: itemModel.lengthCm,
            widthCm: itemModel.widthCm,
            heightCm: itemModel.heightCm,
          );
        }).toList();
        cartItems.assignAll(items);
        _updateTotals(cartResp.totals);
        _updateAddresses(cartResp);
        calculateDelhiveryShippingCharge();
      }
    } catch (e) {
      CustomToast.show('Failed to add item to cart', isError: true);
    }
  }

  // Update item quantity in WooCommerce cart
  Future<void> updateQuantity(String productId, int delta) async {
    final item =
        cartItems.firstWhereOrNull((item) => item.product.id == productId);
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
                weightKg: itemModel.weightKg,
                lengthCm: itemModel.lengthCm,
                widthCm: itemModel.widthCm,
                heightCm: itemModel.heightCm,
              );
            }).toList();
            cartItems.assignAll(items);
             _updateTotals(cartResp.totals);
             calculateDelhiveryShippingCharge();
          }
        } catch (e) {
          CustomToast.show('Failed to update quantity', isError: true);
        }
      }
    }
  }

  // Remove an item from the WooCommerce cart
  Future<void> removeItem(String productId) async {
    final item =
        cartItems.firstWhereOrNull((item) => item.product.id == productId);
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
              weightKg: itemModel.weightKg,
              lengthCm: itemModel.lengthCm,
              widthCm: itemModel.widthCm,
              heightCm: itemModel.heightCm,
            );
          }).toList();
          cartItems.assignAll(items);
           _updateTotals(cartResp.totals);
           calculateDelhiveryShippingCharge();
        }
      } catch (e) {
        CustomToast.show('Failed to remove item', isError: true);
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

  int _getEstimatedWeightInGrams(String productName, String category) {
    final name = productName.toLowerCase();
    final cat = category.toLowerCase();

    if (name.contains('dining') || name.contains('table') || cat.contains('table')) {
      return 45000; // 45 kg
    } else if (name.contains('sofa') || name.contains('couch') || cat.contains('sofa')) {
      return 50000; // 50 kg
    } else if (name.contains('chair') || name.contains('stool') || name.contains('bench') || cat.contains('chair')) {
      return 12000; // 12 kg
    } else if (name.contains('bed') || cat.contains('bed')) {
      return 75000; // 75 kg
    } else if (name.contains('wardrobe') || name.contains('cabinet') || name.contains('almirah') || cat.contains('wardrobe')) {
      return 80000; // 80 kg
    } else if (name.contains('mirror') || name.contains('shelf') || cat.contains('decor')) {
      return 15000; // 15 kg
    }
    return 25000; // Default 25 kg
  }

  Future<void> calculateDelhiveryShippingCharge() async {
    final addr = shippingAddress.value;
    if (addr == null || addr.postcode.isEmpty) {
      return;
    }

    final String pincode = addr.postcode.trim();
    if (pincode.length != 6 || int.tryParse(pincode) == null) {
      return;
    }

    // Calculate total weight of cart items using extension fields or fallback heuristics
    int totalWeightGrams = 0;
    for (final item in cartItems) {
      int itemWeightGrams = 0;
      
      // Use dynamic weight and dimensions if available from WooCommerce extension
      if (item.weightKg != null && item.weightKg! > 0) {
        final double deadWeight = item.weightKg! * 1000;
        double volumetricWeight = 0;
        if (item.lengthCm != null && item.widthCm != null && item.heightCm != null) {
          volumetricWeight = (item.lengthCm! * item.widthCm! * item.heightCm!) * 0.2;
        }
        itemWeightGrams = (deadWeight > volumetricWeight ? deadWeight : volumetricWeight).toInt();
      } else {
        // Fallback to estimated weight heuristics
        itemWeightGrams = _getEstimatedWeightInGrams(
          item.product.name,
          item.product.category,
        );
      }

      totalWeightGrams += itemWeightGrams * item.quantity.value;
    }

    if (totalWeightGrams <= 0) {
      totalWeightGrams = 10000; // Default to 10kg minimum
    }

    try {
      isCalculatingDelivery.value = true;
      final response = await _deliveryRepository.getShippingCharges(
        destinationPin: pincode,
        weightInGrams: totalWeightGrams,
      );

      if (response != null && response is List && response.isNotEmpty) {
        final chargeData = response.first;
        if (chargeData != null && chargeData['total_amount'] != null) {
          final double amt = double.tryParse(chargeData['total_amount'].toString()) ?? 0.0;
          
          double oldShipping = deliveryPriceValue.value;
          deliveryPriceValue.value = amt;
          totalAmountValue.value = totalAmountValue.value - oldShipping + amt;
          return;
        }
      }
    } catch (e) {
      // Silent catch
    } finally {
      isCalculatingDelivery.value = false;
    }
  }
}
