
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
}
