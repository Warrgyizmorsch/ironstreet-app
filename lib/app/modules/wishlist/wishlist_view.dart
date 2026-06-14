/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'wishlist_controller.dart';
import '../cart/cart_controller.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wishlistCtrl = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());
    final cartController = Get.find<CartController>();
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

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
          'My Wishlist',
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
      body: Obx(() {
        final wishItems = wishlistCtrl.wishlistItems;

        if (wishItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 68, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'No Wishlisted Items yet',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap the heart icon on any sofa, dining table or accessories to view them here.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: wishItems.length,
          itemBuilder: (context, index) {
            final prod = wishItems[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF1F1F1)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: CachedNetworkImage(
                        imageUrl: prod.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prod.brand.toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          prod.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF222222)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatCurrency.format(prod.price),
                              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFF37021)),
                            ),

                            // Actions
                            Row(
                              children: [
                                // Add to Cart bag
                                GestureDetector(
                                  onTap: () => cartController.addToCart(prod),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: const Color(0xFFFFF0E6), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.add_shopping_cart, size: 14, color: Color(0xFFF37021)),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Delete
                                GestureDetector(
                                  onTap: () => wishlistCtrl.toggleWishlist(prod),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.close, size: 14, color: Colors.red[600]),
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
