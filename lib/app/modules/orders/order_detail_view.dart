import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import '../../widgets/shimmer.dart';
import 'orders_controller.dart';

class OrderDetailView extends StatelessWidget {
  final String orderId;

  const OrderDetailView({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final ordCtrl = Get.find<OrdersController>();

    // Trigger API call for fresh order details when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ordCtrl.fetchOrderDetail(orderId);
    });

    final dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Order Info',
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
      body: Obx(() {
        final cachedOrder = ordCtrl.findOrderById(orderId);
        final liveOrder = ordCtrl.activeOrderDetail.value;
        final isLoading = ordCtrl.isDetailsLoading.value;

        // Determine which data to use (prefer live details over cached list info)
        final order = liveOrder ?? cachedOrder;

        if (order == null) {
          if (isLoading) {
            return const OrderDetailShimmer();
          }
          return Center(
            child: Text(
              'Order not found',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        // Determine status colors
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

        return RefreshIndicator(
          onRefresh: () => ordCtrl.fetchOrderDetail(orderId),
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // Pull-to-refresh loading indicator bar
              if (isLoading && liveOrder != null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                  ),
                ),

              // Order ID & Status Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ORDER NUMBER',
                              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              order.orderNumber,
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF222222)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Placed on ${dateFormatter.format(order.orderDate)}',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Order Tracking Progress Timeline
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER STATUS TRACKING',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildTrackStep(
                      'Order Confirmed & Verified',
                      DateFormat('MMMM dd, hh:mm a').format(order.orderDate),
                      isDone: true,
                    ),
                    _buildTrackStep(
                      'Quality Assessed & Packed',
                      'Processing details verified',
                      isDone: order.status.toLowerCase() != 'pending' && order.status.toLowerCase() != 'cancelled',
                    ),
                    _buildTrackStep(
                      'Handed over to E-Kart Logistics',
                      'Shipment registration completed',
                      isDone: order.status.toLowerCase() == 'dispatched' || order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'shipped',
                    ),
                    _buildTrackStep(
                      order.status.toLowerCase() == 'delivered' ? 'Delivered' : 'In-Transit: Nearing Delivery City',
                      order.status.toLowerCase() == 'delivered' ? 'Delivered successfully' : 'Expected delivery shortly',
                      isDone: order.status.toLowerCase() == 'delivered',
                      isCurrent: order.status.toLowerCase() == 'dispatched' || order.status.toLowerCase() == 'shipped' || order.status.toLowerCase() == 'processing',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Items Summary List
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ITEMS ORDERED',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: item.product.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.chair_outlined, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF222222)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} | ${item.product.material}',
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${NumberFormat('#,##,###').format(item.price * item.quantity)}',
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Shipping Address Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHIPPING DETAILS',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.shippingAddress.name,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF222222)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingAddress.fullAddress,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700], height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          order.shippingAddress.phone,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bill Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRICE DETAILS',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    _buildPriceRow('Items Subtotal', order.subtotal),
                    _buildPriceRow('Discount Applied', -order.discount, isDiscount: true),
                    _buildPriceRow('Delivery Charges', order.deliveryCharges),
                    const Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF222222)),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(order.totalAmount)}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
                        ),
                        Text(
                          '${order.paymentMethod} (${order.paymentDetails})',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF444444)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Need Help? Contact Us
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD4C0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.headset_mic_outlined, color: AppColors.primary, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Have any query regarding delivery?',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            'Call us at 1800-424-6789 or write to care@ironstreet.com',
                            style: GoogleFonts.poppins(fontSize: 9, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPriceRow(String label, double val, {bool isDiscount = false}) {
    final formattedVal = NumberFormat('#,##,###').format(val.abs());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          Text(
            isDiscount ? '-₹$formattedVal' : '₹$formattedVal',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? Colors.green[700]
                  : (val == 0.0 ? Colors.green[700] : const Color(0xFF444444)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep(String label, String timing, {bool isDone = false, bool isCurrent = false, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone || isCurrent ? Colors.green[600] : Colors.grey[300],
                border: isCurrent ? Border.all(color: Colors.green[100]!, width: 4) : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isDone ? Colors.green[200] : Colors.grey[200],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isCurrent
                      ? AppColors.primary
                      : (isDone ? const Color(0xFF222222) : Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timing,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
