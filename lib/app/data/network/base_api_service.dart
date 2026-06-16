import 'dart:typed_data';


abstract class BaseApiServices {
  Future<dynamic> getApi(String url);

  // Future<dynamic> postApi(String url, dynamic data);
  Future<dynamic> postApi(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });

  Future<dynamic> putApi(String url, dynamic data);

  Future<dynamic> patchApi(String url, dynamic data);

  Future<dynamic> deleteApi(String url, dynamic data);

  Future<dynamic> postFormData(String url, Map<String, dynamic> data);


  /// Multipart (supports ANY file type)
  Future<dynamic> postMultipart({
    required String url,
    required Map<String, String> fields,
    required List<Uint8List> files,
    required List<String> fileNames,

    Map<String, String>? headers,
    String? fileFieldName,
    String? contentType,
  });

}
