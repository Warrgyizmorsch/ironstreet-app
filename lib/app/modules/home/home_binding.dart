import 'package:get/get.dart';
import 'home_controller.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import '../profile/profile_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
        () => HomeController());
    Get.put(CartController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}
