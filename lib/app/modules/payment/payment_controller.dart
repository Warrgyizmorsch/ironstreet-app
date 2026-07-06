import 'package:get/get.dart';
import '../cart/cart_controller.dart';
import '../checkout/checkout_controller.dart';
import '../orders/orders_controller.dart';
import '../../data/models/order_model.dart';
import '../../data/models/payment_method_model.dart';
import 'payment_success_view.dart';
import 'payment_failed_view.dart';

class PaymentController extends GetxController {
  final cartCtrl = Get.find<CartController>();
  final checkCtrl = Get.find<CheckoutController>();
  final ordCtrl = Get.find<OrdersController>();

  var paymentMethods = <PaymentMethodModel>[].obs;
  var selectedMethodId = ''.obs;
  var isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPaymentMethods();
  }

  void _loadPaymentMethods() {
    paymentMethods.assignAll([
      PaymentMethodModel(
        id: 'pay_upi',
        name: 'UPI (Google Pay / PhonePe)',
        type: PaymentType.upi,
        details: 'ananya@oksbi',
        icon: 'upi',
      ),
      PaymentMethodModel(
        id: 'pay_card',
        name: 'Credit / Debit Card',
        type: PaymentType.card,
        details: 'Visa ending in 4122',
        icon: 'card',
      ),
      PaymentMethodModel(
        id: 'pay_net',
        name: 'Net Banking',
        type: PaymentType.netBanking,
        details: 'State Bank of India',
        icon: 'bank',
      ),
      PaymentMethodModel(
        id: 'pay_cod',
        name: 'Cash on Delivery',
        type: PaymentType.cod,
        details: 'Pay cash/UPI upon delivery',
        icon: 'cod',
      ),
    ]);

    // Select the first one by default
    if (paymentMethods.isNotEmpty) {
      selectedMethodId.value = paymentMethods[0].id;
    }
  }

  void selectMethod(String id) {
    selectedMethodId.value = id;
  }

  PaymentMethodModel? get selectedMethod {
    return paymentMethods.firstWhereOrNull((m) => m.id == selectedMethodId.value);
  }

  Future<void> processPayment({bool simulateFailure = false}) async {
    final method = selectedMethod;
    if (method == null) {
      Get.snackbar('Error', 'Please select a payment method.');
      return;
    }

    isProcessing.value = true;

    // Simulate 2 seconds network lag for payment processing
    await Future.delayed(const Duration(seconds: 2));

    isProcessing.value = false;

    if (simulateFailure) {
      Get.to(() => const PaymentFailedView());
      return;
    }

    // Success flow
    final orderNum = 'IS-${1000 + DateTime.now().second * 97}-ORDER';
    final orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    final shipping = checkCtrl.selectedAddress.value!;
    
    final orderItems = cartCtrl.cartItems.map((cartItem) {
      return OrderItemModel(
        product: cartItem.product,
        quantity: cartItem.quantity.value,
        price: cartItem.product.price,
      );
    }).toList();

    final subtotal = cartCtrl.subtotal;
    final discount = cartCtrl.discountAmount + checkCtrl.couponDiscount.value;
    final delivery = cartCtrl.deliveryPrice;
    final grandTotal = checkCtrl.checkoutTotal;

    final newOrder = OrderModel(
      id: orderId,
      orderNumber: orderNum,
      items: orderItems,
      shippingAddress: shipping,
      paymentMethod: method.name,
      paymentDetails: method.details,
      orderDate: DateTime.now(),
      status: 'Processing',
      subtotal: subtotal,
      discount: discount,
      deliveryCharges: delivery,
      totalAmount: grandTotal,
    );

    // Place the order
    ordCtrl.placeOrder(newOrder);

    // Clear the shopping cart
    cartCtrl.clearCart();
    
    // Clear coupons in checkout
    checkCtrl.removeCoupon();

    // Navigate to Success View
    Get.to(() => PaymentSuccessView(orderNumber: orderNum, orderId: orderId));
  }
}
