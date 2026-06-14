

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'home_controller.dart';
import '../category/category_view.dart';
import '../account/account_view.dart';
import '../../widgets/app_header.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/section_header.dart';
import '../../data/dummy_data.dart';
import '../../data/models/product_model.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppHeader(
        onMenuClick: () => controller.openDrawer(),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Global Search Bar linked to query filter
          Obx(() {
            return CustomSearchBar(
              value: controller.searchQuery.value,
              onChanged: (val) {
                controller.searchQuery.value = val;
                if (val.trim().isNotEmpty) {
                  controller.currentIndex.value = 1; // Auto switch to Catalog/Search
                }
              },
            );
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- DRAWER/SIDEBAR SIMULATION ---
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1))),
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
                        color: const Color(0xFFF37021),
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
                _buildDrawerItem(Icons.chair, 'Living Room Furniture', () {
                  controller.selectSubCategory('Living');
                  controller.currentIndex.value = 1;
                  Get.back();
                }),
                _buildDrawerItem(Icons.bed, 'Bedroom Furniture', () {
                  controller.selectSubCategory('Bedroom');
                  controller.currentIndex.value = 1;
                  Get.back();
                }),
                _buildDrawerItem(Icons.restaurant, 'Dining & Kitchen', () {
                  controller.selectSubCategory('Dining');
                  controller.currentIndex.value = 1;
                  Get.back();
                }),
                const Divider(),
                _buildDrawerSectionTitle('BENEFITS & EXPLORE'),
                _buildDrawerItem(Icons.storefront, 'Our Experience Stores', () {
                  controller.currentIndex.value = 3;
                  Get.back();
                }),
                _buildDrawerItem(Icons.phone_in_talk, 'Request Callback', () {
                  controller.currentIndex.value = 2;
                  Get.back();
                }),
                _buildDrawerItem(Icons.account_circle, 'My Account', () {
                  controller.currentIndex.value = 4;
                  Get.back();
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFAF9F6),
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
                        color: const Color(0xFF444444),
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

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700], size: 20),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF444444),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      dense: true,
      onTap: onTap,
    );
  }

  // --- BOTTOM NAV BAR ---
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: controller.currentIndex.value,
      onTap: (index) => controller.onTabChanged(index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFF37021),
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
          label: 'Catalog',
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
    );
  }

  // --- FLOATING WHATSAPP FAB ---
  Widget _buildWhatsAppFAB() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF25D366),
      child: const Icon(Icons.chat, color: Colors.white),
      onPressed: () {
        Get.defaultDialog(
          title: 'Opening WhatsApp',
          middleText: 'Connecting you with our on-call layout executive on WhatsApp...',
          textConfirm: 'Proceed',
          confirmTextColor: Colors.white,
          buttonColor: const Color(0xFF25D366),
          onConfirm: () {
            Get.back();
            Get.snackbar('Connected', 'Virtual styling advisor lines are now active!');
          },
        );
      },
    );
  }

  // --- INDEX 0: SUB VIEW HOME PANEL ---
  Widget _buildHomeSubView() {
    // Filter Discover and Top Rated list items based on active subcategory select
    List<Product> displayDiscover = discoverNewProducts;
    List<Product> displayTopRated = topRatedProducts;

    if (controller.selectedSubCategory.value != 'All') {
      displayDiscover = discoverNewProducts
          .where((p) => p.category.toLowerCase() == controller.selectedSubCategory.value.toLowerCase())
          .toList();
      displayTopRated = topRatedProducts
          .where((p) => p.category.toLowerCase() == controller.selectedSubCategory.value.toLowerCase())
          .toList();
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Horizontal subcategories filters scroll tab strip
        _buildSubCategoryTabs(),

        // Double row Grid Categories
        _buildCategoryHorizontalScroll(),

        // Banners slider carousel
        BannerSlider(
          banners: bannerCarouselCount,
          onTap: (banner) {
            Get.snackbar('Promo Tapped', 'Opening selection: "${banner.title}"');
          },
        ),

        // Deal Timer Lightning Deals Card
        _buildDealTimerCard(),

        // 3x2 Brand Categories Grid
        _buildBrandGridSection(),

        // Discover what's new horizontal list
        if (displayDiscover.isNotEmpty) ...[
          SectionHeader(
            title: 'Discover what’s new',
            subtitle: 'Exquisite woodcraft & premium finishes',
            actionText: 'View All',
            onActionTap: () {
              controller.currentIndex.value = 1;
            },
          ),
          _buildHorizontalProductsList(displayDiscover),
        ],

        // Top-Rated by Indian Homes list
        if (displayTopRated.isNotEmpty) ...[
          SectionHeader(
            title: 'Top-Rated by Indian Homes',
            subtitle: 'Universally loved designs',
            actionText: 'View All',
            onActionTap: () {
              controller.currentIndex.value = 1;
            },
          ),
          _buildHorizontalProductsList(displayTopRated),
        ],

        // Home Furnishing Section
        _buildFurnishingGridSection(),

        // Home Decor Section
        _buildDecorGridSection(),

        // Recently Viewed items
        SectionHeader(
          title: 'Recently Viewed',
          subtitle: 'Items you inspected recently',
        ),
        _buildHorizontalProductsList(recentProducts),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSubCategoryTabs() {
    final subcategories = ['All', 'Living', 'Bedroom', 'Dining'];
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final cat = subcategories[index];
          final isActive = controller.selectedSubCategory.value == cat;
          return GestureDetector(
            onTap: () => controller.selectSubCategory(cat),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFFFF0E6) : Colors.transparent,
                border: Border.all(
                  color: isActive ? const Color(0xFFF37021) : const Color(0xFFE5E5E5),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFFF37021) : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHorizontalScroll() {
    return Container(
      height: 195,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Browse by Rooms & Categories',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                final cat = categoriesList[index];
                return CategoryCard(
                  category: cat,
                  onTap: () {
                    controller.selectSubCategory('All');
                    controller.currentIndex.value = 1;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealTimerCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECE0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD4C0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Color(0xFFF37021), size: 24),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIGHTNING DEAL OFFER',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFF37021),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Grab premium solid wood at up to 60% OFF',
                    style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF37021),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildTimeBox(controller.minutes),
                const Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore India\'s Finest Styles',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF222222),
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
                  controller.selectSubCategory('All');
                  controller.currentIndex.value = 1;
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
                      style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold),
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

  Widget _buildHorizontalProductsList(List<Product> list) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final prod = list[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ProductCard(product: prod),
          );
        },
      ),
    );
  }

  Widget _buildFurnishingGridSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Luxe Home Furnishings',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF222222),
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
            itemCount: homeFurnishingGrid.length,
            itemBuilder: (context, index) {
              final item = homeFurnishingGrid[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: item.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.priceText,
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: const Color(0xFFF37021),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDecorGridSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Designer Home Decors',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF222222),
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
            itemCount: homeDecorGrid.length,
            itemBuilder: (context, index) {
              final item = homeDecorGrid[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: item.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Column(
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item.priceText,
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: const Color(0xFFF37021),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFFF37021), size: 68),
              const SizedBox(height: 16),
              Text(
                'Request Registered!',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'We hear you, ${nameController.text}! Our professional interior layout and styling coordinator will ring you back on ${phoneController.text} during the requested slot (${timeSlot.value}).',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF222222),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  isSubmitted.value = false;
                  nameController.clear();
                  phoneController.clear();
                },
                child: Text('Request Another Call', style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD4C0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.phone_callback, color: Color(0xFFF37021), size: 24),
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
                              color: const Color(0xFFF37021),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Struggling with space sizing, fabric combinations or custom layout advice? Get a free home layout call with zero commitments.',
                            style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Full Name Text field
              Text('Your Full Name', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Mobile Number
              Text('Mobile Number', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '10-digit number',
                  prefixText: '+91 ',
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // What are you looking to buy?
              Text('What are you looking to buy?', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF6F6F6), borderRadius: BorderRadius.circular(8)),
                child: Obx(() {
                  return DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: category.value,
                    onChanged: (val) {
                      if (val != null) category.value = val;
                    },
                    items: const [
                      DropdownMenuItem(value: 'Living Room Furniture', child: Text('Living Room Furniture')),
                      DropdownMenuItem(value: 'Bed Room Setup', child: Text('Bedroom Setup')),
                      DropdownMenuItem(value: 'Dining & Kitchen', child: Text('Dining & Kitchen Setup')),
                      DropdownMenuItem(value: 'Complete Home Makeover', child: Text('Complete Home Makeover')),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Time slot
              Text('Preferred Call Slot', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFFF6F6F6), borderRadius: BorderRadius.circular(8)),
                child: Obx(() {
                  return DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    value: timeSlot.value,
                    onChanged: (val) {
                      if (val != null) timeSlot.value = val;
                    },
                    items: const [
                      DropdownMenuItem(value: 'Immediate (Within 15 mins)', child: Text('Immediate (Within 15 mins)')),
                      DropdownMenuItem(value: 'Today: 2:00 PM - 5:00 PM', child: Text('Today: 2:00 PM - 5:00 PM')),
                      DropdownMenuItem(value: 'Tomorrow Morning', child: Text('Tomorrow Morning')),
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
                    backgroundColor: const Color(0xFFF37021),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) {
                      Get.snackbar('Error', 'Please fill out your Name and Phone Number.');
                      return;
                    }
                    isSubmitted.value = true;
                  },
                  child: Text('Confirm Request Call-Back', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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
    final cities = ['All', 'Bangalore', 'Mumbai', 'New Delhi'];

    return Obx(() {
      final filteredList = selectedCity.value == 'All'
          ? experienceStores
          : experienceStores.where((s) => s.city.toLowerCase() == selectedCity.value.toLowerCase()).toList();

      return Column(
        children: [
          // City horizontal filters
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFF0E6) : Colors.transparent,
                      border: Border.all(
                        color: isActive ? const Color(0xFFF37021) : const Color(0xFFE5E5E5),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      city,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFFF37021) : Colors.grey[700],
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF1F1F1)),
                  ),
                  child: Column(
                    children: [
                      // Image banner
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    store.address,
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
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
                                    const Icon(Icons.access_time, size: 15, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      store.timings,
                                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Open Everyday',
                                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold),
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
                                        foregroundColor: Colors.grey[800],
                                        side: BorderSide(color: Colors.grey[300]!)),
                                    onPressed: () {
                                      Get.snackbar('GPS', 'Opening directions in maps to ${store.name}');
                                    },
                                    icon: const Icon(Icons.navigation, size: 14, color: Color(0xFFF37021)),
                                    label: const Text('Directions', style: TextStyle(fontSize: 11)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF37021)),
                                    onPressed: () {
                                      Get.snackbar('Calling', 'Showroom coordinators dial line diallers: ${store.phone}');
                                    },
                                    icon: const Icon(Icons.phone, size: 14, color: Colors.white),
                                    label: const Text('Call Store', style: TextStyle(fontSize: 11, color: Colors.white)),
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
}
