import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:iron_street_app/app/data/network/base_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';
import 'package:iron_street_app/app/data/exceptions/app_exceptions.dart';

class NetworkApiServices extends BaseApiServices {
  late final Dio _dio;

  NetworkApiServices() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': AppUrls.basicAuthHeader, // Your WooCommerce Auth
        },
      ),
    );

    // Optional: Add logging for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  @override
  Future<dynamic> getApi(String url) async {
    try {
      final response = await _dio.get(url);
      return returnResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<dynamic> postApi(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
      return returnResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<dynamic> putApi(String url, dynamic data) async {
    try {
      final response = await _dio.put(url, data: data);
      return returnResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<dynamic> patchApi(String url, dynamic data) async {
    try {
      final response = await _dio.patch(url, data: data);
      return returnResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<dynamic> deleteApi(String url, dynamic data) async {
    try {
      final response = await _dio.delete(url, data: data);
      return returnResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<dynamic> postFormData(String url, Map<String, dynamic> data) async {
    try {
      // Dio makes form data incredibly easy
      FormData formData = FormData.fromMap(data);

      final response = await _dio.post(url, data: formData);
      return returnResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  @override
  Future<dynamic> postMultipart({
    required String url,
    required Map<String, String> fields,
    required List<Uint8List> files,
    required List<String> fileNames,
    Map<String, String>? headers,
    String? fileFieldName,
    String? contentType,
  }) async {
    try {
      // 1. Add normal text fields to FormData
      FormData formData = FormData.fromMap(fields);

      // 2. Loop through the bytes and add them as MultipartFiles
      for (int i = 0; i < files.length; i++) {
        formData.files.add(
          MapEntry(
            fileFieldName ??
                'file[]', // Use your custom field name or a default
            MultipartFile.fromBytes(
              files[i],
              filename: fileNames[i],
            ),
          ),
        );
      }

      // 3. Send the request, merging any custom headers
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: headers, // Overrides default headers if provided
        ),
      );

      return returnResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  // --- Helper to Map HTTP Status Codes ---
  dynamic returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
        throw FetchDataException('Bad Request: ${response.data}');
      case 401:
      case 403:
        throw FetchDataException(
            'Unauthorized: Please check WooCommerce API Keys');
      case 404:
        throw InvalidUrlException('Endpoint not found');
      case 500:
        throw ServerException('Server error occurred');
      default:
        throw FetchDataException(
            'Error occurred with status code : ${response.statusCode}');
    }
  }

  // --- Helper to Map DioExceptions to your Custom AppExceptions ---
  dynamic _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw RequestTimeOut('Connection Timed Out');
    } else if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      throw InternetException('No Internet Connection');
    } else if (e.response != null) {
      // If the server responded with an error (e.g., 404, 500), pass it to returnResponse
      return returnResponse(e.response!);
    } else {
      throw FetchDataException('Unexpected Error: ${e.message}');
    }
  }
}
