import 'package:iron_street_app/app/data/network/network_api_service.dart';

class DeliveryRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> checkPincodeServiceability(String pincode) async {
    const String url = 'https://track.delhivery.com/c/api/pin-codes/json/';
    final Map<String, dynamic> headers = {
      'Authorization': '9acb3b25fe6f9fbdd3781041828fd48cc09ea77c',
      'Content-Type': 'application/json',
    };
    final Map<String, dynamic> queryParameters = {
      'filter_codes': pincode,
    };

    try {
      final response = await _apiService.getApi(
        url,
        queryParameters: queryParameters,
        headers: headers,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
