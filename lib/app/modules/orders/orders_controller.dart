import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../data/models/address_model.dart';
import '../../data/dummy_data.dart';

class OrdersController extends GetxController {
  var orders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyOrders();
  }

  void _loadDummyOrders() {
    // Standard mock shipping address
    final mockAddress = AddressModel(
      id: 'addr_1',
      name: 'Ananya Sharma',
      phone: '+91 98765 43210',
      addressLine1: 'Flat 402, Sunshine Residency',
      addressLine2: '12th Main, 4th Sector, HSR Layout',
      city: 'Bengaluru',
      state: 'Karnataka',
      postalCode: '560102',
      country: 'India',
      addressType: 'Home',
      isDefault: true,
    );

    // Let's grab product references from our dummy_data.dart
    final p1 = discoverNewProducts.firstWhere((p) => p.id == 'p1');
    final p3 = discoverNewProducts.firstWhere((p) => p.id == 'p3');

    orders.assignAll([
      OrderModel(
        id: 'ord_recent_1',
        orderNumber: 'IS-7341-ORDER',
        items: [
          OrderItemModel(product: p1, quantity: 1, price: p1.price),
        ],
        shippingAddress: mockAddress,
        paymentMethod: 'UPI',
        paymentDetails: 'ananya@oksbi',
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Dispatched',
        subtotal: p1.price,
        discount: p1.oldPrice - p1.price,
        deliveryCharges: 0.0,
        totalAmount: p1.price,
      ),
      OrderModel(
        id: 'ord_past_1',
        orderNumber: 'IS-4911-ORDER',
        items: [
          OrderItemModel(product: p3, quantity: 1, price: p3.price),
        ],
        shippingAddress: mockAddress,
        paymentMethod: 'Credit Card',
        paymentDetails: 'xxxx-xxxx-xxxx-4122',
        orderDate: DateTime.now().subtract(const Duration(days: 20)),
        status: 'Delivered',
        subtotal: p3.price,
        discount: p3.oldPrice - p3.price,
        deliveryCharges: 499.0,
        totalAmount: p3.price + 499.0,
      ),
    ]);
  }

  void placeOrder(OrderModel newOrder) {
    orders.insert(0, newOrder);
  }

  OrderModel? findOrderById(String orderId) {
    return orders.firstWhereOrNull((o) => o.id == orderId);
  }
}
