import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';

import 'account_controller.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final accCtrl = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());

    final emailFieldController = TextEditingController();
    final passFieldController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Obx(() {
        if (accCtrl.isLoggedIn.value) {
          return _buildProfileDashboard(accCtrl);
        } else {
          return _buildLoginForm(
              accCtrl, emailFieldController, passFieldController);
        }
      }),
    );
  }

  // --- PROFILE DASHBOARD STATE ---
  Widget _buildProfileDashboard(AccountController accCtrl) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        // Profile Brief Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0E6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  accCtrl.name.value.split(' ').map((n) => n[0]).join(''),
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accCtrl.name.value,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF222222)),
                    ),
                    Text(
                      accCtrl.email.value.isNotEmpty
                          ? accCtrl.email.value
                          : 'ananya.sharma@gmail.com',
                      style:
                          GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD4C0)),
                      ),
                      child: Text(
                        'Gold Club Member'.toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Quick Stats row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Row(
            children: [
              _buildStatCol('1', 'Active Order'),
              Container(color: const Color(0xFFF1F1F1), width: 1.5, height: 35),
              _buildStatCol('12', 'Total Orders'),
              Container(color: const Color(0xFFF1F1F1), width: 1.5, height: 35),
              _buildStatCol('₹1,45,000', 'Total Saved'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Active tracking item
        _buildActiveTrackingSection(),
        const SizedBox(height: 16),

        // General list settings
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Column(
            children: [
              _buildSettingsRow('Your Address Book'),
              const Divider(height: 1),
              _buildSettingsRow('My Reviews & Ratings'),
              const Divider(height: 1),
              _buildSettingsRow('Help Desk & Support Center'),
              const Divider(height: 1),
              _buildSettingsRow('Terms & Conditions'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logout Secure Button
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[600],
              side: BorderSide(color: Colors.red[100]!),
              backgroundColor: Colors.red[50],
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
        )
      ],
    );
  }

  Widget _buildStatCol(String num, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            num,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.primary),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.poppins(
                fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrackingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F1F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'RECENT ORDER',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '#IS-7341-ORDER',
                style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=100&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ayaana Sheesham Wood Sofa Cum Bed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Quantity: 1 | Honey Finish',
                      style:
                          GoogleFonts.poppins(fontSize: 9, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Simple dynamic timeline steps tracking
          _buildTimelineStep(
              'Order Dispatched from Bengaluru Hub', 'June 12, 10:14 AM',
              isCompleted: true),
          _buildTimelineStep(
              'In-Transit: Nearing Delivery City', 'June 13, 08:30 AM',
              isCurrent: true),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, String timing,
      {bool isCompleted = false, bool isCurrent = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent
                    ? Colors.green[600]
                    : Colors.grey[300],
              ),
            ),
            Container(
              width: 1.5,
              height: 24,
              color: isCompleted ? Colors.green[200] : Colors.grey[200],
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color:
                      isCurrent ? AppColors.primary : const Color(0xFF222222),
                ),
              ),
              Text(
                timing,
                style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(String text) {
    return ListTile(
      title: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF444444)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      dense: true,
      onTap: () {
        Get.snackbar('Console', 'Opening customized configurations: "$text"');
      },
    );
  }

  // --- LOG IN SIGN IN CONSOLE FORM STATE ---
  Widget _buildLoginForm(AccountController accCtrl,
      TextEditingController emailCtrl, TextEditingController passCtrl) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F1F1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SIGN IN TO IRON STREET',
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 4),
              Text(
                'Access orders, secure receipts & receive exclusive Gold Club Coupons.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Email Address
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email Address',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey))),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  hintText: 'Enter Guest Email e.g. guest@ironstreet.com',
                  isDense: true,
                  filled: true,
                  hintStyle: const TextStyle(fontSize: 11),
                  prefixIcon: const Icon(Icons.mail_outline, size: 16),
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),

              // Password
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey))),
              const SizedBox(height: 6),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  isDense: true,
                  filled: true,
                  prefixIcon: const Icon(Icons.lock_outline, size: 16),
                  fillColor: const Color(0xFFF6F6F6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => accCtrl.login(emailCtrl.text, passCtrl.text),
                  child: Text(
                    'Log In Securely',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: const Color(0xFFFFF0E6),
                child: Text(
                  '💡 Enter any user email to complete instantaneous login!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
