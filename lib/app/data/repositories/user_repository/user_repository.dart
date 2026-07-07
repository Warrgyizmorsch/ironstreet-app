import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class UserRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  Future<dynamic> loginUser({
    required String username,
    required String password,
  }) async {
    final String baseUrlBase = AppUrls.baseUrl.replaceAll('/wc/v3', '');
    final String url = '$baseUrlBase/jwt-auth/v1/token';

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await _apiService.postApi(
        url,
        data: {
          'username': username,
          'password': password,
        },
        headers: headers,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> registerUser({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final String baseUrlBase = AppUrls.baseUrl.replaceAll('/wc/v3', '');
    final String url = '$baseUrlBase/custom/v1/register';

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await _apiService.postApi(
        url,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
        headers: headers,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
