// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/modules/category/category_controller.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'package:iron_street_app/app/routes/app_pages.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import '../../widgets/product_card.dart';
import '../../widgets/shimmer.dart';

class CategoryProductView extends GetView<CategoryController> {
  const CategoryProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();
    final cartController = Get.find<CartController>();

    final isPushed = ModalRoute.of(context)?.canPop ?? false;

    // Load category arguments if available
    final categoryId = Get.arguments as int?;
    if (categoryId != null && controller.activeProductCategoryId.value != categoryId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchProductsByCategory(categoryId);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: isPushed
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          'Iron Street',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          Obx(() {
            final int count = wishlistController.wishlistItems.length;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.black87),
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
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87),
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
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        height: 56,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFF1F1F1)),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showSortBottomSheet(context),
                  icon: const Icon(Icons.sort, color: AppColors.primary, size: 20),
                  label: Text(
                    'SORT',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF222222),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFE5E5E5),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showFilterBottomSheet(context),
                  icon: const Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                  label: Text(
                    'FILTER',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF222222),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        final products = controller.sortedAndFilteredProducts;
        final isLoading = controller.isProductsLoading.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Info Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() {
                    final activeId = controller.activeProductCategoryId.value;
                    final cat = controller.allCategories.firstWhereOrNull((c) => c.id == activeId);
                    return Text(
                      cat?.name ?? 'Category Products',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF222222),
                      ),
                    );
                  }),
                  const SizedBox(height: 2),
                  Text(
                    '${products.length} Products',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Subcategory Chips Scroll
            Obx(() {
              final rootId = controller.rootCategoryId;
              final subcategories = controller.siblingSubcategories;

              if (rootId == 0 || subcategories.isEmpty) {
                return const SizedBox.shrink();
              }

              final activeId = controller.activeProductCategoryId.value;
              final isAllActive = activeId == rootId;

              // Find parent category name
              final parentCat = controller.allCategories.firstWhereOrNull((c) => c.id == rootId);
              final parentName = parentCat?.name ?? 'Category';

              return Container(
                height: 38,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subcategories.length + 1, // +1 for "View All"
                  itemBuilder: (context, index) {
                    final isFirst = index == 0;
                    final bool isActive = isFirst ? isAllActive : (subcategories[index - 1].id == activeId);
                    final String label = isFirst ? 'View All $parentName' : subcategories[index - 1].name;
                    final int targetId = isFirst ? rootId : subcategories[index - 1].id;

                    return GestureDetector(
                      onTap: () => controller.fetchProductsByCategory(targetId),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? AppColors.primary : const Color(0xFFE5E5E5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Product Grid
            Expanded(
              child: isLoading
                  ? GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) => const ProductCardShimmer(width: double.infinity),
                    )
                  : products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category_outlined, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No products found.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 70), // Clearance padding for bottom bar
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.72,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final prod = products[index];
                            return ProductCard(
                              product: prod,
                              width: double.infinity,
                            );
                          },
                        ),
            ),

            // Fetching More Indicator
            if (controller.isFetchingMoreProducts.value)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
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
                  'Sort By',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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
            Obx(() => Column(
              children: [
                _buildSortOption(
                  title: 'Default / Popularity',
                  value: 'default',
                  selectedValue: controller.activeSortType.value,
                  onTap: () {
                    controller.activeSortType.value = 'default';
                    Get.back();
                  },
                ),
                _buildSortOption(
                  title: 'Top Rated',
                  value: 'rating',
                  selectedValue: controller.activeSortType.value,
                  onTap: () {
                    controller.activeSortType.value = 'rating';
                    Get.back();
                  },
                ),
                _buildSortOption(
                  title: 'Price: Low to High',
                  value: 'price_low_high',
                  selectedValue: controller.activeSortType.value,
                  onTap: () {
                    controller.activeSortType.value = 'price_low_high';
                    Get.back();
                  },
                ),
                _buildSortOption(
                  title: 'Price: High to Low',
                  value: 'price_high_low',
                  selectedValue: controller.activeSortType.value,
                  onTap: () {
                    controller.activeSortType.value = 'price_high_low';
                    Get.back();
                  },
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption({
    required String title,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selectedValue;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary, size: 18)
          : null,
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
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
                  'Filter by Price',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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
            Obx(() => Column(
              children: [
                _buildFilterOption(
                  title: 'All Products',
                  value: 'All',
                  selectedValue: controller.selectedPriceFilter.value,
                  onTap: () {
                    controller.selectedPriceFilter.value = 'All';
                    Get.back();
                  },
                ),
                _buildFilterOption(
                  title: 'Under ₹10,000',
                  value: 'under_10k',
                  selectedValue: controller.selectedPriceFilter.value,
                  onTap: () {
                    controller.selectedPriceFilter.value = 'under_10k';
                    Get.back();
                  },
                ),
                _buildFilterOption(
                  title: '₹10,000 - ₹20,000',
                  value: '10k_20k',
                  selectedValue: controller.selectedPriceFilter.value,
                  onTap: () {
                    controller.selectedPriceFilter.value = '10k_20k';
                    Get.back();
                  },
                ),
                _buildFilterOption(
                  title: 'Over ₹20,000',
                  value: 'over_20k',
                  selectedValue: controller.selectedPriceFilter.value,
                  onTap: () {
                    controller.selectedPriceFilter.value = 'over_20k';
                    Get.back();
                  },
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selectedValue;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary, size: 18)
          : null,
    );
  }
}
