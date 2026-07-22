import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'package:iron_street_app/app/widgets/shimmer.dart';
import 'checkout_controller.dart';
import '../address/add_edit_address_view.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final checkCtrl = Get.isRegistered<CheckoutController>()
        ? Get.find<CheckoutController>()
        : Get.put(CheckoutController());

    final couponTextCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        title: Text(
          'Checkout',
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
        actions: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'STEP 2/3',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (checkCtrl.cartCtrl.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Checkout Progress Tracker Indicator
            _buildCheckoutProgress(context),
            const SizedBox(height: 16),

            // Shipping Address Section
            _buildShippingAddressSection(context, checkCtrl),
            const SizedBox(height: 16),

            // Cart Items Summary Section
            _buildItemsSummarySection(context, checkCtrl),
            const SizedBox(height: 16),

            // Promo Code Section
            _buildPromoCodeSection(context, checkCtrl, couponTextCtrl),
            const SizedBox(height: 16),

            // Bill Summary Section
            _buildBillSummarySection(context, checkCtrl),
            const SizedBox(height: 32),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total amount',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                    Obx(() {
                      final isCalculating =
                          checkCtrl.isCalculatingDelivery.value;
                      final total = checkCtrl.checkoutTotal;
                      if (isCalculating) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Shimmer(
                            child: SizedBox(
                              width: 80,
                              height: 18,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Text(
                        '₹${NumberFormat('#,##,###').format(total)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 180,
                height: 48,
                child: Obx(() {
                  final isProcessing = checkCtrl.isProcessing.value;
                  final isCalculating = checkCtrl.isCalculatingDelivery.value;
                  if (isProcessing || isCalculating) {
                    return Shimmer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isProcessing ? 'PROCESSING...' : 'CALCULATING...',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: () => checkCtrl.proceedToPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'PLACE ORDER',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutProgress(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildProgressStep(context, 'Delivery', isCompleted: true),
          Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey[400]),
          _buildProgressStep(context, 'Payment', isActive: true),
          Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey[400]),
          _buildProgressStep(context, 'Success', isPending: true),
        ],
      ),
    );
  }

  Widget _buildProgressStep(BuildContext context, String label,
      {bool isCompleted = false,
      bool isActive = false,
      bool isPending = false}) {
    Color color;
    FontWeight weight;
    if (isCompleted) {
      color = AppColors.primary;
      weight = FontWeight.bold;
    } else if (isActive) {
      color = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87;
      weight = FontWeight.bold;
    } else {
      color = Colors.grey[400]!;
      weight = FontWeight.normal;
    }

    return Row(
      children: [
        Icon(
          isCompleted
              ? Icons.check_circle
              : (isActive ? Icons.circle_outlined : Icons.circle),
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 11, color: color, fontWeight: weight),
        ),
      ],
    );
  }

  Widget _buildShippingAddressSection(
      BuildContext context, CheckoutController checkCtrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Obx(() {
        final wcAddr = checkCtrl.cartCtrl.shippingAddress.value;
        final hasAddress = wcAddr != null &&
            (wcAddr.city.isNotEmpty || wcAddr.address1.isNotEmpty);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DELIVER TO',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (hasAddress) {
                      Get.to(() =>
                          AddEditAddressView(address: wcAddr.toAddressModel()));
                    } else {
                      Get.to(() => const AddEditAddressView());
                    }
                  },
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30)),
                  child: Text(
                    hasAddress ? 'CHANGE' : 'ADD ADDRESS',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasAddress) ...[
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF3D2619)
                          : const Color(0xFFFFF0E6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SHIPPING',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${wcAddr.firstName} ${wcAddr.lastName}'.trim(),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).textTheme.titleSmall?.color),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                wcAddr.fullAddress,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.8),
                    height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                'Mobile: ${wcAddr.phone}',
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.8)),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No delivery address selected. Please add one.',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildItemsSummarySection(
      BuildContext context, CheckoutController checkCtrl) {
    return Container(
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
            'ORDER ITEMS',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: checkCtrl.cartCtrl.cartItems.length,
            itemBuilder: (ctx, index) {
              final item = checkCtrl.cartCtrl.cartItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: item.product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                          Text(
                            'Qty: ${item.quantity.value} | ${item.product.material}',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${NumberFormat('#,##,###').format(item.product.price * item.quantity.value)}',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCodeSection(BuildContext context,
      CheckoutController checkCtrl, TextEditingController couponTextCtrl) {
    return Container(
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
            'PROMO CODE',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: couponTextCtrl,
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code (e.g. GOLDSTREET)',
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.grey[400]),
                    isDense: true,
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    if (couponTextCtrl.text.isNotEmpty) {
                      if (checkCtrl.applyCoupon(couponTextCtrl.text)) {
                        couponTextCtrl.clear();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]!
                            : Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'APPLY',
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          if (checkCtrl.appliedCoupon.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E3524)
                    : Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Coupon "${checkCtrl.appliedCoupon.value}" Active',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.green[300]
                                    : Colors.green[800],
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => checkCtrl.removeCoupon(),
                    child:
                        const Icon(Icons.cancel, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillSummarySection(
      BuildContext context, CheckoutController checkCtrl) {
    final subtotal = checkCtrl.cartCtrl.subtotal;
    final discount = checkCtrl.cartCtrl.discountAmount;
    final couponDisc = checkCtrl.couponDiscount.value;
    final tax = checkCtrl.cartCtrl.totalTax;

    return Container(
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
            'BILL DETAILS',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow(context, 'Item Subtotal', subtotal),
          if (discount > 0)
            _buildBillRow(context, 'Product Discounts', -discount,
                isDiscount: true),
          if (couponDisc > 0)
            _buildBillRow(context, 'Coupon Discount', -couponDisc,
                isDiscount: true),
          Obx(() {
            final isCalculating = checkCtrl.isCalculatingDelivery.value;
            final delivery = checkCtrl.deliveryCharge.value;
            if (isCalculating) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Charges',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.8),
                      ),
                    ),
                    const Shimmer(
                      child: SizedBox(
                        width: 60,
                        height: 14,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildBillRow(
              context,
              'Delivery Charges',
              delivery,
            );
          }),
          if (tax > 0) _buildBillRow(context, 'Estimated Tax (GST)', tax),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To Pay',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.titleSmall?.color),
              ),
              Obx(() {
                final isCalculating = checkCtrl.isCalculatingDelivery.value;
                final total = checkCtrl.checkoutTotal;
                if (isCalculating) {
                  return const Shimmer(
                    child: SizedBox(
                      width: 80,
                      height: 18,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ),
                    ),
                  );
                }
                return Text(
                  '₹${NumberFormat('#,##,###').format(total)}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.primary),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(BuildContext context, String label, double val,
      {bool isDiscount = false, String? customValueText}) {
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
            customValueText ??
                (isDiscount ? '-₹$formattedVal' : '₹$formattedVal'),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: customValueText != null
                  ? AppColors.primary
                  : (isDiscount
                      ? Colors.green[700]
                      : (val == 0.0
                          ? Colors.green[700]
                          : Theme.of(context).textTheme.bodyLarge?.color)),
            ),
          ),
        ],
      ),
    );
  }
}
