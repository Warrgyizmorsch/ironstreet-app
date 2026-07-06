
// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const CATEGORY = _Paths.CATEGORY;
  static const PRODUCT_DETAIL = _Paths.PRODUCT_DETAIL;
  static const WISHLIST = _Paths.WISHLIST;
  static const CART = _Paths.CART;
  static const ACCOUNT = _Paths.ACCOUNT;
  static const STORES = _Paths.STORES;
  static const CALLBACK = _Paths.CALLBACK;
  static const PROFILE = _Paths.PROFILE;
  static const ORDERS = _Paths.ORDERS;
  static const ORDER_DETAIL = _Paths.ORDER_DETAIL;
  static const ADDRESS_LIST = _Paths.ADDRESS_LIST;
  static const ADD_EDIT_ADDRESS = _Paths.ADD_EDIT_ADDRESS;
  static const CHECKOUT = _Paths.CHECKOUT;
  static const PAYMENT = _Paths.PAYMENT;
  static const PAYMENT_SUCCESS = _Paths.PAYMENT_SUCCESS;
  static const PAYMENT_FAILED = _Paths.PAYMENT_FAILED;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const CATEGORY = '/category';
  static const PRODUCT_DETAIL = '/product-detail';
  static const WISHLIST = '/wishlist';
  static const CART = '/cart';
  static const ACCOUNT = '/account';
  static const STORES = '/stores';
  static const CALLBACK = '/callback';
  static const PROFILE = '/profile';
  static const ORDERS = '/orders';
  static const ORDER_DETAIL = '/order-detail';
  static const ADDRESS_LIST = '/address-list';
  static const ADD_EDIT_ADDRESS = '/add-edit-address';
  static const CHECKOUT = '/checkout';
  static const PAYMENT = '/payment';
  static const PAYMENT_SUCCESS = '/payment-success';
  static const PAYMENT_FAILED = '/payment-failed';
}

