// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'cart_controller.dart';
import '../../routes/app_pages.dart';
import '../wishlist/wishlist_controller.dart';
import '../../data/models/product_list_model.dart';
import '../../utills/theme/app_colors.dart';
import '../checkout/checkout_controller.dart';
import '../address/address_controller.dart';
import '../address/add_edit_address_view.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    if (!Get.isRegistered<AddressController>()) {
      Get.put(AddressController());
    }

    final checkoutController = Get.isRegistered<CheckoutController>()
        ? Get.find<CheckoutController>()
        : Get.put(CheckoutController());

    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'CART',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox();
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'STEP 1/3',
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return const EmptyCartState();
        }

        return Column(
          children: [
            // Delivery Location Section
            DeliveryLocationSection(checkoutController: checkoutController),

            // List of cart items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.cartItems.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return CartItemCard(
                    item: item,
                    controller: controller,
                    wishlistController: wishlistController,
                    formatCurrency: formatCurrency,
                  );
                },
              ),
            ),

            // Fixed Bottom Bar
            CartBottomBar(
              controller: controller,
              formatCurrency: formatCurrency,
            ),
          ],
        );
      }),
    );
  }
}

class DeliveryLocationSection extends StatelessWidget {
  final CheckoutController checkoutController;

  const DeliveryLocationSection({
    super.key,
    required this.checkoutController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() {
              final addr = checkoutController.selectedAddress.value;
              return Text(
                addr != null
                    ? 'Delivery at ${addr.city} - ${addr.postalCode}'
                    : 'Select Delivery Address',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
          TextButton(
            onPressed: () {
              _showAddressSelectionBottomSheet(context, checkoutController);
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Change',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSelectionBottomSheet(
      BuildContext context, CheckoutController checkCtrl) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Address',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF222222),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Flexible(
              child: Obx(() {
                final list = checkCtrl.addrCtrl.addresses;
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No saved addresses',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final addr = list[index];
                    final isSelected =
                        checkCtrl.selectedAddress.value?.id == addr.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFF1F1F1),
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
                          style: GoogleFonts.poppins(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          addr.fullAddress,
                          style: GoogleFonts.poppins(
                              fontSize: 9, color: Colors.grey),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary, size: 18)
                            : null,
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Get.back();
                  Get.to(() => const AddEditAddressView());
                },
                child: Text(
                  'ADD NEW ADDRESS',
                  style: GoogleFonts.poppins(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController controller;
  final WishlistController wishlistController;
  final NumberFormat formatCurrency;

  const CartItemCard({
    super.key,
    required this.item,
    required this.controller,
    required this.wishlistController,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final prod = item.product;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: prod.image,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Pricing Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formatCurrency.format(prod.price),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackC,
                            ),
                          ),
                          if (prod.oldPrice > prod.price) ...[
                            const SizedBox(width: 8),
                            Text(
                              formatCurrency.format(prod.oldPrice),
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${prod.discount.toStringAsFixed(0)}% OFF',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quantity selector
                      Obx(
                        () => QuantitySelector(
                          quantity: item.quantity.value,
                          onChanged: (delta) {
                            controller.updateQuantity(prod.id, delta);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Delivery Estimation
                      Row(
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Estimated Delivery: 3-5 Business Days',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          // Actions bar
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    final int productIdInt = int.tryParse(prod.id) ?? 0;
                    if (!wishlistController.isInWishlist(productIdInt)) {
                      wishlistController.toggleWishlist(
                        ProductListModel(
                          id: productIdInt,
                          name: prod.name,
                          price: prod.price,
                          oldPrice: prod.oldPrice,
                          discount: prod.discount,
                          image: prod.image,
                          brand: prod.brand,
                          rating: prod.rating,
                          reviewsCount: prod.reviewsCount,
                        ),
                      );
                    }
                    controller.removeItem(prod.id);
                    Get.snackbar(
                      'Wishlist',
                      'Moved "${prod.name}" to Wishlist',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.favorite_border, size: 14),
                  label: Text(
                    'Move to Wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    controller.removeItem(prod.id);
                    Get.snackbar(
                      'Removed',
                      'Removed "${prod.name}" from Cart',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.close, size: 14),
                  label: Text(
                    'Remove',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final Function(int) onChanged;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Qty:',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCDCDC)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: quantity > 1 ? () => onChanged(-1) : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.transparent,
                  child: Icon(
                    Icons.remove,
                    size: 12,
                    color: quantity > 1 ? Colors.black87 : Colors.grey[300],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 18,
                color: const Color(0xFFDCDCDC),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF222222),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 18,
                color: const Color(0xFFDCDCDC),
              ),
              GestureDetector(
                onTap: () => onChanged(1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.transparent,
                  child: const Icon(
                    Icons.add,
                    size: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CartBottomBar extends StatelessWidget {
  final CartController controller;
  final NumberFormat formatCurrency;

  const CartBottomBar({
    super.key,
    required this.controller,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFF1F1F1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price Summary Trigger
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                        formatCurrency.format(controller.totalAmount),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF222222),
                        ),
                      )),
                  GestureDetector(
                    onTap: () => _showPriceDetailsSheet(context),
                    child: Text(
                      'VIEW PRICE DETAILS',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Checkout button
            SizedBox(
              width: 140,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.toNamed(Routes.CHECKOUT),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceDetailsSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Details',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF222222),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInvoiceLine('Subtotal Items Price',
                formatCurrency.format(controller.oldSubtotal)),
            if (controller.discountAmount > 0)
              _buildInvoiceLine('Special Store Coupon Discount',
                  '- ${formatCurrency.format(controller.discountAmount)}',
                  isGreen: true),
            _buildInvoiceLine(
                'Delivery Charges',
                controller.deliveryPrice > 0
                    ? formatCurrency.format(controller.deliveryPrice)
                    : 'FREE'),
            if (controller.totalTax > 0)
              _buildInvoiceLine('Estimated GST (18% included)',
                  formatCurrency.format(controller.totalTax)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatCurrency.format(controller.totalAmount),
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInvoiceLine(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isGreen ? Colors.green[600] : const Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyCartState extends StatelessWidget {
  const EmptyCartState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 68,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore our premium furniture collection and add some warm layouts to your home!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 42,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    'Continue Shopping',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
