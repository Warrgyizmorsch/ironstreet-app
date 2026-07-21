// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';

import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'account_controller.dart';
import '../../routes/app_pages.dart';
import 'legal_policies_view.dart';
import 'package:iron_street_app/app/data/local/session_manager.dart';
import '../profile/profile_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final accCtrl = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());

    final loginUsernameController = TextEditingController();
    final loginPassController = TextEditingController();

    final regUsernameController = TextEditingController();
    final regEmailController = TextEditingController();
    final regPassController = TextEditingController();
    final regFirstController = TextEditingController();
    final regLastController = TextEditingController();

    final RxBool isLoginTab = true.obs;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF6F6F6),
      body: Obx(() {
        if (accCtrl.isLoggedIn.value) {
          return _buildProfileDashboard(context, accCtrl);
        } else {
          return _buildAuthContainer(
            context,
            accCtrl: accCtrl,
            isLoginTab: isLoginTab,
            loginUsernameCtrl: loginUsernameController,
            loginPassCtrl: loginPassController,
            regUsernameCtrl: regUsernameController,
            regEmailCtrl: regEmailController,
            regPassCtrl: regPassController,
            regFirstCtrl: regFirstController,
            regLastCtrl: regLastController,
          );
        }
      }),
    );
  }

  // --- PROFILE DASHBOARD STATE ---
  Widget _buildProfileDashboard(BuildContext context, AccountController accCtrl) {
    final profCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Brief Card — powered by ProfileController (live API data)
                    Obx(() {
                      final user = profCtrl.userProfile.value;
                      final isLoading = profCtrl.isLoading.value;

                      // Display name: prefer full API name, fall back to JWT display name
                      final displayName = user?.name.isNotEmpty == true
                          ? user!.name
                          : accCtrl.name.value;

                      // Email: prefer API email, fall back to JWT email
                      final displayEmail = user?.email.isNotEmpty == true
                          ? user!.email
                          : accCtrl.email.value;

                      // Member status from roles
                      final memberStatus = user?.memberStatus ?? 'Member';

                      // Joined date
                      final joinedDate = user?.joinedDate ?? '';

                      // Avatar initials
                      final initials = displayName.trim().isNotEmpty
                          ? displayName
                              .trim()
                              .split(' ')
                              .where((w) => w.isNotEmpty)
                              .map((n) => n[0])
                              .join('')
                              .toUpperCase()
                          : 'U';

                      // Avatar image URL from WP user URL field
                      final avatarUrl = user?.profileImage ?? '';


                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Row(
                          children: [
                            // Avatar: real image if available, else initials circle
                            isLoading
                                ? Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF3D2619)
                                          : const Color(0xFFFFF0E6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : avatarUrl.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          avatarUrl,
                                          width: 58,
                                          height: 58,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _initialsCircle(context, initials),
                                        ),
                                      )
                                    : _initialsCircle(context, initials),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.titleMedium?.color),
                                  ),
                                  Text(
                                    displayEmail,
                                    style: GoogleFonts.poppins(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                  if (joinedDate.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      joinedDate,
                                      style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: Colors.grey.shade400),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF3D2619)
                                          : const Color(0xFFFFF0E6),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? const Color(0xFF5A3926)
                                              : const Color(0xFFFFD4C0)),
                                    ),
                                    child: Text(
                                      memberStatus.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    _buildSectionHeader(context, 'Account Settings'),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsRow(
                            context,
                            'Profile details',
                            leadingIcon: Icons.person_outline_rounded,
                            targetRoute: Routes.PROFILE,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.17,
                            color: Theme.of(context).dividerColor,
                          ),
                          _buildSettingsRow(
                            context,
                            'My Address',
                            leadingIcon: Icons.location_on_outlined,
                            targetRoute: Routes.ADDRESS_LIST,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.17,
                            color: Theme.of(context).dividerColor,
                          ),
                          _buildThemeRow(context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader(context, 'Purchases & History'),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsRow(
                            context,
                            'My Orders',
                            leadingIcon: Icons.shopping_bag_outlined,
                            targetRoute: Routes.ORDERS,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildSectionHeader(context, 'Support & Legal'),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        children: [
                          _buildSettingsRow(
                            context,
                            'Legal, Terms & Conditions',
                            leadingIcon: Icons.description_outlined,
                            onTap: () =>
                                Get.to(() => const LegalPoliciesView()),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),

                    // Logout Secure Button
                    SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.red[900]!
                                  : Colors.red[100]!),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.red[900]?.withValues(alpha: 0.2)
                              : Colors.red[50],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => accCtrl.logout(),
                        icon: const Icon(Icons.logout, size: 16),
                        label: Text(
                          'Sign Out of Account',
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildStatCol(String num, String label) {
  //   return Expanded(
  //     child: Column(
  //       children: [
  //         Text(
  //           num,
  //           style: GoogleFonts.poppins(
  //               fontSize: 14,
  //               fontWeight: FontWeight.w800,
  //               color: AppColors.primary),
  //         ),
  //         const SizedBox(height: 2),
  //         Text(
  //           label.toUpperCase(),
  //           style: GoogleFonts.poppins(
  //               fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  /// Reusable initials avatar circle (fallback when no profile image)
  Widget _initialsCircle(BuildContext context, String initials) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF3D2619)
            : const Color(0xFFFFF0E6),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary),
      ),
    );
  }

  // Widget _buildActiveTrackingSection() {
  //   return GestureDetector(
  //     // onTap: () => Get.to(() => const OrderDetailView(orderId: 'ord_recent_1')),
  //     onTap: () => Get.toNamed(Routes.ORDER_DETAIL, arguments: 'ord_recent_1'),
  //     child: Container(
  //       padding: const EdgeInsets.all(16),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(16),
  //         border: Border.all(color: const Color(0xFFF1F1F1)),
  //       ),
  //       child: Column(

  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Row(
  //                 children: [
  //                   const Icon(Icons.local_shipping,
  //                       color: AppColors.primary, size: 18),
  //                   const SizedBox(width: 6),
  //                   Text(
  //                     'RECENT ORDER',
  //                     style: GoogleFonts.poppins(
  //                         fontSize: 10,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.grey),
  //                   ),
  //                 ],
  //               ),
  //               Text(
  //                 '#IS-7341-ORDER',
  //                 style: GoogleFonts.poppins(
  //                     fontSize: 9,
  //                     color: Colors.grey,
  //                     fontWeight: FontWeight.bold),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             children: [
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(6),
  //                 child: SizedBox(
  //                   width: 38,
  //                   height: 38,
  //                   child: CachedNetworkImage(
  //                     imageUrl:
  //                         'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=100&auto=format&fit=crop&q=80',
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Ayaana Sheesham Wood Sofa Cum Bed',
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: GoogleFonts.poppins(
  //                           fontSize: 11, fontWeight: FontWeight.bold),
  //                     ),
  //                     Text(
  //                       'Quantity: 1 | Honey Finish',
  //                       style: GoogleFonts.poppins(
  //                           fontSize: 9, color: Colors.grey),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const Divider(height: 24),
  //
  //           // Simple dynamic timeline steps tracking
  //           _buildTimelineStep(
  //               'Order Dispatched from Bengaluru Hub', 'June 12, 10:14 AM',
  //               isCompleted: true),
  //           _buildTimelineStep(
  //               'In-Transit: Nearing Delivery City', 'June 13, 08:30 AM',
  //               isCurrent: true),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildTimelineStep(String label, String timing,
  //     {bool isCompleted = false, bool isCurrent = false}) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Column(
  //         children: [
  //           Container(
  //             width: 8,
  //             height: 8,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: isCompleted || isCurrent
  //                   ? Colors.green[600]
  //                   : Colors.grey[300],
  //             ),
  //           ),
  //           Container(
  //             width: 1.5,
  //             height: 24,
  //             color: isCompleted ? Colors.green[200] : Colors.grey[200],
  //           ),
  //         ],
  //       ),
  //       const SizedBox(width: 12),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: GoogleFonts.poppins(
  //                 fontSize: 10,
  //                 fontWeight: FontWeight.bold,
  //                 color:
  //                     isCurrent ? AppColors.primary : const Color(0xFF222222),
  //               ),
  //             ),
  //             Text(
  //               timing,
  //               style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, String text,
      {required IconData leadingIcon,
      String? targetRoute,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(leadingIcon, color: AppColors.primary, size: 20),
      title: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
      dense: true,
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (targetRoute != null) {
          Get.toNamed(targetRoute);
        } else {
          CustomToast.show('Opening customized configurations: "$text"');
        }
      },
    );
  }

  Widget _buildThemeRow(BuildContext context) {
    final sessionManager = Get.find<SessionManager>();
    final currentModeStr = sessionManager.getThemeMode().obs;

    return Obx(() {
      IconData themeIcon = Icons.brightness_auto_outlined;
      String displayMode = 'System Default';
      if (currentModeStr.value == 'light') {
        themeIcon = Icons.light_mode_outlined;
        displayMode = 'Light Mode';
      } else if (currentModeStr.value == 'dark') {
        themeIcon = Icons.dark_mode_outlined;
        displayMode = 'Dark Mode';
      }

      return ListTile(
        leading: Icon(themeIcon, color: AppColors.primary, size: 20),
        title: Text(
          'Theme Mode',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayMode,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
          ],
        ),
        dense: true,
        onTap: () => _showThemeSelectionDialog(context, currentModeStr),
      );
    });
  }

  void _showThemeSelectionDialog(BuildContext context, RxString currentModeRx) {
    final sessionManager = Get.find<SessionManager>();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Theme Mode',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeDialogOption(context, 'System Default', 'system', currentModeRx, sessionManager),
            _buildThemeDialogOption(context, 'Light Mode', 'light', currentModeRx, sessionManager),
            _buildThemeDialogOption(context, 'Dark Mode', 'dark', currentModeRx, sessionManager),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDialogOption(
    BuildContext context,
    String title,
    String value,
    RxString currentModeRx,
    SessionManager sessionManager,
  ) {
    return Obx(() {
      return RadioListTile<String>(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        value: value,
        groupValue: currentModeRx.value,
        activeColor: AppColors.primary,
        onChanged: (val) {
          if (val != null) {
            currentModeRx.value = val;
            sessionManager.saveThemeMode(val);

            ThemeMode mode = ThemeMode.system;
            if (val == 'light') {
              mode = ThemeMode.light;
            } else if (val == 'dark') {
              mode = ThemeMode.dark;
            }
            Get.changeThemeMode(mode);
            Get.back();
          }
        },
      );
    });
  }

  // --- LOG IN SIGN IN CONSOLE FORM STATE ---
  Widget _buildAuthContainer(
    BuildContext context, {
    required AccountController accCtrl,
    required RxBool isLoginTab,
    required TextEditingController loginUsernameCtrl,
    required TextEditingController loginPassCtrl,
    required TextEditingController regUsernameCtrl,
    required TextEditingController regEmailCtrl,
    required TextEditingController regPassCtrl,
    required TextEditingController regFirstCtrl,
    required TextEditingController regLastCtrl,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tabs Header
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => isLoginTab.value = true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isLoginTab.value
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'SIGN IN',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isLoginTab.value
                                  ? AppColors.primary
                                  : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => isLoginTab.value = false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !isLoginTab.value
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'SIGN UP',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: !isLoginTab.value
                                  ? AppColors.primary
                                  : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: isLoginTab.value
                    ? _buildSignInForm(
                        context, accCtrl, loginUsernameCtrl, loginPassCtrl)
                    : _buildSignUpForm(
                        context,
                        accCtrl,
                        regUsernameCtrl,
                        regEmailCtrl,
                        regPassCtrl,
                        regFirstCtrl,
                        regLastCtrl,
                        isLoginTab,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm(
    BuildContext context,
    AccountController accCtrl,
    TextEditingController usernameCtrl,
    TextEditingController passCtrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to access your orders, account profile, and benefits.',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 20),

        // Username or Email
        Text(
          'Username or Email',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: usernameCtrl,
          decoration: InputDecoration(
            hintText: 'Enter username or email',
            isDense: true,
            filled: true,
            hintStyle:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.person_outline, size: 16),
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password
        Text(
          'Password',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter password',
            isDense: true,
            filled: true,
            hintStyle:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.lock_outline, size: 16),
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Login Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: accCtrl.isLoading.value
                ? null
                : () => accCtrl.login(usernameCtrl.text, passCtrl.text),
            child: accCtrl.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Log In Securely',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm(
    BuildContext context,
    AccountController accCtrl,
    TextEditingController usernameCtrl,
    TextEditingController emailCtrl,
    TextEditingController passCtrl,
    TextEditingController firstCtrl,
    TextEditingController lastCtrl,
    RxBool isLoginTab,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Join Iron Street to unlock exclusive catalogs, coupons, and secure orders.',
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 20),

        // Name fields side by side
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Name',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: firstCtrl,
                    decoration: InputDecoration(
                      hintText: 'First name',
                      isDense: true,
                      filled: true,
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey[400]),
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFF6F6F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Name',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: lastCtrl,
                    decoration: InputDecoration(
                      hintText: 'Last name',
                      isDense: true,
                      filled: true,
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey[400]),
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFF6F6F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Username
        Text(
          'Username',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: usernameCtrl,
          decoration: InputDecoration(
            hintText: 'Choose username',
            isDense: true,
            filled: true,
            hintStyle:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.person_outline, size: 16),
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Email Address
        Text(
          'Email Address',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter email address',
            isDense: true,
            filled: true,
            hintStyle:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.mail_outline, size: 16),
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Password
        Text(
          'Password',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: passCtrl,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Choose secure password',
            isDense: true,
            filled: true,
            hintStyle:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.lock_outline, size: 16),
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Register Button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: accCtrl.isRegisterLoading.value
                ? null
                : () => accCtrl.register(
                      username: usernameCtrl.text,
                      emailAddress: emailCtrl.text,
                      pass: passCtrl.text,
                      firstName: firstCtrl.text,
                      lastName: lastCtrl.text,
                    ),
            child: accCtrl.isRegisterLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
