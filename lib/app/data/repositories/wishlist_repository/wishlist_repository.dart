import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class WishlistRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

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
}
