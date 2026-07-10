// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/category/category_binding.dart';
import '../modules/category/category_product_view.dart';
import '../modules/product_detail/product_detail_binding.dart';
import '../modules/product_detail/product_detail_view.dart';
import '../modules/product_detail/product_reviews_view.dart';
import '../modules/wishlist/wishlist_binding.dart';
import '../modules/wishlist/wishlist_view.dart';
import '../modules/cart/cart_binding.dart';
import '../modules/cart/cart_view.dart';
import '../modules/account/account_binding.dart';
import '../modules/account/account_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/orders/orders_binding.dart';
import '../modules/orders/orders_view.dart';
import '../modules/orders/order_detail_view.dart';
import '../modules/address/address_binding.dart';
import '../modules/address/address_list_view.dart';
import '../modules/address/add_edit_address_view.dart';
import '../modules/checkout/checkout_binding.dart';
import '../modules/checkout/checkout_view.dart';
import '../modules/payment/payment_binding.dart';
import '../modules/payment/payment_view.dart';
import '../modules/payment/payment_success_view.dart';
import '../modules/payment/payment_failed_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.CATEGORY,
      page: () => const CategoryProductView(),
      binding: CategoryBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAIL,
      page: () => const ProductDetailView(),
      binding: ProductDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.WISHLIST,
      page: () => const WishlistView(),
      binding: WishlistBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: _Paths.ACCOUNT,
      page: () => const AccountView(),
      binding: AccountBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => const OrdersView(),
      binding: OrdersBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.ORDER_DETAIL,
      page: () => OrderDetailView(orderId: Get.arguments ?? ''),
      binding: OrdersBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.ADDRESS_LIST,
      page: () => const AddressListView(),
      binding: AddressBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.ADD_EDIT_ADDRESS,
      page: () => AddEditAddressView(address: Get.arguments),
      binding: AddressBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      bindings: [CheckoutBinding(), AddressBinding(), OrdersBinding()],
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.PAYMENT,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.PAYMENT_SUCCESS,
      page: () => PaymentSuccessView(
        orderNumber: Get.arguments?['orderNumber'] ?? '',
        orderId: Get.arguments?['orderId'] ?? '',
      ),
      transition: Transition.zoom,
    ),
    GetPage(
      name: _Paths.PAYMENT_FAILED,
      page: () => const PaymentFailedView(),
      transition: Transition.zoom,
    ),
    GetPage(
      name: _Paths.PRODUCT_REVIEWS,
      page: () => const ProductReviewsView(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
