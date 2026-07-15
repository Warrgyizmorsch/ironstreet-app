import 'package:get/get.dart';
import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/data/repositories/address_repository/address_repository.dart';
import 'package:iron_street_app/app/data/repositories/category_repository/category_repository.dart';
import 'package:iron_street_app/app/data/repositories/product_repository/product_repository.dart';
import 'package:iron_street_app/app/modules/cart/cart_controller.dart';
import 'package:iron_street_app/app/modules/wishlist/wishlist_controller.dart';
import 'package:iron_street_app/app/modules/profile/profile_controller.dart';
import 'package:iron_street_app/app/data/repositories/cart_repository/cart_repository.dart';
import 'package:iron_street_app/app/data/repositories/wishlist_repository/wishlist_repository.dart';
import 'package:iron_street_app/app/data/repositories/user_repository/user_repository.dart';
import 'package:iron_street_app/app/data/repositories/checkout_repository/checkout_repository.dart';
import 'package:iron_street_app/app/data/repositories/order_repository/order_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Services / Network helpers
    Get.lazyPut<NetworkApiServices>(() => NetworkApiServices(), fenix: true);

    // 2. Global Repositories
    Get.lazyPut<CartRepository>(() => CartRepository(), fenix: true);
    Get.lazyPut<WishlistRepository>(() => WishlistRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    Get.lazyPut<AddressRepository>(() => AddressRepository(), fenix: true);
    Get.lazyPut<CategoryRepository>(() => CategoryRepository(), fenix: true);
    Get.lazyPut<ProductRepository>(() => ProductRepository(), fenix: true);
    Get.lazyPut<CheckoutRepository>(() => CheckoutRepository(), fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);

    // 3. Global Controllers
    Get.put(CartController(), permanent: true);
    Get.put(WishlistController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}
