import 'package:get/get.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/repositories/checkout_repository/checkout_repository.dart';
import '../../data/repositories/order_repository/order_repository.dart';
import '../cart/cart_controller.dart';
import '../../data/models/cart_response_model.dart';
import '../payment/payment_success_view.dart';
import '../payment/payment_failed_view.dart';
import '../../data/repositories/delivery_repository/delivery_repository.dart';

class CheckoutController extends GetxController {
  final cartCtrl = Get.find<CartController>();
  final CheckoutRepository checkoutRepository = Get.find<CheckoutRepository>();
  final OrderRepository orderRepository = Get.find<OrderRepository>();
  final DeliveryRepository _deliveryRepository = DeliveryRepository();

  var appliedCoupon = ''.obs;
  var couponDiscount = 0.0.obs;
  var isProcessing = false.obs;

  var deliveryCharge = 0.0.obs;
  var isCalculatingDelivery = false.obs;

  late Razorpay _razorpay;
  int? _activeOrderId;
  String? _activeOrderNumber;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Re-calculate shipping dynamically when address postcode changes
    ever(cartCtrl.shippingAddress, (_) {
      calculateDelhiveryShippingCharge();
    });

    // Reactively sync coupon status from CartController to keep UI in perfect sync
    ever(cartCtrl.appliedCoupons, (List<CartCouponModel> coupons) {
      if (coupons.isNotEmpty) {
        appliedCoupon.value = coupons.first.code;
        couponDiscount.value = coupons.first.discountAmount;
      } else {
        appliedCoupon.value = '';
        couponDiscount.value = 0.0;
      }
    });

    // Run initial check for already applied coupons
    if (cartCtrl.appliedCoupons.isNotEmpty) {
      appliedCoupon.value = cartCtrl.appliedCoupons.first.code;
      couponDiscount.value = cartCtrl.appliedCoupons.first.discountAmount;
    }

    // Run initial calculation
    calculateDelhiveryShippingCharge();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_activeOrderId == null) return;

    try {
      // 1. Mark order as paid in WooCommerce via PUT /orders/<id>
      await orderRepository.updateOrder(
        orderId: _activeOrderId!,
        data: {
          'status': 'processing',
          'transaction_id': response.paymentId ?? '',
          'set_paid': true,
        },
      );

      // 2. Clear local cart
      cartCtrl.clearCart();

      // 3. Clear checkout coupon
      removeCoupon();

      isProcessing.value = false;

      // 4. Navigate to success page
      Get.off(() => PaymentSuccessView(
            orderNumber: _activeOrderNumber ?? '',
            orderId: _activeOrderId!.toString(),
          ));
    } catch (e) {
      isProcessing.value = false;
      CustomToast.show(
        'Payment was successful (ID: ${response.paymentId}), but we failed to update the order. Please contact support. Error: $e',
        isError: true,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isProcessing.value = false;

    // Check if the user cancelled the payment
    if (response.code == Razorpay.PAYMENT_CANCELLED || response.code == 2) {
      CustomToast.show(
        'You cancelled the payment process.',
      );
      return;
    }

    // Go to failed screen
    Get.to(() => const PaymentFailedView());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isProcessing.value = false;
  }

  Future<bool> applyCoupon(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    final success = await cartCtrl.applyCouponCode(cleanCode);
    if (success) {
      appliedCoupon.value = cleanCode;
      final couponObj = cartCtrl.appliedCoupons.firstWhereOrNull(
        (c) => c.code.toUpperCase() == cleanCode,
      );
      if (couponObj != null) {
        couponDiscount.value = couponObj.discountAmount;
      } else {
        // If not explicitly found in coupons list, fallback to cart total discount
        couponDiscount.value = cartCtrl.discountAmount;
      }
      CustomToast.show(
        'Successfully applied coupon: $cleanCode',
        isSuccess: true,
      );
      return true;
    }
    return false;
  }

  Future<void> removeCoupon() async {
    final code = appliedCoupon.value;
    if (code.isEmpty) return;

    final success = await cartCtrl.removeCouponCode(code);
    if (success) {
      appliedCoupon.value = '';
      couponDiscount.value = 0.0;
      CustomToast.show(
        'Coupon discount was removed.',
        isSuccess: true,
      );
    }
  }

  double get checkoutTotal {
    // Override WooCommerce's static shipping cost (cartCtrl.deliveryPrice)
    // and inject Delhivery's dynamic live shipping cost (deliveryCharge.value)
    double base = cartCtrl.totalAmount - cartCtrl.deliveryPrice;
    double total = base + deliveryCharge.value - couponDiscount.value;
    return total < 0 ? 0.0 : total;
  }

  Future<void> proceedToPayment() async {
    final addr = cartCtrl.shippingAddress.value;
    if (addr == null || addr.address1.isEmpty) {
      CustomToast.show(
        'Please select or add a shipping address to proceed.',
      );
      return;
    }
    if (cartCtrl.cartItems.isEmpty) {
      CustomToast.show(
        'Your cart is empty. Please add items to checkout.',
      );
      return;
    }

    try {
      isProcessing.value = true;

      // 1. Call standard WooCommerce Store API GET Checkout to create/sync the checkout-draft
      await checkoutRepository.getCheckoutDraft();

      // 2. Call standard WooCommerce Store API POST Checkout to finalize order & payment redirection
      final response = await checkoutRepository.placeOrderStoreApi(
        paymentMethod: 'razorpay',
      );

      // Extract values from response
      final orderIdStr = response['order_id']?.toString() ?? '';
      final orderNumber = response['order_number']?.toString() ?? orderIdStr;

      final orderId = int.tryParse(orderIdStr);
      if (orderId == null) {
        isProcessing.value = false;
        CustomToast.show(
          'Failed to retrieve valid order ID from checkout.',
          isError: true,
        );
        return;
      }

      _activeOrderId = orderId;
      _activeOrderNumber = orderNumber;

      // 3. Trigger native Razorpay payment sheet
      final double totalAmountInPaise = checkoutTotal * 100;

      final options = {
        // 'key': 'rzp_live_S9b3ahb0GRXV0w',
        'key': AppUrls.razorPayKey,
        'amount': totalAmountInPaise.toInt(),
        'name': 'Iron Street',
        'description': 'Order #$orderNumber',
        'timeout': 300, // in seconds
        'prefill': {
          'contact': addr.phone.isNotEmpty ? addr.phone : '',
          'email': cartCtrl.billingAddress.value?.email ?? '',
          'name': '${addr.firstName} ${addr.lastName}'.trim(),
        }
      };

      _razorpay.open(options);
    } catch (e) {
      isProcessing.value = false;
      CustomToast.show(
        e.toString().replaceAll('Exception:', '').trim(),
        isError: true,
      );
    }
  }

  int _getEstimatedWeightInGrams(String productName, String category) {
    final name = productName.toLowerCase();
    final cat = category.toLowerCase();

    if (name.contains('dining') ||
        name.contains('table') ||
        cat.contains('table')) {
      return 45000; // 45 kg
    } else if (name.contains('sofa') ||
        name.contains('couch') ||
        cat.contains('sofa')) {
      return 50000; // 50 kg
    } else if (name.contains('chair') ||
        name.contains('stool') ||
        name.contains('bench') ||
        cat.contains('chair')) {
      return 12000; // 12 kg
    } else if (name.contains('bed') || cat.contains('bed')) {
      return 75000; // 75 kg
    } else if (name.contains('wardrobe') ||
        name.contains('cabinet') ||
        name.contains('almirah') ||
        cat.contains('wardrobe')) {
      return 80000; // 80 kg
    } else if (name.contains('mirror') ||
        name.contains('shelf') ||
        cat.contains('decor')) {
      return 15000; // 15 kg
    }
    return 25000; // Default 25 kg
  }

  Future<void> calculateDelhiveryShippingCharge() async {
    final addr = cartCtrl.shippingAddress.value;
    if (addr == null || addr.postcode.isEmpty) {
      deliveryCharge.value = 0.0;
      return;
    }

    final String pincode = addr.postcode.trim();
    if (pincode.length != 6 || int.tryParse(pincode) == null) {
      deliveryCharge.value = 0.0;
      return;
    }

    // Calculate total weight of cart items
    int totalWeightGrams = 0;
    for (final item in cartCtrl.cartItems) {
      int itemWeightGrams = 0;

      // Use dynamic weight and dimensions if available from WooCommerce extension
      if (item.weightKg != null && item.weightKg! > 0) {
        final double deadWeight = item.weightKg! * 1000;
        double volumetricWeight = 0;
        if (item.lengthCm != null &&
            item.widthCm != null &&
            item.heightCm != null) {
          volumetricWeight =
              (item.lengthCm! * item.widthCm! * item.heightCm!) * 0.2;
        }
        itemWeightGrams =
            (deadWeight > volumetricWeight ? deadWeight : volumetricWeight)
                .toInt();
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
          final double amt =
              double.tryParse(chargeData['total_amount'].toString()) ?? 0.0;
          deliveryCharge.value = amt;
          return;
        }
      }
      deliveryCharge.value = 0.0;
    } catch (e) {
      deliveryCharge.value = 0.0;
    } finally {
      isCalculatingDelivery.value = false;
    }
  }
}
