import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class CartRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> getCart() async {
    try {
      final response = await _apiService.getApi('${AppUrls.cartUrl}?fresh=1');
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

  Future<dynamic> updateCartItem(
      {required String key, required int quantity}) async {
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
}
