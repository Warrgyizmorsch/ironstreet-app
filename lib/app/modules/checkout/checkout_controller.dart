import 'package:get/get.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/repositories/checkout_repository/checkout_repository.dart';
import '../../data/repositories/order_repository/order_repository.dart';
import '../cart/cart_controller.dart';
import '../payment/payment_success_view.dart';
import '../payment/payment_failed_view.dart';

class CheckoutController extends GetxController {
  final cartCtrl = Get.find<CartController>();
  final CheckoutRepository checkoutRepository = Get.find<CheckoutRepository>();
  final OrderRepository orderRepository = Get.find<OrderRepository>();

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

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'GOLD9842STREET' || cleanCode == 'IRON2153STREET') {
      appliedCoupon.value = cleanCode;
      // 10% additional discount on the cart subtotal
      // couponDiscount.value = cartCtrl.subtotal * 0.10;
      CustomToast.show(
        'Successfully applied coupon: $cleanCode (10% Off)',
      );
      return true;
    } else {
      CustomToast.show(
        'The entered code is not valid or expired.',
      );
      return false;
    }
  }

  void removeCoupon() {
    appliedCoupon.value = '';
    couponDiscount.value = 0.0;
    CustomToast.show(
      'Coupon discount was removed.',
    );
  }

  double get checkoutTotal {
    double total = cartCtrl.totalAmount - couponDiscount.value;
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
        'key': 'rzp_live_S9b3ahb0GRXV0w',
        // 'key': 'rzp_test_TCubW9gX0V2fux',
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
}
