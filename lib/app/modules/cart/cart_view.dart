// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'cart_controller.dart';
import '../../routes/app_pages.dart';
import '../wishlist/wishlist_controller.dart';
import '../../widgets/custom_toast.dart';
import '../../data/models/product_list_model.dart';
import '../../utills/theme/app_colors.dart';
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.fetchCart();
    // });

    String formatCurrency(double amount) {
      final formatter = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: amount % 1 == 0 ? 0 : 2,
      );
      return formatter.format(amount);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color ??
                  Theme.of(context).textTheme.titleLarge?.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'CART',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
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
          return
              // RefreshIndicator(
              //   onRefresh: () => controller.fetchCart(),
              //   color: AppColors.primary,
              //   child:
              SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 120,
              child: const EmptyCartState(),
            ),
            // ),
          );
        }

        return Column(
          children: [
            // Delivery Location Section
            const DeliveryLocationSection(),

            // List of cart items
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchCart(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.cartItems.length,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
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
  const DeliveryLocationSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.7),
              size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() {
              final wcAddr = cartCtrl.shippingAddress.value;
              String displayStr = 'Select Delivery Address';
              if (wcAddr != null &&
                  (wcAddr.city.isNotEmpty || wcAddr.postcode.isNotEmpty)) {
                displayStr =
                    'Delivery at ${wcAddr.city.isNotEmpty ? wcAddr.city : 'Selected Address'}${wcAddr.postcode.isNotEmpty ? ' - ${wcAddr.postcode}' : ''}';
              }

              return Text(
                displayStr,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
          Obx(() {
            final wcAddr = cartCtrl.shippingAddress.value;
            final hasAddress = wcAddr != null &&
                (wcAddr.city.isNotEmpty || wcAddr.address1.isNotEmpty);

            return TextButton(
              onPressed: () {
                if (hasAddress) {
                  Get.to(() =>
                      AddEditAddressView(address: wcAddr.toAddressModel()));
                } else {
                  Get.to(() => const AddEditAddressView());
                }
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                hasAddress ? 'Change' : 'Add Address',
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
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController controller;
  final WishlistController wishlistController;
  final String Function(double) formatCurrency;

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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
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
                GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.PRODUCT_DETAIL,
                    arguments: int.tryParse(prod.id) ?? 0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: prod.image,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(
                          Routes.PRODUCT_DETAIL,
                          arguments: int.tryParse(prod.id) ?? 0,
                        ),
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
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Pricing Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  formatCurrency(prod.price),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blackC,
                                  ),
                                ),
                                if (prod.oldPrice > prod.price) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    formatCurrency(prod.oldPrice),
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
                          ],
                        ),
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
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Estimated Delivery: 3-5 Business Days',
                            style: GoogleFonts.poppins(
                              fontSize: 8.5,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.7),
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
            color: Theme.of(context).dividerColor,
          ),
          // Actions bar
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.8),
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
                    CustomToast.show('Moved to Wishlist');
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
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    controller.removeItem(prod.id);
                    CustomToast.show('Removed from Cart');
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
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
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
                    color: quantity > 1
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).dividerColor,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 18,
                color: Theme.of(context).dividerColor,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 18,
                color: Theme.of(context).dividerColor,
              ),
              GestureDetector(
                onTap: () => onChanged(1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.transparent,
                  child: Icon(
                    Icons.add,
                    size: 12,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
  final String Function(double) formatCurrency;

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
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
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
                        formatCurrency(controller.totalAmount),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).textTheme.titleSmall?.color,
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
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: Theme.of(context).textTheme.titleMedium?.color,
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
            Obx(() {
              final isCalculatingDelivery =
                  controller.isCalculatingDelivery.value;
              final priceVal = controller.deliveryPrice;

              return Column(
                children: [
                  _buildInvoiceLine(context, 'Item Subtotal',
                      formatCurrency(controller.originalSubtotal)),
                  if (controller.productDiscountAmount > 0)
                    _buildInvoiceLine(context, 'Product Discount',
                        '- ${formatCurrency(controller.productDiscountAmount)}',
                        isGreen: true),
                  ...controller.appliedCoupons.map((coupon) {
                    return _buildInvoiceLine(
                      context,
                      'Coupon Discount (${coupon.code})',
                      '- ${formatCurrency(coupon.discountAmount)}',
                      isGreen: true,
                    );
                  }),
                  _buildInvoiceLine(
                      context,
                      'Delivery Charges',
                      isCalculatingDelivery
                          ? 'Calculating...'
                          : (priceVal > 0 ? formatCurrency(priceVal) : 'FREE')),
                  if (controller.totalTax > 0)
                    _buildInvoiceLine(context, 'Estimated GST (18% included)',
                        formatCurrency(controller.totalTax)),
                ],
              );
            }),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Obx(() {
                  final isCalculating = controller.isCalculatingDelivery.value;
                  final totalVal = controller.totalAmount;
                  return Text(
                    isCalculating ? 'Calculating...' : formatCurrency(totalVal),
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInvoiceLine(BuildContext context, String label, String value,
      {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.8)),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isGreen
                  ? Colors.green[600]
                  : Theme.of(context).textTheme.bodyLarge?.color,
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
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Explore our premium furniture collection and add some warm layouts to your home!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.8),
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
