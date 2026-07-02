

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';

import 'product_detail_controller.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final wishlistController = Get.find<WishlistController>();
    final formatCurrency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final prod = controller.product;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.poppins(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {
              Get.snackbar(
                  'Share', 'Link to ${prod.name} copied to clipboard!');
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images Slider Stack
                  Stack(
                    children: [
                      SizedBox(
                        height: 320,
                        child: PageView.builder(
                          itemCount:
                              prod.images.isNotEmpty ? prod.images.length : 1,
                          onPageChanged: (index) =>
                              controller.updateImageIndex(index),
                          itemBuilder: (context, index) {
                            String url = prod.images.isNotEmpty
                                ? prod.images[index]
                                : prod.image;
                            return CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Obx(() {
                          int total =
                              prod.images.isNotEmpty ? prod.images.length : 1;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              total,
                              (index) => Container(
                                width: 6,
                                height: 6,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: controller.selectedImageIndex.value ==
                                          index
                                      ? const Color(0xFFF37021)
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          );
                        }),
                      )
                    ],
                  ),

                  // Info details padding
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.brand.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[500],
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          prod.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF222222),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                border: Border.all(color: Colors.green[100]!),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.green, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${prod.rating}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${prod.reviewsCount} Buyer Ratings',
                              style: GoogleFonts.poppins(
                                  fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Price Row details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formatCurrency.format(prod.price),
                              style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            if (prod.oldPrice > prod.price) ...[
                              Text(
                                formatCurrency.format(prod.oldPrice),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${prod.discount.toStringAsFixed(0)}% OFF',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Delivery speed banner
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF1F1F1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 10),
                              Text(
                                prod.deliveryText,
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),

                        // Specification panels details (Description, Dimensions, Material etc.)
                        const SizedBox(height: 24),
                        _buildSectionExpandable(
                            'Product Description', prod.description),
                        _buildSectionExpandable(
                            'Material & Finish Used', prod.material),
                        _buildSectionExpandable(
                            'Product Dimensions Details', prod.dimensions),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),

          // Floating CTA bottom control bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
              border: const Border(top: BorderSide(color: Color(0xFFF1F1F1))),
            ),
            child: Row(
              children: [
                // Wishlist Toggle Circle Option
                Obx(() {
                  bool isHearted = wishlistController.isWishlisted(prod.id);
                  return GestureDetector(
                    onTap: () => wishlistController.toggleWishlist(prod),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Icon(
                        isHearted ? Icons.favorite : Icons.favorite_border,
                        color: isHearted ? Colors.red : Colors.grey[700],
                        size: 22,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 12),

                // Primary Add to Bag Action Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => cartController.addToCart(prod),
                      icon: const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white),
                      label: Text(
                        'Add to Shopping Bag',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionExpandable(String head, String detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: ExpansionTile(
        title: Text(
          head,
          style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF444444)),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              detail,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey[700], height: 1.5),
            ),
          )
        ],
      ),
    );
  }
}
