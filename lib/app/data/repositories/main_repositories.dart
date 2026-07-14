import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/models/product_tag_model.dart';
import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class MainRepositories {
  final NetworkApiServices _apiService = NetworkApiServices();

  // Product list field
  final fields = [
    'id',
    'name',
    'price',
    'regular_price',
    'sale_price',
    'on_sale',
    'average_rating',
    'rating_count',
    'images',
    'attributes',
  ].join(',');

  Future<dynamic> fetchCategories({
    int page = 1,
    int perPage = 100,
  }) async {
    final String url = '${AppUrls.categories}'
        '?page=$page'
        '&per_page=$perPage'
        '&hide_empty=true'
        '&_fields=id,name,slug,parent,image,count'
        '&orderby=count'
        '&order=desc';

    try {
      final response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchProductsByCategory({
    required int categoryId,
    int page = 1,
    int perPage = 10,
  }) async {
    final fields = [
      'id',
      'name',
      'price',
      'regular_price',
      'sale_price',
      'on_sale',
      'average_rating',
      'rating_count',
      'images',
      'attributes',
    ].join(',');

    final String url = categoryId == 0
        ? '${AppUrls.products}?per_page=$perPage&page=$page&_fields=$fields'
        : '${AppUrls.products}?category=$categoryId&per_page=$perPage&page=$page&_fields=$fields';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchProducts({
    required int categoryId,
    int page = 1,
    int perPage = 10,
  }) async {
    final String url =
        '${AppUrls.baseUrl}/products?category=$categoryId&per_page=$perPage&page=$page&_fields=$fields';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchProductDetail({required int productId}) async {
    final fields = [
      'id',
      'name',
      'slug',
      'permalink',
      'description',
      'short_description',
      'sku',
      'price',
      'regular_price',
      'sale_price',
      'on_sale',
      'purchasable',
      'stock_status',
      'average_rating',
      'rating_count',
      'images',
      'attributes',
      'categories',
      'related_ids',
    ].join(',');

    final String url = '${AppUrls.products}/$productId?_fields=$fields';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchProductReviews({
    required int productId,
    int page = 1,
    int perPage = 20,
  }) async {
    final fields = [
      'id',
      'product_id',
      'product_name',
      'reviewer',
      'review',
      'rating',
      'date_created',
      'verified',
      'reviewer_avatar_urls',
    ].join(',');

    final String url = '${AppUrls.baseUrl}/products/reviews'
        '?product=$productId'
        '&page=$page'
        '&per_page=$perPage'
        '&_fields=$fields';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchRelatedProductsByIds({
    required List<int> productIds,
  }) async {
    if (productIds.isEmpty) {
      return [];
    }

    final String ids = productIds.join(',');

    final String url =
        '${AppUrls.products}?include=$ids&per_page=${productIds.length}&_fields=$fields&orderby=include';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ProductTagModel>> getProductTags() async {
    try {
      final response = await _apiService.getApi(
        AppUrls.tags,
        queryParameters: {
          'per_page': 100,
          'hide_empty': true,
          '_fields': 'id,name,slug,description,count',
          'orderby': 'count',
          'order': 'desc',
        },
      );
      final List data = response;
      return data.map((json) => ProductTagModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch product tags: $e');
    }
  }

  Future<List<ProductListModel>> getProductsByTag({
    required int tagId,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiService.getApi(
          '${AppUrls.products}/?tag=$tagId&per_page=$perPage&_fields=$fields');

      final List data = response;

      return data.map((json) => ProductListModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by tag: $e');
    }
  }

  Future<List<ProductListModel>> searchProducts({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query.trim());

      final String url = '${AppUrls.products}'
          '?search=$encodedQuery'
          '&search_fields=name,sku'
          '&page=$page'
          '&per_page=$perPage'
          '&_fields=id,name,price,regular_price,sale_price,on_sale,'
          'average_rating,rating_count,short_description,images,categories,tags';

      final response = await _apiService.getApi(url);

      // Your API service already returns decoded List
      final List data = response;

      return data.map((json) => ProductListModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  Future<dynamic> getCart() async {
    try {
      final response = await _apiService.getApi(AppUrls.cartUrl);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> addToCart({required int productId, int quantity = 1}) async {
    try {
      final response = await _apiService.postApi(
        AppUrls.cartAddItem,
        data: {
          'id': productId,
          'quantity': quantity,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateCartItem({required String key, required int quantity}) async {
    try {
      final response = await _apiService.postApi(
        AppUrls.cartUpdateItem,
        data: {
          'key': key,
          'quantity': quantity,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  

  Future<dynamic> removeCartItem({required String key}) async {
    try {
      final response = await _apiService.postApi(
        AppUrls.cartRemoveItem,
        data: {
          'key': key,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateCustomerAddress({
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
  }) async {
    try {
      final response = await _apiService.postApi(
        AppUrls.updateCustomer,
        data: {
          'shipping_address': shippingAddress,
          'billing_address': billingAddress,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchWishlist() async {
    try {
      final response = await _apiService.getApi(AppUrls.getWishlist);
      final int wishlistId = response['wishlist_id'] ?? 0;
      final List<dynamic> itemsJson = response['items'] ?? [];
      final List<ProductListModel> items = itemsJson
          .map((item) => ProductListModel.fromWishlistJson(item))
          .toList();
      return {
        'wishlist_id': wishlistId,
        'items': items,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToWishlist({required int productId, required int wishlistId}) async {
    try {
      final response = await _apiService.postApi(
        AppUrls.mutateWishlist,
        data: {
          'product_id': productId,
          'wishlist_id': wishlistId,
          'quantity': 1,
        },
      );
      if (response != null && response['product_data'] != null) {
        return response['product_data']['isAdded'] ?? false;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeFromWishlist({required int productId, required int wishlistId}) async {
    try {
      final response = await _apiService.deleteApi(
        AppUrls.mutateWishlist,
        {
          'product_id': productId,
          'wishlist_id': wishlistId,
        },
      );
      if (response != null && response['product_data'] != null) {
        return !(response['product_data']['isAdded'] ?? true);
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches orders for a specific customer, optimized to only retrieve fields used in the list view.
  Future<dynamic> fetchOrders({
    required int customerId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final String url = '${AppUrls.orders}'
          '?customer=$customerId'
          '&page=$page'
          '&per_page=$perPage'
          '&_fields=id,number,status,date_created,total,line_items';
      final response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a specific order detail by order ID, optimized to only retrieve fields used in the detail view.
  Future<dynamic> fetchOrderDetail({required int orderId}) async {
    try {
      final String url = '${AppUrls.orders}/$orderId'
          '?_fields=id,number,status,date_created,total,shipping_total,discount_total,shipping,billing,payment_method,payment_method_title,transaction_id,line_items';
      final response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves the current checkout draft via the WooCommerce Store API
  Future<dynamic> getCheckoutDraft() async {
    try {
      const String url = '${AppUrls.storeApiUrl}/checkout';
      final response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Initiates the order checkout via the WooCommerce Store API
  Future<dynamic> placeOrderStoreApi({
    required String paymentMethod,
  }) async {
    try {
      const String url = '${AppUrls.storeApiUrl}/checkout';
      final response = await _apiService.postApi(
        url,
        queryParameters: {
          'billing_address': 'Yes',
          'payment_method': paymentMethod,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
