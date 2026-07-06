import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
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
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Checkout',
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
        if (checkCtrl.cartCtrl.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
            _buildCheckoutProgress(),
            const SizedBox(height: 16),

            // Shipping Address Section
            _buildShippingAddressSection(context, checkCtrl),
            const SizedBox(height: 16),

            // Cart Items Summary Section
            _buildItemsSummarySection(checkCtrl),
            const SizedBox(height: 16),

            // Promo Code Section
            _buildPromoCodeSection(checkCtrl, couponTextCtrl),
            const SizedBox(height: 16),

            // Bill Summary Section
            _buildBillSummarySection(checkCtrl),
            const SizedBox(height: 32),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final total = checkCtrl.checkoutTotal;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F1F1)),
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
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '₹${NumberFormat('#,##,###').format(total)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
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
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCheckoutProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildProgressStep('Delivery', isCompleted: true),
          Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey[400]),
          _buildProgressStep('Payment', isActive: true),
          Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey[400]),
          _buildProgressStep('Success', isPending: true),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, {bool isCompleted = false, bool isActive = false, bool isPending = false}) {
    Color color;
    FontWeight weight;
    if (isCompleted) {
      color = AppColors.primary;
      weight = FontWeight.bold;
    } else if (isActive) {
      color = Colors.black87;
      weight = FontWeight.bold;
    } else {
      color = Colors.grey[400]!;
      weight = FontWeight.normal;
    }

    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : (isActive ? Icons.circle_outlined : Icons.circle),
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: weight),
        ),
      ],
    );
  }

  Widget _buildShippingAddressSection(BuildContext context, CheckoutController checkCtrl) {
    final address = checkCtrl.selectedAddress.value;

    return Container(
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
                onPressed: () => _showAddressSelectionBottomSheet(context, checkCtrl),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                child: Text(
                  address != null ? 'CHANGE' : 'ADD ADDRESS',
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
          if (address != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0E6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    address.addressType.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  address.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF222222)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              address.fullAddress,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 6),
            Text(
              'Mobile: ${address.phone}',
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No delivery address selected. Please add one.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddressSelectionBottomSheet(BuildContext context, CheckoutController checkCtrl) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Address',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final list = checkCtrl.addrCtrl.addresses;
              if (list.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No saved addresses',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 250,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (ctx, idx) {
                    final addr = list[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: checkCtrl.selectedAddress.value?.id == addr.id
                              ? AppColors.primary
                              : const Color(0xFFECECEC),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          checkCtrl.updateSelectedAddress(addr);
                          Get.back();
                        },
                        title: Text(
                          '${addr.name} (${addr.addressType})',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          addr.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 10),
                        ),
                        trailing: checkCtrl.selectedAddress.value?.id == addr.id
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : null,
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.to(() => const AddEditAddressView());
                },
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                label: Text(
                  'ADD NEW ADDRESS',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSummarySection(CheckoutController checkCtrl) {
    return Container(
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
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF222222)),
                          ),
                          Text(
                            'Qty: ${item.quantity.value} | ${item.product.material}',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${NumberFormat('#,##,###').format(item.product.price * item.quantity.value)}',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF222222)),
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

  Widget _buildPromoCodeSection(CheckoutController checkCtrl, TextEditingController couponTextCtrl) {
    return Container(
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
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code (e.g. GOLDSTREET)',
                    hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[200]!),
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
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'APPLY',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
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
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Coupon "${checkCtrl.appliedCoupon.value}" Active',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.green[800], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => checkCtrl.removeCoupon(),
                    child: const Icon(Icons.cancel, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillSummarySection(CheckoutController checkCtrl) {
    final subtotal = checkCtrl.cartCtrl.subtotal;
    final discount = checkCtrl.cartCtrl.discountAmount;
    final delivery = checkCtrl.cartCtrl.deliveryPrice;
    final couponDisc = checkCtrl.couponDiscount.value;
    final total = checkCtrl.checkoutTotal;

    return Container(
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
            'BILL DETAILS',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow('Item Subtotal', subtotal),
          _buildBillRow('Product Discounts', -discount, isDiscount: true),
          if (couponDisc > 0) _buildBillRow('Coupon Discount', -couponDisc, isDiscount: true),
          _buildBillRow('Delivery Charges', delivery),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To Pay',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF222222)),
              ),
              Text(
                '₹${NumberFormat('#,##,###').format(total)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double val, {bool isDiscount = false}) {
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
}
