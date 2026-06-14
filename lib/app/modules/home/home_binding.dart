/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:get/get.dart';
import 'home_controller.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.put(CartController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
  }
}
