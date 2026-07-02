// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:intl/intl.dart';
// import 'package:iron_street_app/app/utills/theme/app_colors.dart';

// import 'product_detail_controller.dart';
// import '../cart/cart_controller.dart';
// import '../wishlist/wishlist_controller.dart';

// class ProductDetailView extends GetView<ProductDetailController> {
//   const ProductDetailView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cartController = Get.find<CartController>();
//     final wishlistController = Get.find<WishlistController>();
//     final formatCurrency =
//         NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

//     final prod = controller.product;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           'Product Details',
//           style: GoogleFonts.poppins(
//               color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share_outlined, color: Colors.black87),
//             onPressed: () {
//               Get.snackbar(
//                   'Share', 'Link to ${prod.name} copied to clipboard!');
//             },
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Product Images Slider Stack
//                   Stack(
//                     children: [
//                       SizedBox(
//                         height: 320,
//                         child: PageView.builder(
//                           itemCount:
//                               prod.images.isNotEmpty ? prod.images.length : 1,
//                           onPageChanged: (index) =>
//                               controller.updateImageIndex(index),
//                           itemBuilder: (context, index) {
//                             String url = prod.images.isNotEmpty
//                                 ? prod.images[index]
//                                 : prod.image;
//                             return CachedNetworkImage(
//                               imageUrl: url,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 12,
//                         left: 0,
//                         right: 0,
//                         child: Obx(() {
//                           int total =
//                               prod.images.isNotEmpty ? prod.images.length : 1;
//                           return Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: List.generate(
//                               total,
//                               (index) => Container(
//                                 width: 6,
//                                 height: 6,
//                                 margin:
//                                     const EdgeInsets.symmetric(horizontal: 3),
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   color: controller.selectedImageIndex.value ==
//                                           index
//                                       ? const Color(0xFFF37021)
//                                       : Colors.white.withOpacity(0.5),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//                       )
//                     ],
//                   ),

//                   // Info details padding
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           prod.brand.toUpperCase(),
//                           style: GoogleFonts.poppins(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.grey[500],
//                             letterSpacing: 1.0,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           prod.name,
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF222222),
//                             height: 1.3,
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         // Rating row
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: Colors.green[50],
//                                 border: Border.all(color: Colors.green[100]!),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(Icons.star,
//                                       color: Colors.green, size: 12),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     '${prod.rating}',
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green,
//                                         fontSize: 11),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               '${prod.reviewsCount} Buyer Ratings',
//                               style: GoogleFonts.poppins(
//                                   fontSize: 11, color: Colors.grey[600]),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),

//                         // Price Row details
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.baseline,
//                           textBaseline: TextBaseline.alphabetic,
//                           children: [
//                             Text(
//                               formatCurrency.format(prod.price),
//                               style: GoogleFonts.poppins(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w900,
//                                   color: AppColors.primary),
//                             ),
//                             const SizedBox(width: 12),
//                             if (prod.oldPrice > prod.price) ...[
//                               Text(
//                                 formatCurrency.format(prod.oldPrice),
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 13,
//                                   color: Colors.grey,
//                                   decoration: TextDecoration.lineThrough,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 '${prod.discount.toStringAsFixed(0)}% OFF',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.green[600],
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),

//                         // Delivery speed banner
//                         const SizedBox(height: 16),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 10),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFFAF9F6),
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(color: const Color(0xFFF1F1F1)),
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(Icons.local_shipping_outlined,
//                                   color: AppColors.primary, size: 18),
//                               const SizedBox(width: 10),
//                               Text(
//                                 prod.deliveryText,
//                                 style: GoogleFonts.poppins(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.grey[700]),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Specification panels details (Description, Dimensions, Material etc.)
//                         const SizedBox(height: 24),
//                         _buildSectionExpandable(
//                             'Product Description', prod.description),
//                         _buildSectionExpandable(
//                             'Material & Finish Used', prod.material),
//                         _buildSectionExpandable(
//                             'Product Dimensions Details', prod.dimensions),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),

//           // Floating CTA bottom control bar
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, -2),
//                 )
//               ],
//               border: const Border(top: BorderSide(color: Color(0xFFF1F1F1))),
//             ),
//             child: Row(
//               children: [
//                 // Wishlist Toggle Circle Option
//                 Obx(() {
//                   bool isHearted = wishlistController.isWishlisted(prod.id);
//                   return GestureDetector(
//                     onTap: () => wishlistController.toggleWishlist(prod),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: const Color(0xFFE5E5E5)),
//                       ),
//                       child: Icon(
//                         isHearted ? Icons.favorite : Icons.favorite_border,
//                         color: isHearted ? Colors.red : Colors.grey[700],
//                         size: 22,
//                       ),
//                     ),
//                   );
//                 }),
//                 const SizedBox(width: 12),

//                 // Primary Add to Bag Action Button
//                 Expanded(
//                   child: SizedBox(
//                     height: 48,
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12)),
//                       ),
//                       onPressed: () => cartController.addToCart(prod),
//                       icon: const Icon(Icons.shopping_bag_outlined,
//                           color: Colors.white),
//                       label: Text(
//                         'Add to Shopping Bag',
//                         style: GoogleFonts.poppins(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 13),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionExpandable(String head, String detail) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: const BoxDecoration(
//         border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
//       ),
//       child: ExpansionTile(
//         title: Text(
//           head,
//           style: GoogleFonts.poppins(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF444444)),
//         ),
//         tilePadding: EdgeInsets.zero,
//         childrenPadding: const EdgeInsets.only(bottom: 12),
//         children: [
//           Align(
//             alignment: Alignment.centerLeft,
//             child: Text(
//               detail,
//               style: GoogleFonts.poppins(
//                   fontSize: 11, color: Colors.grey[700], height: 1.5),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/data/models/product_model.dart';
import 'package:iron_street_app/app/data/models/related_product_list.dart';
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

    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      final prod = controller.productDetail.value;

      if (prod == null) {
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
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          body: const Center(
            child: Text('No product details found'),
          ),
        );
      }

      final double price = _toDouble(prod.price);
      final double salePrice = _toDouble(prod.salePrice);
      final double regularPrice = _toDouble(prod.regularPrice);

      final double displayPrice = salePrice > 0 ? salePrice : price;
      final double oldPrice = regularPrice > displayPrice ? regularPrice : 0;
      final double discount = _calculateDiscount(oldPrice, displayPrice);

      final String brandName = _getAttributeValue(prod, 'Brand Name');
      final String material = _getAttributeValue(prod, 'Frame Material');
      final String tableTopMaterial =
          _getAttributeValue(prod, 'Table Top Material');
      final String dimensions =
          _getAttributeValue(prod, 'Dimensions(L x W x H)');
      final String deliveryCondition =
          _getAttributeValue(prod, 'Delivery Condition');
      final String careInstructions =
          _getAttributeValue(prod, 'Care Instructions');

      final List<String> imageUrls = prod.images.map((e) => e.src).toList();

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
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.black87),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: prod.permalink));
                Get.snackbar(
                  'Share',
                  'Product link copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
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
                    Stack(
                      children: [
                        SizedBox(
                          height: 320,
                          child: PageView.builder(
                            itemCount:
                                imageUrls.isNotEmpty ? imageUrls.length : 1,
                            onPageChanged: (index) {
                              controller.changeImage(index);
                            },
                            itemBuilder: (context, index) {
                              final String imageUrl =
                                  imageUrls.isNotEmpty ? imageUrls[index] : '';

                              if (imageUrl.isEmpty) {
                                return Container(
                                  color: const Color(0xFFF7F7F7),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFFF7F7F7),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFFF7F7F7),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _buildStockBadge(prod.stockStatus),
                        ),
                        if (prod.onSale)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${discount.toStringAsFixed(0)}% OFF',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Obx(() {
                            final int total =
                                imageUrls.isNotEmpty ? imageUrls.length : 1;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                total,
                                (index) => Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        controller.selectedImageIndex.value ==
                                                index
                                            ? const Color(0xFFF37021)
                                            : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    if (imageUrls.length > 1)
                      SizedBox(
                        height: 76,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            return Obx(() {
                              final bool selected =
                                  controller.selectedImageIndex.value == index;

                              return GestureDetector(
                                onTap: () {
                                  controller.changeImage(index);
                                },
                                child: Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : const Color(0xFFE5E5E5),
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrls[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (brandName.isNotEmpty)
                            Text(
                              brandName.toUpperCase(),
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
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF222222),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (prod.categories.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: prod.categories
                                  .map(
                                    (cat) => _buildSmallChip(cat.name),
                                  )
                                  .toList(),
                            ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  border: Border.all(
                                    color: Colors.green[100]!,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      prod.averageRating,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${prod.ratingCount} Buyer Ratings',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                prod.sku.isNotEmpty ? 'SKU: ${prod.sku}' : '',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                formatCurrency.format(displayPrice),
                                style: GoogleFonts.poppins(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (oldPrice > 0) ...[
                                Text(
                                  formatCurrency.format(oldPrice),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${discount.toStringAsFixed(0)}% OFF',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF9F6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFF1F1F1),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_shipping_outlined,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    deliveryCondition.isNotEmpty
                                        ? deliveryCondition
                                        : prod.stockStatus == 'instock'
                                            ? 'Available for delivery'
                                            : 'Currently unavailable',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _buildMiniInfoCard(
                                icon: Icons.verified_outlined,
                                title: 'Purchasable',
                                value: prod.purchasable ? 'Yes' : 'No',
                              ),
                              const SizedBox(width: 10),
                              _buildMiniInfoCard(
                                icon: Icons.inventory_2_outlined,
                                title: 'Stock',
                                value: _formatStock(prod.stockStatus),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildMiniInfoCard(
                                icon: Icons.sell_outlined,
                                title: 'Sale',
                                value: prod.onSale ? 'On Sale' : 'Regular',
                              ),
                              const SizedBox(width: 10),
                              _buildMiniInfoCard(
                                icon: Icons.link_outlined,
                                title: 'Product ID',
                                value: prod.id.toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (material.isNotEmpty ||
                              tableTopMaterial.isNotEmpty ||
                              dimensions.isNotEmpty)
                            _buildQuickSpecs(
                              material: material,
                              tableTopMaterial: tableTopMaterial,
                              dimensions: dimensions,
                            ),
                          const SizedBox(height: 20),
                          _buildSectionExpandable(
                            'Product Description',
                            _cleanHtml(prod.description),
                          ),
                          if (prod.shortDescription.isNotEmpty)
                            _buildSectionExpandable(
                              'Short Description',
                              _cleanHtml(prod.shortDescription),
                            ),
                          if (prod.attributes.isNotEmpty)
                            _buildAttributesSection(prod.attributes),
                          if (careInstructions.isNotEmpty)
                            _buildSectionExpandable(
                              'Care Instructions',
                              careInstructions,
                            ),
                          _buildProductInfoSection(prod),
                          // if (prod.relatedIds.isNotEmpty)
                          //   _buildRelatedIdsSection(prod.relatedIds),
                          _buildRelatedProductsSection(controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: Color(0xFFF1F1F1)),
                ),
              ),
              child: Row(
                children: [
                  Obx(() {
                    final bool isHearted =
                        wishlistController.isWishlisted(prod.id.toString());

                    return GestureDetector(
                      onTap: () => wishlistController.toggleWishlist(Product(
                          id: prod.id.toString(),
                          name: prod.name,
                          brand: "LuxeLiving by Iron Street",
                          price: price,
                          oldPrice: oldPrice,
                          discount: discount,
                          rating: prod.ratingCount.toDouble(),
                          reviewsCount: prod.ratingCount,
                          image: prod.images.first.src,
                          images: [prod.images.first.src],
                          description: prod.description,
                          deliveryText: 'Available',
                          dimensions: dimensions,
                          material: material,
                          category: prod.categories.first.name)),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E5E5),
                          ),
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
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              prod.purchasable && prod.stockStatus == 'instock'
                                  ? AppColors.primary
                                  : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed:
                            prod.purchasable && prod.stockStatus == 'instock'
                                ? () => cartController.addToCart(Product(
                                    id: prod.id.toString(),
                                    name: prod.name,
                                    brand: "LuxeLiving by Iron Street",
                                    price: price,
                                    oldPrice: oldPrice,
                                    discount: discount,
                                    rating: prod.ratingCount.toDouble(),
                                    reviewsCount: prod.ratingCount,
                                    image: prod.images.first.src,
                                    images: [prod.images.first.src],
                                    description: prod.description,
                                    deliveryText: 'Available',
                                    dimensions: dimensions,
                                    material: material,
                                    category: prod.categories.first.name))
                                : null,
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          prod.stockStatus == 'instock'
                              ? 'Add to Shopping Bag'
                              : 'Out of Stock',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRelatedProductsSection(ProductDetailController controller) {
    return Obx(() {
      if (controller.isRelatedProductsLoading.value) {
        return Container(
          margin: const EdgeInsets.only(top: 8, bottom: 20),
          height: 210,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.relatedProducts.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Related Products',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 235,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.relatedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = controller.relatedProducts[index];

                return _buildRelatedProductCard(
                  product: item,
                  onTap: () => controller.openRelatedProduct(item),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRelatedProductCard({
    required ProductRelatedListModel product,
    required VoidCallback onTap,
  }) {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final double price = double.tryParse(product.price.toString()) ?? 0;
    final double oldPrice =
        double.tryParse(product.regularPrice.toString()) ?? 0;

    final String imageUrl =
        product.images.isNotEmpty ? product.images.first.src : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEFEFEF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Container(
                height: 125,
                width: double.infinity,
                color: const Color(0xFFF7F7F7),
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF222222),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        formatCurrency.format(price),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (oldPrice > price && oldPrice > 0)
                        Expanded(
                          child: Text(
                            formatCurrency.format(oldPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F1F1)),
                    ),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockBadge(String stockStatus) {
    final bool inStock = stockStatus == 'instock';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: inStock ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        inStock ? 'In Stock' : 'Out of Stock',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSmallChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMiniInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F1F1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSpecs({
    required String material,
    required String tableTopMaterial,
    required String dimensions,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Quick Specifications'),
          const SizedBox(height: 10),
          if (material.isNotEmpty) _buildInfoRow('Frame Material', material),
          if (tableTopMaterial.isNotEmpty)
            _buildInfoRow('Table Top Material', tableTopMaterial),
          if (dimensions.isNotEmpty) _buildInfoRow('Dimensions', dimensions),
        ],
      ),
    );
  }

  Widget _buildAttributesSection(List<dynamic> attributes) {
    final visibleAttributes = attributes.where((attr) {
      return attr.visible == true && attr.options.isNotEmpty;
    }).toList();

    if (visibleAttributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5F5F5)),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          'All Product Specifications',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF444444),
          ),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            child: Column(
              children: visibleAttributes.map((attr) {
                return _buildInfoRow(
                  attr.name,
                  attr.options.join(', '),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoSection(dynamic prod) {
    final List<Map<String, String>> rows = [
      {'label': 'Product ID', 'value': prod.id.toString()},
      {'label': 'SKU', 'value': prod.sku},
      {'label': 'Slug', 'value': prod.slug},
      {'label': 'Stock Status', 'value': _formatStock(prod.stockStatus)},
      {'label': 'Average Rating', 'value': prod.averageRating},
      {'label': 'Rating Count', 'value': prod.ratingCount.toString()},
      {'label': 'Purchasable', 'value': prod.purchasable ? 'Yes' : 'No'},
      {'label': 'On Sale', 'value': prod.onSale ? 'Yes' : 'No'},
      {'label': 'Product URL', 'value': prod.permalink},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5F5F5)),
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          'More Product Information',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF444444),
          ),
        ),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEFEFEF)),
            ),
            child: Column(
              children: rows
                  .where(
                      (row) => row['value'] != null && row['value']!.isNotEmpty)
                  .map(
                    (row) => _buildInfoRow(
                      row['label']!,
                      row['value']!,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedIdsSection(List<int> relatedIds) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5F5F5)),
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          'Related Products',
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF444444),
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: relatedIds
                  .map(
                    (id) => _buildSmallChip('Product #$id'),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionExpandable(String head, String detail) {
    if (detail.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5F5F5)),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: head == 'Product Description',
        title: Text(
          head,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF444444),
          ),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              detail,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5F5F5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _getAttributeValue(dynamic product, String name) {
    try {
      final attr = product.attributes.firstWhereOrNull(
        (e) => e.name.toString().toLowerCase() == name.toLowerCase(),
      );

      if (attr == null || attr.options.isEmpty) {
        return '';
      }

      return attr.options.join(', ');
    } catch (_) {
      return '';
    }
  }

  String _cleanHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8377;', '₹')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatStock(String stockStatus) {
    switch (stockStatus) {
      case 'instock':
        return 'In Stock';
      case 'outofstock':
        return 'Out of Stock';
      case 'onbackorder':
        return 'On Backorder';
      default:
        return stockStatus;
    }
  }

  double _toDouble(String value) {
    return double.tryParse(value.replaceAll(',', '').trim()) ?? 0;
  }

  double _calculateDiscount(double oldPrice, double newPrice) {
    if (oldPrice <= 0 || newPrice <= 0 || oldPrice <= newPrice) {
      return 0;
    }

    return ((oldPrice - newPrice) / oldPrice) * 100;
  }
}
