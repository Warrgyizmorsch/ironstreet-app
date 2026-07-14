import 'package:get/get.dart';
import '../../data/repositories/main_repositories.dart';
import '../cart/cart_controller.dart';
import 'checkout_webview.dart';

class CheckoutController extends GetxController {
  final cartCtrl = Get.find<CartController>();
  final MainRepositories repositories = Get.isRegistered<MainRepositories>()
      ? Get.find<MainRepositories>()
      : Get.put(MainRepositories());

  var appliedCoupon = ''.obs;
  var couponDiscount = 0.0.obs;
  var isProcessing = false.obs;

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

      // 1. Call standard WooCommerce Store API Checkout endpoint to create the order
      final response = await repositories.placeOrderStoreApi(
        paymentMethod: 'razorpay',
      );

      isProcessing.value = false;

      // 2. Extract values from response
      final paymentResult = response['payment_result'];
      final redirectUrl = paymentResult != null ? paymentResult['redirect_url'] as String? : null;
      final orderId = response['order_id']?.toString() ?? '';
      final orderNumber = response['order_number']?.toString() ?? orderId;

      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        // 3. Open WebView to complete the payment
        Get.to(() => CheckoutWebView(
              url: redirectUrl,
              orderId: orderId,
              orderNumber: orderNumber,
            ));
      } else {
        Get.snackbar(
          'Error',
          'Failed to obtain payment redirect URL. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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
