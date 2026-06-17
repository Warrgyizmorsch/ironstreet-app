import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class MainRepositories {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> fetchCategories({int page = 1, int perPage = 100}) async {
    final String url =
        '${AppUrls.baseUrl}/products/categories?page=$page&per_page=$perPage';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch products by page
  Future<dynamic> fetchProducts({required int page, int perPage = 10}) async {
    final String url =
        '${AppUrls.baseUrl}/products?page=$page&per_page=$perPage';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
