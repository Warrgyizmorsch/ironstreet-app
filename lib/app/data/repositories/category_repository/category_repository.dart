import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class CategoryRepository {
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
}
