// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'wishlist_controller.dart';
import '../cart/cart_controller.dart';
import '../../data/models/product_list_model.dart';
import '../../data/models/product_model.dart';
import '../../utills/theme/app_colors.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistCtrl = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());
    final cartController = Get.find<CartController>();
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
          'WISHLIST',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        final wishItems = wishlistCtrl.wishlistItems;

        if (wishItems.isEmpty) {
          return const EmptyWishlistState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: wishItems.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final prod = wishItems[index];
            return WishlistItemCard(
              prod: prod,
              wishlistCtrl: wishlistCtrl,
              cartController: cartController,
              formatCurrency: formatCurrency,
            );
          },
        );
      }),
    );
  }
}

class WishlistItemCard extends StatelessWidget {
  final ProductListModel prod;
  final WishlistController wishlistCtrl;
  final CartController cartController;
  final NumberFormat formatCurrency;

  const WishlistItemCard({
    super.key,
    required this.prod,
    required this.wishlistCtrl,
    required this.cartController,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        prod.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 6),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.grey.shade300,
            thickness: 1,
          ),
          // Actions bar
          Row(
            children: [
              // Add to Cart
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    cartController.addToCart(
                      Product(
                        id: prod.id.toString(),
                        name: prod.name,
                        brand: prod.brand.isNotEmpty
                            ? prod.brand
                            : "LuxeLiving by Iron Street",
                        price: prod.price,
                        oldPrice: prod.oldPrice,
                        discount: prod.discount,
                        rating: prod.rating,
                        reviewsCount: prod.reviewsCount,
                        image: prod.image,
                        images: [prod.image],
                        description: "Premium Iron Street furniture design",
                        deliveryText: "Available",
                        dimensions: "Standard",
                        material: "Metal / Iron",
                        category: "Furniture",
                      ),
                    );
                    Get.snackbar(
                      'Added to Cart',
                      'Added "${prod.name}" to Cart',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 14),
                  label: Text(
                    'Add to Cart',
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
              // Remove Action
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    wishlistCtrl.toggleWishlist(prod);
                    Get.snackbar(
                      'Removed',
                      'Removed "${prod.name}" from Wishlist',
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

class EmptyWishlistState extends StatelessWidget {
  const EmptyWishlistState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 68,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Your wishlist is empty',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the heart icon on any product to save it to your wishlist!',
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
