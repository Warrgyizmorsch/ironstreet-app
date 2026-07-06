import 'package:get/get.dart';
import '../cart/cart_controller.dart';
import '../address/address_controller.dart';
import '../../data/models/address_model.dart';
import '../payment/payment_view.dart';

class CheckoutController extends GetxController {
  final cartCtrl = Get.find<CartController>();
  final addrCtrl = Get.find<AddressController>();

  var selectedAddress = Rxn<AddressModel>();
  var appliedCoupon = ''.obs;
  var couponDiscount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Default to the default address if any exists
    selectedAddress.value = addrCtrl.defaultAddress;
  }

  void updateSelectedAddress(AddressModel address) {
    selectedAddress.value = address;
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

  void proceedToPayment() {
    if (selectedAddress.value == null) {
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

    // Navigate to payment view
    Get.to(() => const PaymentView());
  }
}
