import 'package:get/get.dart';
import 'package:iron_street_app/app/data/repositories/checkout_repository/checkout_repository.dart';
import 'package:iron_street_app/app/data/repositories/order_repository/order_repository.dart';
import 'checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CheckoutRepository>(() => CheckoutRepository());
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
