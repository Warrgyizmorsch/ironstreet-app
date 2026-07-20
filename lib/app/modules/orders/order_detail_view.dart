import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'package:iron_street_app/app/data/local/session_manager.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'package:iron_street_app/app/data/repositories/product_repository/product_repository.dart';
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        title: Text(
          'Order Info',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).appBarTheme.iconTheme?.color ??
                  Theme.of(context).textTheme.titleLarge?.color,
              size: 20),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        switch (order.status.toLowerCase()) {
          case 'pending':
            statusColor = isDark ? Colors.orange[400]! : Colors.orange[800]!;
            statusBg = isDark
                ? Colors.orange[900]!.withValues(alpha: 0.2)
                : Colors.orange[50]!;
            break;
          case 'processing':
            statusColor = isDark ? Colors.blue[300]! : Colors.blue[800]!;
            statusBg = isDark
                ? Colors.blue[900]!.withValues(alpha: 0.2)
                : Colors.blue[50]!;
            break;
          case 'dispatched':
          case 'shipped':
            statusColor = AppColors.primary;
            statusBg = isDark
                ? AppColors.primary.withValues(alpha: 0.15)
                : const Color(0xFFFFF0E6);
            break;
          case 'delivered':
            statusColor = isDark ? Colors.green[400]! : Colors.green[800]!;
            statusBg = isDark
                ? Colors.green[900]!.withValues(alpha: 0.2)
                : Colors.green[50]!;
            break;
          case 'cancelled':
          default:
            statusColor = isDark ? Colors.red[400]! : Colors.red[800]!;
            statusBg = isDark
                ? Colors.red[900]!.withValues(alpha: 0.2)
                : Colors.red[50]!;
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
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
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              order.orderNumber,
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.color),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Order Tracking Progress Timeline
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER STATUS TRACKING',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    _buildTrackStep(
                      context,
                      'Order Confirmed & Verified',
                      DateFormat('MMMM dd, hh:mm a').format(order.orderDate),
                      isDone: true,
                    ),
                    _buildTrackStep(
                      context,
                      'Quality Assessed & Packed',
                      'Processing details verified',
                      isDone: order.status.toLowerCase() != 'pending' &&
                          order.status.toLowerCase() != 'cancelled',
                    ),
                    _buildTrackStep(
                      context,
                      'Handed over to E-Kart Logistics',
                      'Shipment registration completed',
                      isDone: order.status.toLowerCase() == 'dispatched' ||
                          order.status.toLowerCase() == 'delivered' ||
                          order.status.toLowerCase() == 'shipped',
                    ),
                    _buildTrackStep(
                      context,
                      order.status.toLowerCase() == 'delivered'
                          ? 'Delivered'
                          : 'In-Transit: Nearing Delivery City',
                      order.status.toLowerCase() == 'delivered'
                          ? 'Delivered successfully'
                          : 'Expected delivery shortly',
                      isDone: order.status.toLowerCase() == 'delivered',
                      isCurrent: order.status.toLowerCase() == 'dispatched' ||
                          order.status.toLowerCase() == 'shipped' ||
                          order.status.toLowerCase() == 'processing',
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ITEMS ORDERED',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
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
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2D2D2D)
                                      : Colors.grey[200],
                                  child: const Icon(Icons.chair_outlined,
                                      color: Colors.grey),
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
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.color),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} | ${item.product.material}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () {
                                      _showAddReviewBottomSheet(
                                        context: context,
                                        productId:
                                            int.tryParse(item.product.id) ?? 0,
                                        productName: item.product.name,
                                        productImageUrl: item.product.image,
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.rate_review_outlined,
                                          size: 13,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Write a Review',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${NumberFormat('#,##,###').format(item.price * item.quantity)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary),
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHIPPING DETAILS',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.shippingAddress.name,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleSmall?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.shippingAddress.fullAddress,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.8),
                          height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          order.shippingAddress.phone,
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.8)),
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRICE DETAILS',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    _buildPriceRow(context, 'Items Subtotal', order.subtotal),
                    if (order.discount > 0)
                      _buildPriceRow(
                          context, 'Discount Applied', -order.discount,
                          isDiscount: true),
                    _buildPriceRow(
                        context, 'Delivery Charges', order.deliveryCharges),
                    if (order.totalTax > 0)
                      _buildPriceRow(
                          context, 'Estimated Tax (GST)', order.totalTax),
                    const Divider(height: 24, thickness: 0.3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Grand Total',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.color),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,###').format(order.totalAmount)}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 24,
                      thickness: 0.3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Method',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.8)),
                        ),
                        Text(
                          '${order.paymentMethod} (${order.paymentDetails})',
                          style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color),
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF3D2619)
                      : const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF5A3926)
                          : const Color(0xFFFFD4C0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.headset_mic_outlined,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Have any query regarding delivery?',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.87)
                                    : Colors.black.withValues(alpha: 0.87)),
                          ),
                          Text(
                            'Call us at 1800-424-6789 or write to care@ironstreet.com',
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.54)
                                    : Colors.black.withValues(alpha: 0.54)),
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

  Widget _buildPriceRow(BuildContext context, String label, double val,
      {bool isDiscount = false}) {
    final formattedVal = NumberFormat('#,##,###').format(val.abs());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.8))),
          Text(
            isDiscount ? '-₹$formattedVal' : '₹$formattedVal',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? Colors.green[700]
                  : (val == 0.0
                      ? Colors.green[700]
                      : Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackStep(BuildContext context, String label, String timing,
      {bool isDone = false, bool isCurrent = false, bool isLast = false}) {
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
                color: isDone || isCurrent
                    ? Colors.green[600]
                    : (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2D2D2D)
                        : Colors.grey[300]),
                border: isCurrent
                    ? Border.all(color: Colors.green[100]!, width: 4)
                    : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color:
                    isDone ? Colors.green[200] : Theme.of(context).dividerColor,
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
                      : (isDone
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : Colors.grey[400]),
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

  void _showAddReviewBottomSheet({
    required BuildContext context,
    required int productId,
    required String productName,
    required String productImageUrl,
  }) {
    final reviewTextController = TextEditingController();
    final RxInt selectedRating = 5.obs;
    final RxString ratingText = 'Excellent'.obs;
    final RxBool isSubmitting = false.obs;

    void updateRatingText(int rating) {
      switch (rating) {
        case 5:
          ratingText.value = 'Excellent';
          break;
        case 4:
          ratingText.value = 'Good';
          break;
        case 3:
          ratingText.value = 'Average';
          break;
        case 2:
          ratingText.value = 'Poor';
          break;
        case 1:
          ratingText.value = 'Very Poor';
          break;
      }
    }

    final sessionManager = Get.find<SessionManager>();
    final reviewerName = sessionManager.getName();
    final reviewerEmail = sessionManager.getEmail();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Write a Review',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              // Product Info Preview
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: productImageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2D2D2D)
                            : Colors.grey[200],
                        child: const Icon(Icons.chair_outlined,
                            color: Colors.grey, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reviewer details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Reviewing as: $reviewerName ($reviewerEmail)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Star selection
              Text(
                'Rate this product',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleSmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Obx(() => Row(
                        children: List.generate(5, (index) {
                          final int starValue = index + 1;
                          return GestureDetector(
                            onTap: () {
                              selectedRating.value = starValue;
                              updateRatingText(starValue);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                starValue <= selectedRating.value
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 32,
                                color: starValue <= selectedRating.value
                                    ? Colors.amber[700]
                                    : Colors.grey[400],
                              ),
                            ),
                          );
                        }),
                      )),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                        ratingText.value,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // Review details
              Text(
                'Review details',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleSmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewTextController,
                maxLines: 4,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Share your experience with this product...',
                  hintStyle: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Obx(() {
                final bool submitting = isSubmitting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: submitting
                        ? null
                        : () async {
                            final String text =
                                reviewTextController.text.trim();
                            if (text.isEmpty) {
                              CustomToast.show('Please enter your review text',
                                  isError: true);
                              return;
                            }

                            try {
                              isSubmitting.value = true;
                              final productRepository =
                                  Get.find<ProductRepository>();
                              final response =
                                  await productRepository.submitProductReview(
                                productId: productId,
                                reviewer: reviewerName.isNotEmpty
                                    ? reviewerName
                                    : 'Anonymous',
                                email: reviewerEmail.isNotEmpty
                                    ? reviewerEmail
                                    : 'anonymous@example.com',
                                review: text,
                                rating: selectedRating.value,
                              );

                              isSubmitting.value = false;
                              if (response != null) {
                                CustomToast.show(
                                    'Review submitted successfully!',
                                    isSuccess: true);
                                Get.back(); // Close bottom sheet
                              }
                            } catch (e) {
                              isSubmitting.value = false;
                              final errorMsg = e.toString().toLowerCase();
                              if (errorMsg.contains('comment_duplicate') ||
                                  errorMsg.contains('duplicate')) {
                                CustomToast.show(
                                    'You have already submitted a review for this product.',
                                    isError: true);
                              } else {
                                CustomToast.show(
                                    'Failed to submit review. Please try again.',
                                    isError: true);
                              }
                            }
                          },
                    child: submitting
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : Text(
                            'Submit Review',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
