import 'package:iron_street_app/app/data/models/user_model.dart';
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

  /// Fetches the authenticated user's WordPress profile.
  /// Endpoint: GET /wp/v2/users/me?context=edit&_fields=...
  /// Auth: Authorization: Bearer <jwt_token>
  Future<UserModel> fetchProfile({required String token}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _apiService.getApi(
        AppUrls.userProfile,
        headers: headers,
      );
      return UserModel.fromWpJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
  /// Updates the authenticated user's WordPress profile.
  /// Endpoint: POST /wp/v2/users/me?_fields=...
  /// Auth: Authorization: Bearer <jwt_token>
  /// Sends only the fields that are provided (name and/or email).
  Future<UserModel> updateProfile({
    required String token,
    String? name,
    String? email,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Build body with only changed fields
    final Map<String, dynamic> body = {};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (email != null && email.isNotEmpty) body['email'] = email;

    try {
      final response = await _apiService.postApi(
        AppUrls.userProfileUpdate,
        data: body,
        headers: headers,
      );
      return UserModel.fromWpJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
}
