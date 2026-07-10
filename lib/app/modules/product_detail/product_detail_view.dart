// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/models/product_model.dart';
import 'package:iron_street_app/app/data/models/product_review_model.dart';
import 'package:iron_street_app/app/modules/product_detail/widget/full_screen_image.dart';
import 'package:iron_street_app/app/routes/app_pages.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import '../../widgets/shimmer.dart';
import '../../widgets/product_card.dart';
import 'package:share_plus/share_plus.dart';

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
          body: const ProductDetailShimmer(),
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
            Obx(() {
              final int count = wishlistController.wishlistItems.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border,
                        color: Colors.black87),
                    onPressed: () => Get.toNamed(Routes.WISHLIST),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
            Obx(() {
              final int count = cartController.totalCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined,
                        color: Colors.black87),
                    onPressed: () => Get.toNamed(Routes.CART),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }),
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
                            controller: controller.imagePageController,
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

                              return GestureDetector(
                                onTap: () {
                                  _openImagePreview(
                                    images: imageUrls,
                                    initialIndex: index,
                                  );
                                },
                                child: Hero(
                                  tag: 'product-image-$index',
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => Shimmer(
                                      child: Container(
                                        color: Colors.black,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: const Color(0xFFF7F7F7),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image_outlined,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
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
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.share_outlined,
                                  size: 20, color: Colors.black87),
                              onPressed: () async {
                                final box =
                                    context.findRenderObject() as RenderBox?;
                                await SharePlus.instance.share(
                                  ShareParams(
                                    text: prod.permalink,
                                    title: 'Share Via',
                                    subject: prod.name,
                                    sharePositionOrigin: box == null
                                        ? null
                                        : box.localToGlobal(Offset.zero) &
                                            box.size,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Obx(() {
                            final isHearted =
                                wishlistController.isInWishlist(prod.id);
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isHearted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 20,
                                  color:
                                      isHearted ? Colors.red : Colors.black87,
                                ),
                                onPressed: () =>
                                    wishlistController.toggleWishlist(
                                  ProductListModel(
                                    id: prod.id,
                                    name: prod.name,
                                    price: price,
                                    oldPrice: oldPrice,
                                    discount: discount,
                                    image: prod.images.first.src,
                                    brand: brandName.isNotEmpty
                                        ? brandName
                                        : "LuxeLiving by Iron Street",
                                    rating:
                                        double.tryParse(prod.averageRating) ??
                                            0.0,
                                    reviewsCount: prod.ratingCount,
                                  ),
                                ),
                              ),
                            );
                          }),
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
                                  _openImagePreview(
                                    images: imageUrls,
                                    initialIndex: index,
                                  );
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
                          // const SizedBox(height: 20),
                          // _buildSectionExpandable(
                          //   'Product Description',
                          //   _cleanHtml(prod.description),
                          // ),
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
                          _buildReviewsSection(controller),
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
                  // Add to Cart Button
                  Expanded(
                    child: Obx(() {
                      final bool productInCart =
                          cartController.isInCart(prod.id.toString());

                      return SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: prod.purchasable &&
                                      prod.stockStatus == 'instock'
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: prod.purchasable &&
                                  prod.stockStatus == 'instock'
                              ? () => productInCart
                                  ? Get.toNamed(Routes.CART)
                                  : cartController.addToCart(Product(
                                      id: prod.id.toString(),
                                      name: prod.name,
                                      brand: brandName.isNotEmpty
                                          ? brandName
                                          : "LuxeLiving by Iron Street",
                                      price: price,
                                      oldPrice: oldPrice,
                                      discount: discount,
                                      rating:
                                          double.tryParse(prod.averageRating) ??
                                              0.0,
                                      reviewsCount: prod.ratingCount,
                                      image: prod.images.first.src,
                                      images: [prod.images.first.src],
                                      description: prod.description,
                                      deliveryText: 'Available',
                                      dimensions: dimensions,
                                      material: material,
                                      category: prod.categories.isNotEmpty
                                          ? prod.categories.first.name
                                          : 'Furniture'))
                              : null,
                          icon: Icon(
                            productInCart
                                ? Icons.shopping_cart_checkout
                                : Icons.shopping_bag_outlined,
                            size: 18,
                          ),
                          label: Text(
                            prod.stockStatus == 'instock'
                                ? productInCart
                                    ? 'Go to Cart'
                                    : 'Add to Cart'
                                : 'Out of Stock',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  // Buy Now Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              prod.purchasable && prod.stockStatus == 'instock'
                                  ? AppColors.primary
                                  : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: prod.purchasable &&
                                prod.stockStatus == 'instock'
                            ? () async {
                                final bool productInCart =
                                    cartController.isInCart(prod.id.toString());
                                if (!productInCart) {
                                  cartController.addToCart(Product(
                                      id: prod.id.toString(),
                                      name: prod.name,
                                      brand: brandName.isNotEmpty
                                          ? brandName
                                          : "LuxeLiving by Iron Street",
                                      price: price,
                                      oldPrice: oldPrice,
                                      discount: discount,
                                      rating:
                                          double.tryParse(prod.averageRating) ??
                                              0.0,
                                      reviewsCount: prod.ratingCount,
                                      image: prod.images.first.src,
                                      images: [prod.images.first.src],
                                      description: prod.description,
                                      deliveryText: 'Available',
                                      dimensions: dimensions,
                                      material: material,
                                      category: prod.categories.isNotEmpty
                                          ? prod.categories.first.name
                                          : 'Furniture'));
                                }
                                await Future.delayed(Duration.zero);
                                Get.toNamed(Routes.CHECKOUT);
                              }
                            : null,
                        child: Text(
                          'Buy Now',
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

  void _openImagePreview({
    required List<String> images,
    required int initialIndex,
  }) {
    if (images.isEmpty) return;

    Get.to(
      () => FullScreenImageViewer(
        images: images,
        initialIndex: initialIndex,
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  Widget _buildRelatedProductsSection(ProductDetailController controller) {
    return Obx(() {
      if (controller.isRelatedProductsLoading.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 140,
              height: 14,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(
              height: 235,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return const ProductCardShimmer(width: 155);
                },
              ),
            ),
          ],
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

                return ProductCard(
                  product: item,
                  width: 155,
                  onTap: () => controller.openRelatedProduct(item),
                );
              },
            ),
          ),
        ],
      );
    });
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

  Widget _buildReviewsSection(ProductDetailController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5F5F5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF222222),
                ),
              ),
              Obx(() {
                final count = controller.reviewsList.length;
                return Text(
                  count > 0 ? '$count Review${count > 1 ? 's' : ''}' : '',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isReviewsLoading.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading reviews...',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.reviewsList.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1F1F1)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 36,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No Reviews Yet',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to share your experience with this product.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Calculations for overview
            final reviews = controller.reviewsList;
            final int total = reviews.length;
            double sum = 0;
            final Map<int, int> ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
            for (var r in reviews) {
              sum += r.rating;
              ratingCounts[r.rating] = (ratingCounts[r.rating] ?? 0) + 1;
            }
            final double average = total > 0 ? sum / total : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF9F6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1F1F1)),
                  ),
                  child: Row(
                    children: [
                      // Average Rating Column
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              average.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            _buildReviewStars(average, size: 16),
                            const SizedBox(height: 6),
                            Text(
                              'Based on $total review${total > 1 ? 's' : ''}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(
                        height: 70,
                        width: 1,
                        color: const Color(0xFFE5E5E5),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      // Rating bars column
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((stars) {
                            final count = ratingCounts[stars] ?? 0;
                            final double pct = total > 0 ? count / total : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(
                                    '$stars ★',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 6,
                                        backgroundColor:
                                            const Color(0xFFE5E5E5),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          stars >= 4
                                              ? Colors.green[600]!
                                              : stars == 3
                                                  ? Colors.amber[600]!
                                                  : Colors.orange[600]!,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 16,
                                    child: Text(
                                      count.toString(),
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Display the first review
                _buildReviewItem(reviews.first),
                if (total > 1) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Get.toNamed(Routes.PRODUCT_REVIEWS),
                      child: Text(
                        'See All $total Reviews',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewStars(double rating, {double size = 14}) {
    int fullStars = rating.floor();
    bool hasHalf = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, size: size, color: Colors.amber[700]);
        } else if (index == fullStars && hasHalf) {
          return Icon(Icons.star_half, size: size, color: Colors.amber[700]);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.amber[700]);
        }
      }),
    );
  }

  Widget _buildReviewItem(ProductReviewModel review) {
    // Format date
    String dateStr = review.dateCreated;
    try {
      final DateTime parsed = DateTime.parse(review.dateCreated);
      dateStr = DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {}

    final avatarUrl = review.reviewerAvatarUrls.size96.isNotEmpty
        ? review.reviewerAvatarUrls.size96
        : (review.reviewerAvatarUrls.size48.isNotEmpty
            ? review.reviewerAvatarUrls.size48
            : review.reviewerAvatarUrls.size24);

    final initial = review.reviewer.isNotEmpty
        ? review.reviewer.trim().substring(0, 1).toUpperCase()
        : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                color: Colors.grey[200],
                child: avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // Reviewer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          review.reviewer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (review.verified) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified,
                                  size: 10, color: Colors.green[700]),
                              const SizedBox(width: 2),
                              Text(
                                'Verified',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            // Stars
            _buildReviewStars(review.rating.toDouble(), size: 12),
          ],
        ),
        const SizedBox(height: 10),
        // Review Text
        Text(
          _cleanHtml(review.review),
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
