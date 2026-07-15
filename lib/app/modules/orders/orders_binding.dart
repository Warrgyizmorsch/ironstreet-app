import 'package:get/get.dart';
import 'package:iron_street_app/app/data/repositories/order_repository/order_repository.dart';
import 'orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderRepository>(() => OrderRepository());
    Get.lazyPut<OrdersController>(
      () => OrdersController(),
    );
  }
}
