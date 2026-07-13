// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'orders_controller.dart';
import 'order_detail_view.dart';
import '../../widgets/shimmer.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ordCtrl = Get.isRegistered<OrdersController>()
        ? Get.find<OrdersController>()
        : Get.put(OrdersController());

    final ScrollController scrollController = ScrollController();
    
    // Add scroll listener to load next page when scrolled near bottom
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        ordCtrl.loadNextPage();
      }
    });

    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'My Orders',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ordCtrl.fetchUserOrders(isRefresh: true),
        color: AppColors.primary,
        child: Obx(() {
          if (ordCtrl.isLoading.value) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) => const OrderCardShimmer(),
            );
          }

          if (ordCtrl.hasError.value) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load orders',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check your internet connection and swipe down to try again.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => ordCtrl.fetchUserOrders(),
                      icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
                      label: Text(
                        'RETRY',
                        style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (ordCtrl.orders.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No Orders Placed Yet',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your purchase history will appear here.',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: ordCtrl.orders.length + (ordCtrl.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == ordCtrl.orders.length) {
                return Obx(() {
                  return ordCtrl.isMoreLoading.value
                      ? const Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 16),
                          child: OrderCardShimmer(),
                        )
                      : const SizedBox.shrink();
                });
              }

              final order = ordCtrl.orders[index];
            
            // Build Status Chip decoration
            Color statusColor;
            Color statusBg;
            switch (order.status.toLowerCase()) {
              case 'pending':
                statusColor = Colors.orange[800]!;
                statusBg = Colors.orange[50]!;
                break;
              case 'processing':
                statusColor = Colors.blue[800]!;
                statusBg = Colors.blue[50]!;
                break;
              case 'dispatched':
              case 'shipped':
                statusColor = AppColors.primary;
                statusBg = const Color(0xFFFFF0E6);
                break;
              case 'delivered':
                statusColor = Colors.green[800]!;
                statusBg = Colors.green[50]!;
                break;
              case 'cancelled':
              default:
                statusColor = Colors.red[800]!;
                statusBg = Colors.red[50]!;
                break;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFEFEF)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => Get.to(() => OrderDetailView(orderId: order.id)),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.orderNumber,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatter.format(order.orderDate),
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                      ),
                      const Divider(height: 24),
                      
                      // Order Items Thumbnails Row
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: order.items.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = order.items[itemIndex];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFECECEC)),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: item.product.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${NumberFormat('#,##,###').format(order.totalAmount)}',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}',
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Need help with this order?',
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                          ),
                          Row(
                            children: [
                              Text(
                                'VIEW DETAILS',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    ),
  );
}
}
