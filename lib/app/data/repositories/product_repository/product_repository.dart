import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/models/product_tag_model.dart';
import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class ProductRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  // Product list fields
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
      'weight',
      'dimensions',
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

  Future<dynamic> submitProductReview({
    required int productId,
    required String reviewer,
    required String email,
    required String review,
    required int rating,
  }) async {
    const String url = '${AppUrls.baseUrl}/products/reviews';
    final Map<String, dynamic> data = {
      'product_id': productId,
      'reviewer': reviewer,
      'reviewer_email': email,
      'review': review,
      'rating': rating,
    };

    try {
      dynamic response = await _apiService.postApi(url, data: data);
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

      final List data = response;

      return data.map((json) => ProductListModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}
