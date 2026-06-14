/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:get/get.dart';
import 'wishlist_controller.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    // If it is already Put globally,lazyPut won't override it.
    Get.lazyPut<WishlistController>(() => WishlistController());
  }
}
