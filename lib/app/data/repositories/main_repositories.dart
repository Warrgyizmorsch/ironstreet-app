import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class MainRepositories {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> fetchCategories({int page = 1, int perPage = 100}) async {
    final String url = '${AppUrls.categories}?page=$page&per_page=$perPage';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchProductsByCategory(
      {required int categoryId, int page = 1, int perPage = 10}) async {
    final String url =
        '${AppUrls.products}?category=${categoryId == 0 ? '' : categoryId}&per_page=$perPage&page=$page';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Fetch products by page
  // Future<dynamic> fetchProducts({required int page, int perPage = 10}) async {
  //   final String url =
  //       '${AppUrls.baseUrl}/products?page=$page&per_page=$perPage';

  //   try {
  //     dynamic response = await _apiService.getApi(url);
  //     return response;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
  Future<dynamic> fetchProducts({
    required int categoryId,
    int page = 1,
    int perPage = 10,
  }) async {
    final String url =
        '${AppUrls.baseUrl}/products?category=$categoryId&per_page=$perPage&page=$page';

    try {
      dynamic response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchProductDetail({required int productId}) async {
  final String url = '${AppUrls.products}/$productId';

  try {
    dynamic response = await _apiService.getApi(url);
    return response;
  } catch (e) {
    rethrow;
  }
}

}
