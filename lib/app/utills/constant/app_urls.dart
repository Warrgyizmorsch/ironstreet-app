import 'dart:convert';

class AppUrls {
  // WooCommerce Base URL
  static const String baseUrl = 'https://ironstreets.com/wp-json/wc/v3';

  // WooCommerce Consumer Key & Secret (Replace with your actual keys)
  static const String _consumerKey =
      'ck_33f319670ab8218b0145c499f741ed1d075d6041';
  static const String _consumerSecret =
      'cs_e9bbf1764d5097b1e535b2c900800ae69f160016';

  // Helper to generate the Basic Auth Header required by WooCommerce
  static String get basicAuthHeader {
    return 'Basic ${base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'))}';
  }

  // Endpoints
  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/products/categories';
  static const String orders = '$baseUrl/orders';
  static const String customers = '$baseUrl/customers';

  // YITH Wishlist endpoint (from previous setup)
  static const String wishlist =
      'https://ironstreets.com/wp-json/yith/wishlist/v1/products';
}
