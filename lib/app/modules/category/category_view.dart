// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iron_street_app/app/utills/theme/app_colors.dart';

// import 'category_controller.dart';
// import '../../widgets/product_card.dart';

// class CategoryView extends GetView<CategoryController> {
//   final String? initialSearchQuery;

//   const CategoryView({super.key, this.initialSearchQuery});

//   @override
//   Widget build(BuildContext context) {
//     // Put / Find controller depending on widget scope instantiation
//     final catController = Get.isRegistered<CategoryController>()
//         ? Get.find<CategoryController>()
//         : Get.put(CategoryController());

//     if (initialSearchQuery != null) {
//       catController.searchQuery.value = initialSearchQuery!;
//     }

//     final categories = ['All', 'Living', 'Bedroom', 'Dining'];

//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F6F6),
//       body: Obx(() {
//         final products = catController.sortedProducts;

//         return Column(
//           children: [
//             // Horizontal categories scroll
//             Container(
//               height: 48,
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               color: Colors.white,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final cat = categories[index];
//                   final isActive = catController.selectedCategory.value == cat;
//                   return GestureDetector(
//                     onTap: () => catController.selectCategory(cat),
//                     child: Container(
//                       margin: const EdgeInsets.only(right: 8),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: isActive
//                             ? const Color(0xFFFFF0E6)
//                             : Colors.transparent,
//                         border: Border.all(
//                           color: isActive
//                               ? AppColors.primary
//                               : const Color(0xFFE5E5E5),
//                         ),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         cat,
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           color:
//                               isActive ? AppColors.primary : Colors.grey[700],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Sorting and item count bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.sort,
//                           size: 16, color: AppColors.primary),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Sort By: ',
//                         style: GoogleFonts.poppins(
//                             fontSize: 11,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.bold),
//                       ),
//                       DropdownButton<String>(
//                         value: catController.sortBy.value,
//                         underline: const SizedBox(),
//                         iconSize: 16,
//                         style: GoogleFonts.poppins(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w800,
//                             color: const Color(0xFF222222)),
//                         onChanged: (val) {
//                           if (val != null) catController.updateSort(val);
//                         },
//                         items: const [
//                           DropdownMenuItem(
//                               value: 'rating', child: Text('Top Rated')),
//                           DropdownMenuItem(
//                               value: 'priceLowHigh',
//                               child: Text('Price: Low to High')),
//                           DropdownMenuItem(
//                               value: 'priceHighLow',
//                               child: Text('Price: High to Low')),
//                         ],
//                       )
//                     ],
//                   ),
//                   Text(
//                     '${products.length} items found',
//                     style: GoogleFonts.poppins(
//                         fontSize: 10,
//                         color: Colors.grey,
//                         fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//             ),

//             // Products Grid
//             Expanded(
//               child: products.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.category_outlined,
//                               size: 48, color: Colors.grey[400]),
//                           const SizedBox(height: 12),
//                           Text(
//                             'No products found.',
//                             style: GoogleFonts.poppins(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     )
//                   : GridView.builder(

//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       physics: const BouncingScrollPhysics(),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 0.60,
//                       ),
//                       itemCount: products.length,
//                       itemBuilder: (context, index) {
//                         return ProductCard(
//                           product: products[index],
//                           width: double.infinity,
//                         );
//                       },
//                     ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/data/models/product_model.dart';
import 'package:iron_street_app/app/modules/home/home_controller.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';

import '../../widgets/product_card.dart';

class CategoryView extends GetView<HomeController> {
  final String? initialSearchQuery;

  const CategoryView({super.key, this.initialSearchQuery});

  @override
  Widget build(BuildContext context) {
    // 1. Find the HomeController that is already running from the Home Screen
    final controller = Get.find<HomeController>();

    if (initialSearchQuery != null) {
      controller.searchQuery.value = initialSearchQuery!;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Obx(() {
        // 2. Get LIVE products and loading state from HomeController
        final products = controller.products;
        final isLoading = controller.isProductsLoading.value;

        return Column(
          children: [
            // --- Horizontal Categories Scroll Tabs ---
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount:
                    controller.mainCategories.length, // 3. LIVE API Categories
                itemBuilder: (context, index) {
                  final cat = controller.mainCategories[index];

                  // Check if this tab is the active one
                  final isActive = controller.activeProductCategoryId == cat.id;

                  return GestureDetector(
                    onTap: () {
                      // 4. Trigger the API to fetch products for this Category!
                      controller.fetchProductsByCategory(cat.id);
                      log('message tab hit');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFFFF0E6)
                            : Colors.transparent,
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : const Color(0xFFE5E5E5),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cat.name, // Display API Name
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              isActive ? AppColors.primary : Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- Sorting and Item Count Bar (UI Untouched) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sort,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Sort By: ',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold),
                      ),
                      DropdownButton<String>(
                        value: 'rating', // Placeholder for now
                        underline: const SizedBox(),
                        iconSize: 16,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF222222)),
                        onChanged: (val) {
                          // Sort logic can go here later
                        },
                        items: const [
                          DropdownMenuItem(
                              value: 'rating', child: Text('Top Rated')),
                          DropdownMenuItem(
                              value: 'priceLowHigh',
                              child: Text('Price: Low to High')),
                          DropdownMenuItem(
                              value: 'priceHighLow',
                              child: Text('Price: High to Low')),
                        ],
                      )
                    ],
                  ),
                  Text(
                    '${products.length} items found', // Live count
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // --- Products Grid ---
            Expanded(
              child: isLoading
                  ? const Center(
                      // Show loading spinner when fetching new category products
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.category_outlined,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No products found.',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Obx(
                          () => GridView.builder(
                            // 5. CRITICAL: Attach the ScrollController for Infinite Scrolling
                            controller: controller.scrollController,

                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.60,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final prod = products[index];
                              return ProductCard(
                                productListModel: prod,

                                product: Product(
                                    id: prod.id.toString(),
                                    name: prod.name,
                                    brand: prod.brand,
                                    price: prod.price,
                                    oldPrice: prod.oldPrice,
                                    discount: prod.discount,
                                    rating: prod.rating,
                                    reviewsCount: prod.rating.toInt(),
                                    image: prod.image,
                                    images: [],
                                    description: prod.description,
                                    deliveryText: '',
                                    dimensions: 'dimensions',
                                    material: 'material',
                                    category: 'category'),
                                width: double.infinity,
                              );
                            },
                          ),
                        ),
            ),

            // 6. Tiny loading indicator at the very bottom when loading Page 2, 3...
            if (controller.isFetchingMoreProducts.value)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              ),
          ],
        );
      }),
    );
  }
}
