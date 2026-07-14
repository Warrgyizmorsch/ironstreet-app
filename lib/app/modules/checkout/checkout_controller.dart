import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/repositories/main_repositories.dart';
import '../cart/cart_controller.dart';
import '../payment/payment_success_view.dart';
import '../payment/payment_failed_view.dart';

class CheckoutController extends GetxController {
  final cartCtrl = Get.find<CartController>();
  final MainRepositories repositories = Get.isRegistered<MainRepositories>()
      ? Get.find<MainRepositories>()
      : Get.put(MainRepositories());

  var appliedCoupon = ''.obs;
  var couponDiscount = 0.0.obs;
  var isProcessing = false.obs;

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
      await repositories.updateOrder(
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
      Get.snackbar(
        'Payment Completion Error',
        'Payment was successful (ID: ${response.paymentId}), but we failed to update the order. Please contact support. Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 8),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isProcessing.value = false;

    // Check if the user cancelled the payment
    if (response.code == Razorpay.PAYMENT_CANCELLED || response.code == 2) {
      Get.snackbar(
        'Payment Cancelled',
        'You cancelled the payment process.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Go to failed screen
    Get.to(() => const PaymentFailedView());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isProcessing.value = false;
  }

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'GOLDSTREET' || cleanCode == 'IRONSTREET') {
      appliedCoupon.value = cleanCode;
      // 10% additional discount on the cart subtotal
      couponDiscount.value = cartCtrl.subtotal * 0.10;
      Get.snackbar(
        'Coupon Applied',
        'Successfully applied coupon: $cleanCode (10% Off)',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } else {
      Get.snackbar(
        'Invalid Coupon',
        'The entered code is not valid or expired.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  void removeCoupon() {
    appliedCoupon.value = '';
    couponDiscount.value = 0.0;
    Get.snackbar(
      'Coupon Removed',
      'Coupon discount was removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  double get checkoutTotal {
    double total = cartCtrl.totalAmount - couponDiscount.value;
    return total < 0 ? 0.0 : total;
  }

  Future<void> proceedToPayment() async {
    final addr = cartCtrl.shippingAddress.value;
    if (addr == null || addr.address1.isEmpty) {
      Get.snackbar(
        'Address Required',
        'Please select or add a shipping address to proceed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (cartCtrl.cartItems.isEmpty) {
      Get.snackbar(
        'Empty Cart',
        'Your cart is empty. Please add items to checkout.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isProcessing.value = true;

      // 1. Call standard WooCommerce Store API GET Checkout to create/sync the checkout-draft
      await repositories.getCheckoutDraft();

      // 2. Call standard WooCommerce Store API POST Checkout to finalize order & payment redirection
      final response = await repositories.placeOrderStoreApi(
        paymentMethod: 'razorpay',
      );

      // Extract values from response
      final orderIdStr = response['order_id']?.toString() ?? '';
      final orderNumber = response['order_number']?.toString() ?? orderIdStr;

      final orderId = int.tryParse(orderIdStr);
      if (orderId == null) {
        isProcessing.value = false;
        Get.snackbar(
          'Error',
          'Failed to retrieve valid order ID from checkout.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _activeOrderId = orderId;
      _activeOrderNumber = orderNumber;

      // 3. Trigger native Razorpay payment sheet
      final double totalAmountInPaise = checkoutTotal * 100;

      final options = {
        'key': 'rzp_test_TCubW9gX0V2fux',
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
      Get.snackbar(
        'Checkout Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
