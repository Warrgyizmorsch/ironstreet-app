/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import 'cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Shopping Bag',
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        actions: [
          Obx(() {
            if (controller.cartItems.isEmpty) return const SizedBox();
            return TextButton(
              onPressed: () => controller.clearCart(),
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(color: Colors.red[600], fontWeight: FontWeight.bold, fontSize: 11),
              ),
            );
          })
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 68, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Your shopping bag is empty!',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore our premium furniture collection and add some warm layouts to your home!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // List of cart items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  final prod = item.product;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFF1F1F1)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                        // Details
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
                                  // Price
                                  Text(
                                    formatCurrency.format(prod.price),
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFFF37021)),
                                  ),

                                  // Inc/Dec Controls
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => controller.updateQuantity(prod.id, -1),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                                          child: const Icon(Icons.remove, size: 12, color: Colors.black87),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '${item.quantity.value}',
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => controller.updateQuantity(prod.id, 1),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                                          child: const Icon(Icons.add, size: 12, color: Colors.black87),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Trash option
                                      GestureDetector(
                                        onTap: () => controller.removeItem(prod.id),
                                        child: Icon(Icons.delete_outline, size: 16, color: Colors.red[600]),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),

            // Billing layout panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildInvoiceLine('Subtotal Items Price', formatCurrency.format(controller.oldSubtotal)),
                  _buildInvoiceLine('Special Store Coupon discount', '- ${formatCurrency.format(controller.discountAmount)}', isGreen: true),
                  _buildInvoiceLine('Delivery & Sizing charges', controller.deliveryPrice > 0 ? formatCurrency.format(controller.deliveryPrice) : 'FREE'),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Billing Amount',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        formatCurrency.format(controller.totalAmount),
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFFF37021)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Checkout Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF37021),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Confirming Order',
                          middleText: 'Are you sure you want to complete this purchase and schedules delivery?',
                          textConfirm: 'Place Order',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          buttonColor: const Color(0xFFF37021),
                          onConfirm: () {
                            controller.clearCart();
                            Get.back(); // close modal
                            Get.back(); // close cart view
                            Get.snackbar(
                              'Order Confirmed!',
                              'Check your registered mobile / email for tracking details.',
                              backgroundColor: Colors.green[50],
                              colorText: Colors.green[800],
                            );
                          },
                        );
                      },
                      child: Text(
                        'Proceed to Checkout',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }),
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
