import 'dart:convert';

class AppUrls {
  // 1. Central Base Domains
  static const String domain = 'https://ironstreets.com';
  static const String wpJsonBase = '$domain/wp-json';

  // 2. WooCommerce Consumer Key & Secret
  static const String _consumerKey =
      'ck_33f319670ab8218b0145c499f741ed1d075d6041';
  static const String _consumerSecret =
      'cs_e9bbf1764d5097b1e535b2c900800ae69f160016';

  // Caches base64 encoded auth header once on load instead of recomputing per request
  static final String basicAuthHeader =
      'Basic ${base64Encode(utf8.encode("$_consumerKey:$_consumerSecret"))}';

  // 3. WooCommerce REST API (v3) Endpoints
  static const String wcV3Base = '$wpJsonBase/wc/v3';
  static const String baseUrl = wcV3Base; // Preserved for compatibility
  static const String products = '$wcV3Base/products';
  static const String categories = '$wcV3Base/products/categories';
  static const String orders = '$wcV3Base/orders';
  static const String customers = '$wcV3Base/customers';
  static const String tags = '$wcV3Base/products/tags';

  // 4. WooCommerce Store API (v1) Cart & Checkout Endpoints

  static const String storeApiUrl = '$wpJsonBase/wc/store/v1';
  static const String cartUrl = '$storeApiUrl/cart';
  static const String cartAddItem = '$cartUrl/add-item';
  static const String cartUpdateItem = '$cartUrl/update-item';
  static const String cartRemoveItem = '$cartUrl/remove-item';
  static const String updateCustomer = '$cartUrl/update-customer';

  // 5. YITH / Custom Wishlist Endpoints
  static const String wishlist = '$wpJsonBase/yith/wishlist/v1/products';
  static const String getWishlist =
      '$wpJsonBase/iron-app/v1/wishlist/items?fresh=1';
  static const String mutateWishlist = '$wpJsonBase/yith/wishlist/v1/items';

  // 6. WordPress REST API Endpoints (User Profile)
  static const String wpV2Base = '$wpJsonBase/wp/v2';
  static const String userProfile =
      '$wpV2Base/users/me?context=edit&_fields=id,name,first_name,last_name,email,registered_date,roles,url';
  static const String userProfileUpdate =
      '$wpV2Base/users/me?_fields=id,name,first_name,last_name,email,registered_date,roles,url';
}
