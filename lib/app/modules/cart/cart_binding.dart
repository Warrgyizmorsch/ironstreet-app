
import 'package:get/get.dart';
import 'cart_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CartController>()) {
      Get.put(CartController(), permanent: true);
    }
  }
}
