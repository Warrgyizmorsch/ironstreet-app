import 'dart:developer';
import 'package:get/get.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository/order_repository.dart';
import '../profile/profile_controller.dart';

class OrdersController extends GetxController {
  final OrderRepository orderRepository = Get.find<OrderRepository>();

  var orders = <OrderModel>[].obs;
  var isLoading = false.obs;
  var hasError = false.obs;

  // Pagination states
  int _page = 1;
  static const int _perPage = 10;
  var hasMore = true.obs;
  var isMoreLoading = false.obs;

  // Active Order Detail state for detail view
  var activeOrderDetail = Rxn<OrderModel>();
  var isDetailsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders(isRefresh: true);
  }

  /// Fetches user's orders from the WooCommerce REST API with pagination.
  /// Set [isRefresh] to true to reset the list and load the first page.
  Future<void> fetchUserOrders({bool isRefresh = false}) async {
    // Avoid double fetching while loading
    if (!isRefresh && (isMoreLoading.value || !hasMore.value)) return;

    try {
      if (isRefresh) {
        isLoading.value = true;
        hasError.value = false;
        _page = 1;
        hasMore.value = true;
      } else {
        isMoreLoading.value = true;
      }

      final profCtrl = Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController(), permanent: true);

      // Fetch user profile if not loaded yet to retrieve customer ID
      if (profCtrl.userProfile.value == null) {
        await profCtrl.fetchProfile();
      }

      final String customerIdStr = profCtrl.userProfile.value?.id ?? '';
      if (customerIdStr.isEmpty) {
        log('[OrdersController] No customer ID found — skipping orders fetch');
        if (isRefresh) orders.clear();
        return;
      }

      final int customerId = int.tryParse(customerIdStr) ?? 0;
      if (customerId == 0) {
        log('[OrdersController] Invalid customer ID: $customerIdStr');
        if (isRefresh) orders.clear();
        return;
      }

      log('[OrdersController] Fetching page $_page of orders for customer ID: $customerId');
      final response = await orderRepository.fetchOrders(
        customerId: customerId,
        page: _page,
        perPage: _perPage,
      );

      if (response is List) {
        final List<OrderModel> fetchedOrders = response
            .map((json) => OrderModel.fromWcJson(json as Map<String, dynamic>))
            .toList();

        if (isRefresh) {
          orders.assignAll(fetchedOrders);
        } else {
          orders.addAll(fetchedOrders);
        }

        // If returned items count is less than perPage, we reached the end
        if (fetchedOrders.length < _perPage) {
          hasMore.value = false;
          log('[OrdersController] Reached the end of orders. No more pages.');
        } else {
          hasMore.value = true;
        }

        log('[OrdersController] Loaded ${fetchedOrders.length} orders. Total list size: ${orders.length}');
      } else {
        log('[OrdersController] Invalid list format returned from API');
        if (isRefresh) orders.clear();
        hasMore.value = false;
      }
    } catch (e) {
      if (isRefresh) {
        hasError.value = true;
      }
      log('[OrdersController] Error loading orders from API (page $_page): $e');
    } finally {
      if (isRefresh) {
        isLoading.value = false;
      } else {
        isMoreLoading.value = false;
      }
    }
  }

  /// Triggers loading of the next page if there are more items to retrieve
  Future<void> loadNextPage() async {
    if (!isLoading.value && !isMoreLoading.value && hasMore.value) {
      _page++;
      await fetchUserOrders(isRefresh: false);
    }
  }

  /// Fetches detailed information for a single order by ID
  Future<void> fetchOrderDetail(String orderId) async {
    try {
      isDetailsLoading.value = true;
      activeOrderDetail.value = null; // Clear previous state to show loading

      final int id = int.tryParse(orderId) ?? 0;
      if (id == 0) {
        log('[OrdersController] Invalid order ID format: $orderId');
        return;
      }

      log('[OrdersController] Fetching fresh details for order ID: $id');
      final response = await orderRepository.fetchOrderDetail(orderId: id);

      if (response != null && response is Map<String, dynamic>) {
        activeOrderDetail.value = OrderModel.fromWcJson(response);
        log('[OrdersController] Order detail loaded: #${activeOrderDetail.value?.orderNumber}');
      }
    } catch (e) {
      log('[OrdersController] Error loading order details: $e');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  void placeOrder(OrderModel newOrder) {
    orders.insert(0, newOrder);
  }

  OrderModel? findOrderById(String orderId) {
    return orders.firstWhereOrNull((o) => o.id == orderId);
  }
}
