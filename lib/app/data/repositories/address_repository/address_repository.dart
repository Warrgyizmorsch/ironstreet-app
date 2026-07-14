import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class AddressRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

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
}
