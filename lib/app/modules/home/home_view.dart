// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iron_street_app/app/utills/constant/images.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/utills/helpers/helpers.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'package:iron_street_app/app/routes/app_pages.dart';

import 'home_controller.dart';
import '../category/category_view.dart';
import '../account/account_view.dart';
import '../../widgets/app_header.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/section_header.dart';
import '../../widgets/why_choose_iron_street_section.dart';
import '../../widgets/shimmer.dart';
import '../../data/dummy_data.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  HomeController get controller => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      appBar: AppHeader(
        onMenuClick: () => controller.openDrawer(),
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Global Search Bar linked to query filter
          Obx(() {
            if (controller.currentIndex.value == 0 ||
                controller.currentIndex.value == 1) {
              return CustomSearchBar(
                value: controller.searchQuery.value,
                onChanged: controller.onSearchChanged,
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          // Content view switcher
          Expanded(
            child: Obx(() {
              if (controller.searchQuery.value.trim().isNotEmpty) {
                // If searching, render catalog automatically
                return CategoryView(
                  initialSearchQuery: controller.searchQuery.value,
                );
              }

              switch (controller.currentIndex.value) {
                case 1:
                  return const CategoryView();
                case 2:
                  return _buildCallBackView();
                case 3:
                  return _buildStoresView();
                case 4:
                  return const AccountView();
                case 0:
                default:
                  return _buildHomeSubView();
              }
            }),
          ),
        ],
      ),
      floatingActionButton: _buildWhatsAppFAB(),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).cardColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Iron Street',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EXPERIENCE STORE APP',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerSectionTitle('COLLECTIONS'),
                _buildDrawerItem(context, Icons.chair, 'Living Room Furniture', () {
                  Get.back();
                  Get.toNamed(Routes.CATEGORY, arguments: 139);
                }),
                _buildDrawerItem(context, Icons.bed, 'Bedroom Furniture', () {
                  Get.back();
                  Get.toNamed(Routes.CATEGORY, arguments: 142);
                }),
                _buildDrawerItem(context, Icons.restaurant, 'Dining & Kitchen', () {
                  Get.back();
                  Get.toNamed(Routes.CATEGORY, arguments: 140);
                }),
                const Divider(),
                _buildDrawerSectionTitle('BENEFITS & EXPLORE'),
                _buildDrawerItem(context, Icons.storefront, 'Our Experience Stores', () {
                  controller.currentIndex.value = 3;
                  Get.back();
                }),
                _buildDrawerItem(context, Icons.phone_in_talk, 'Request Callback', () {
                  controller.currentIndex.value = 2;
                  Get.back();
                }),
                _buildDrawerItem(context, Icons.account_circle, 'My Account', () {
                  controller.currentIndex.value = 4;
                  Get.back();
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFFAF9F6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars, color: Color(0xFFF37021), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Iron Street Guarantee',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleSmall?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '15-Year Solid Wood Warranty certified by layout & styling professionals.',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7), size: 20),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      dense: true,
      onTap: onTap,
    );
  }

  // --- BOTTOM NAV BAR ---
  Widget _buildBottomNavBar(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        backgroundColor: Theme.of(context).cardColor,
        currentIndex: controller.currentIndex.value,
        onTap: (index) => controller.onTabChanged(index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.normal,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_callback_outlined),
            activeIcon: Icon(Icons.phone_callback),
            label: 'Callback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  // --- FLOATING WHATSAPP FAB ---
  Widget _buildWhatsAppFAB() {
    return FloatingActionButton(
      shape: const CircleBorder(eccentricity: BorderSide.strokeAlignCenter),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // child: const Icon(Icons.message_rounded,
      //     color: Color.fromARGB(255, 11, 138, 15)),
      child: SvgPicture.asset(
        AppImages.whatsappLogo,
        fit: BoxFit.scaleDown,
      ),
      onPressed: () async {
        const cleanPhone = '918690154568';
        final message = Uri.encodeComponent(
          'Hello Iron Street! I would like to get details/designs from your on-call layout executive.',
        );
        final Uri whatsappUrl =
            Uri.parse('https://wa.me/$cleanPhone?text=$message');

        try {
          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } else {
            CustomToast.show(
              'Could not launch WhatsApp. Please make sure it is installed.',
              isError: true,
            );
          }
        } catch (e) {
          CustomToast.show(
            'An error occurred: $e',
            isError: true,
          );
        }
      },
    );
  }

  // --- INDEX 0: SUB VIEW HOME PANEL ---
  Widget _buildHomeSubView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSubCategoryTabs(),

        // Double row Grid Categories
        _buildCategoryHorizontalScroll(),

        // Banners slider carousel
        BannerSlider(
          banners: bannerCarouselCount,
          onTap: (banner) {
            final int? categoryId = int.tryParse(banner.id);
            if (categoryId != null) {
              Get.toNamed(Routes.CATEGORY, arguments: categoryId);
            } else {
              CustomToast.show('Opening selection: "${banner.title}"');
            }
          },
        ),

        // Deal Timer Lightning Deals Card
        // _buildDealTimerCard(),

        // 3x2 Brand Categories Grid
        _buildBrandGridSection(),
        const WhyChooseIronStreetSection(),

        Obx(() {
          if (controller.isTagsLoading.value &&
              controller.productTags.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Loading Products...',
                  subtitle: 'Fetching the best furniture tags',
                ),
                _buildHorizontalProductsListShimmer(),
                const SizedBox(height: 18),
              ],
            );
          }

          if (controller.productTags.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: controller.productTags.map((tag) {
              if (tag.count <= 1) {
                return const SizedBox.shrink();
              }
              final isLoading = controller.tagLoadingMap[tag.id] ?? false;
              final products = controller.tagProductsMap[tag.id] ?? [];

              if (isLoading) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: formatTagTitle(tag.name),
                      subtitle: 'Explore ${formatTagTitle(tag.name)} products',
                      onActionTap: () {},
                    ),
                    _buildHorizontalProductsListShimmer(),
                    const SizedBox(height: 18),
                  ],
                );
              }

              if (products.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: formatTagTitle(tag.name),
                    subtitle: 'Explore ${formatTagTitle(tag.name)} products',
                    onActionTap: () {
                      // Optional: view all page by tag
                      // Get.toNamed(
                      //   Routes.PRODUCT_LIST,
                      //   arguments: {
                      //     'tagId': tag.id,
                      //     'title': formatTagTitle(tag.name),
                      //   },
                      // );
                    },
                  ),
                  _buildHorizontalProductsList(products),
                  const SizedBox(height: 18),
                ],
              );
            }).toList(),
          );
        }),

        Obx(() {
          if (controller.isCustomerFavoritesLoading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Customer Favorites',
                  subtitle: 'Exquisite woodcraft & premium finishes',
                  onActionTap: () {},
                ),
                _buildHorizontalProductsListShimmer(),
                const SizedBox(height: 18),
              ],
            );
          }

          if (controller.customerFavoriteProducts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Customer Favorites',
                subtitle: 'Exquisite woodcraft & premium finishes',
                // actionText: "View All",
                onActionTap: () {
                  // controller.currentIndex.value = 1;
                },
              ),
              _buildHorizontalProductsList(
                controller.customerFavoriteProducts.toList(),
              ),
            ],
          );
        }),

        Obx(() {
          if (controller.isBestSellingChairsLoading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Best Selling Chairs',
                  subtitle: 'Universally loved designs',
                  onActionTap: () {},
                ),
                _buildHorizontalProductsListShimmer(),
                const SizedBox(height: 18),
              ],
            );
          }

          if (controller.bestSellingChairs.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Best Selling Chairs',
                subtitle: 'Universally loved designs',
                onActionTap: () {
                  // optional view all action
                },
              ),
              _buildHorizontalProductsList(
                controller.bestSellingChairs.toList(),
              ),
            ],
          );
        }),
        Obx(() {
          if (controller.isOutdoorFurnitureLoading.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Outdoor Furniture',
                  subtitle: 'Stylish and durable outdoor furniture',
                  onActionTap: () {},
                ),
                _buildHorizontalProductsListShimmer(),
                const SizedBox(height: 18),
              ],
            );
          }

          if (controller.outdoorFurnitureProducts.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Outdoor Furniture',
                subtitle: 'Stylish and durable outdoor furniture',
                onActionTap: () {
                  // optional view all action
                },
              ),
              _buildHorizontalProductsList(
                controller.outdoorFurnitureProducts.toList(),
              ),
            ],
          );
        }),

        // Recently Viewed items
        // const SectionHeader(
        //   title: 'Recently Viewed',
        //   subtitle: 'Items you inspected recently',
        // ),
        // _buildHorizontalProductsList(recentProducts),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSubCategoryTabs() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      // color: Colors.white,
      // color: const Color(0xFFF6F6F6),

      // The outer Obx listens to the loading state and the category list length
      child: Obx(() {
        if (controller.isCategoriesLoading.value) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(
                5,
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: CategoryTabShimmer(),
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.mainCategories.length,
          itemBuilder: (context, index) {
            final cat = controller.mainCategories[index];

            // ✅ THE FIX: Wrap the individual item in Obx!
            // This guarantees the colors recalculate the exact millisecond you tap.
            return Obx(() {
              // Check if THIS specific tab is the active one
              final isActive = controller.selectedMainCatId.value == cat.id;

              return GestureDetector(
                onTap: () {
                  // Tell the controller to update the active ID
                  controller.selectMainCategory(cat.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3D2619) : const Color(0xFFFFF0E6))
                        : Colors.transparent,
                    border: Border.all(
                      color: isActive
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cat.name,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            }); // End of inner Obx
          },
        );
      }),
    );
  }

  Widget _buildCategoryHorizontalScroll() {
    return Container(
      height: 235, // Adjust this height if your cards are getting cut off
      // color: Colors.white,
      color: AppColors.background,

      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              // 1. Show loader while API is fetching
              if (controller.isCategoriesLoading.value) {
                return GridView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const CategoryCardShimmer(),
                );
              }

              // 2. Show empty state if no subcategories exist
              if (controller.subCategories.isEmpty) {
                // return const Center(child: Text("No categories available"));
                return const SizedBox.shrink();
              }

              // 3. Render the flat list in a double-row horizontal grid
              return GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 rows vertically
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 10,
                  // childAspectRatio: 0.9, // Adjust this to fix image/text ratio
                ),
                itemCount: controller.subCategories.length,
                itemBuilder: (context, index) {
                  final cat = controller.subCategories[index];

                  return CategoryCard(
                    category: cat,
                    onTap: () {
                      Get.toNamed(Routes.CATEGORY, arguments: cat.id);
                    },
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDealTimerCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIGHTNING DEAL OFFER',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Grab premium solid wood at up to 60% OFF',
                    style: GoogleFonts.poppins(
                        fontSize: 9, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildTimeBox(controller.minutes),
                const Text(':',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                _buildTimeBox(controller.seconds),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(RxInt value) {
    return Obx(() {
      String padStr = value.value.toString().padLeft(2, '0');
      return Text(
        padStr,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildBrandGridSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(Get.context!).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore India\'s Finest Styles',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Theme.of(Get.context!).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: brandGridCategories.length,
            itemBuilder: (context, index) {
              final item = brandGridCategories[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.CATEGORY, arguments: item.id);
                },
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: item.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                          fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalProductsListShimmer() {
    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(right: 12),
            child: ProductCardShimmer(),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProductsList(List<ProductListModel> list) {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final prod = list[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductCard(
              product: prod,
            ),
          );
        },
      ),
    );
  }

  // --- INDEX 2: CALL BACK VIEW ---
  Widget _buildCallBackView() {
    var isSubmitted = false.obs;
    var nameController = TextEditingController();
    var phoneController = TextEditingController();
    var category = 'Living Room Furniture'.obs;
    var timeSlot = 'Immediate (Within 15 mins)'.obs;

    return Obx(() {
      if (isSubmitted.value) {
        return Container(
          color: Theme.of(Get.context!).cardColor,
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.primary, size: 68),
              const SizedBox(height: 16),
              Text(
                'Request Registered!',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'We hear you, ${nameController.text}! Our professional interior layout and styling coordinator will ring you back on ${phoneController.text} during the requested slot (${timeSlot.value}).',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Theme.of(Get.context!).textTheme.bodySmall?.color?.withOpacity(0.8)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(Get.context!).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : const Color(0xFF222222),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  isSubmitted.value = false;
                  nameController.clear();
                  phoneController.clear();
                },
                child: Text('Request Another Call',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      return Container(
        color: Theme.of(Get.context!).brightness == Brightness.dark
            ? Theme.of(Get.context!).scaffoldBackgroundColor
            : Colors.white,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).brightness == Brightness.dark
                      ? const Color(0xFF3D2619)
                      : const Color(0xFFFFF3EC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(Get.context!).brightness == Brightness.dark
                          ? const Color(0xFF5A3926)
                          : const Color(0xFFFFD4C0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.phone_callback,
                        color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TALK TO A FURNITURE SPECIALIST',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Struggling with space sizing, fabric combinations or custom layout advice? Get a free home layout call with zero commitments.',
                            style: GoogleFonts.poppins(
                                fontSize: 9, color: Theme.of(Get.context!).textTheme.bodySmall?.color?.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Your Full Name Text field
              Text('Your Full Name',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(Get.context!).brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Mobile Number
              Text('Mobile Number',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '10-digit number',
                  prefixText: '+91 ',
                  isDense: true,
                  filled: true,
                  fillColor: Theme.of(Get.context!).brightness == Brightness.dark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // What are you looking to buy?
              Text('What are you looking to buy?',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: Theme.of(Get.context!).brightness == Brightness.dark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(8)),
                child: Obx(() {
                  return DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: category.value,
                    dropdownColor: Theme.of(Get.context!).cardColor,
                    onChanged: (val) {
                      if (val != null) category.value = val;
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'Living Room Furniture',
                          child: Text('Living Room Furniture')),
                      DropdownMenuItem(
                          value: 'Bed Room Setup',
                          child: Text('Bedroom Setup')),
                      DropdownMenuItem(
                          value: 'Dining & Kitchen',
                          child: Text('Dining & Kitchen Setup')),
                      DropdownMenuItem(
                          value: 'Complete Home Makeover',
                          child: Text('Complete Home Makeover')),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Time slot
              Text('Preferred Call Slot',
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: Theme.of(Get.context!).brightness == Brightness.dark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFF6F6F6),
                    borderRadius: BorderRadius.circular(8)),
                child: Obx(() {
                  return DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: timeSlot.value,
                    dropdownColor: Theme.of(Get.context!).cardColor,
                    onChanged: (val) {
                      if (val != null) timeSlot.value = val;
                    },
                    items: const [
                      DropdownMenuItem(
                          value: 'Immediate (Within 15 mins)',
                          child: Text('Immediate (Within 15 mins)')),
                      DropdownMenuItem(
                          value: 'Today: 2:00 PM - 5:00 PM',
                          child: Text('Today: 2:00 PM - 5:00 PM')),
                      DropdownMenuItem(
                          value: 'Tomorrow Morning',
                          child: Text('Tomorrow Morning')),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Submit Action
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty ||
                        phoneController.text.trim().isEmpty) {
                      CustomToast.show(
                          'Please fill out your Name and Phone Number.',
                          isError: true);
                      return;
                    }
                    isSubmitted.value = true;
                  },
                  child: Text('Confirm Request Call-Back',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Our executive call is 100% Free of Cost. Response time is ~9 minutes.',
                  style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  // --- INDEX 3: STORES VIEW ---
  Widget _buildStoresView() {
    var selectedCity = 'All'.obs;
    final cities = [
      'All',
      'Udaipur',
    ];

    return Obx(() {
      final filteredList = selectedCity.value == 'All'
          ? experienceStores
          : experienceStores
              .where((s) =>
                  s.city.toLowerCase() == selectedCity.value.toLowerCase())
              .toList();

      return Column(
        children: [
          // City horizontal filters
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(Get.context!).brightness == Brightness.dark
                ? Theme.of(Get.context!).scaffoldBackgroundColor
                : Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final isActive = selectedCity.value == city;
                return GestureDetector(
                  onTap: () => selectedCity.value = city,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3D2619) : const Color(0xFFFFF0E6))
                          : Colors.transparent,
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary
                            : Theme.of(context).dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      city,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Store locations card list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final store = filteredList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      // Image banner
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: CachedNetworkImage(
                            imageUrl: store.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Information specs
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    store.address,
                                    style: GoogleFonts.poppins(
                                        fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 15, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      store.timings,
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8)),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Open Everyday',
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                                        side: BorderSide(
                                            color: Theme.of(context).dividerColor)),
                                    onPressed: () =>
                                        _openMap(store.mapUrl, store.address),
                                    icon: const Icon(Icons.navigation,
                                        size: 14, color: AppColors.primary),
                                    label: const Text('Directions',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary),
                                    onPressed: () => _makeCall(store.phone),
                                    icon: const Icon(Icons.phone,
                                        size: 14, color: Colors.white),
                                    label: const Text('Call Store',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.white)),
                                  ),
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
          )
        ],
      );
    });
  }

  Future<void> _openMap(String mapUrl, String address) async {
    final String urlString = mapUrl.isNotEmpty
        ? mapUrl
        : 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      CustomToast.show('Could not open map: $e', isError: true);
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    try {
      await launchUrl(url);
    } catch (e) {
      CustomToast.show(
        'This device does not support phone calls or dialer is unavailable.',
        isError: true,
      );
    }
  }
}
