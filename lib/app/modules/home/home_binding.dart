import 'package:get/get.dart';
import 'package:iron_street_app/app/data/repositories/main_repositories.dart';
import 'home_controller.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainRepositories>(() => MainRepositories());
    Get.lazyPut<HomeController>(
        () => HomeController(repositories: Get.find<MainRepositories>()));
    Get.put(CartController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
  }
}
