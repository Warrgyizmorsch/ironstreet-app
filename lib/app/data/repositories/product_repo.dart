

import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class ProductRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  // Fetch products by page
  Future<dynamic> fetchProducts({required int page, int perPage = 10}) async {
    final String url = '${AppUrls.baseUrl}/products?page=$page&per_page=$perPage';
    
    try {
      dynamic response = await _apiService.getApi(url);
      return response; 
    } catch (e) {
      rethrow;
    }
  }
}