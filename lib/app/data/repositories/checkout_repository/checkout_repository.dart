import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class CheckoutRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

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
