import 'package:iron_street_app/app/data/network/network_api_service.dart';
import 'package:iron_street_app/app/utills/constant/app_urls.dart';

class OrderRepository {
  final NetworkApiServices _apiService = NetworkApiServices();

  /// Fetches orders for a specific customer, optimized to only retrieve fields used in the list view.
  Future<dynamic> fetchOrders({
    required int customerId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final String url = '${AppUrls.orders}'
          '?customer=$customerId'
          '&page=$page'
          '&per_page=$perPage'
          '&_fields=id,number,status,date_created,total,line_items';
      final response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches a specific order detail by order ID, optimized to only retrieve fields used in the detail view.
  Future<dynamic> fetchOrderDetail({required int orderId}) async {
    try {
      final String url = '${AppUrls.orders}/$orderId'
          '?_fields=id,number,status,date_created,total,total_tax,shipping_total,discount_total,shipping,billing,payment_method,payment_method_title,transaction_id,line_items';
      final response = await _apiService.getApi(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an order status and details (e.g. marking it paid and adding the transaction ID)
  Future<dynamic> updateOrder({
    required int orderId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final String url = '${AppUrls.orders}/$orderId';
      final response = await _apiService.putApi(url, data);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
