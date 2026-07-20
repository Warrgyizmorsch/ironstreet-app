// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final profCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        title: Text(
          'Profile details',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: Theme.of(context).appBarTheme.iconTheme?.color ?? Theme.of(context).textTheme.titleLarge?.color,
              size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (profCtrl.isEditing.value) {
              return profCtrl.isSaving.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: () {
                        profCtrl.nameEditVal.value = nameController.text;
                        profCtrl.emailEditVal.value = emailController.text;
                        profCtrl.phoneEditVal.value = phoneController.text;
                        profCtrl.saveProfile();
                      },
                      child: Text(
                        'SAVE',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
            } else {
              return TextButton(
                onPressed: () {
                  profCtrl.startEditing();
                  nameController.text = profCtrl.userProfile.value?.name ?? '';
                  emailController.text = profCtrl.userProfile.value?.email ?? '';
                  phoneController.text = profCtrl.userProfile.value?.phone ?? '';
                },
                child: Text(
                  'EDIT',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              );
            }
          }),
        ],
      ),
      body: Obx(() {
        final user = profCtrl.userProfile.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF3D2619)
                              : const Color(0xFFFFF0E6),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 3),
                        ),
                        alignment: Alignment.center,
                        child: user.profileImage.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(45),
                                child: CachedNetworkImage(
                                  imageUrl: user.profileImage,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Text(
                                    user.name.split(' ').map((n) => n[0]).join(''),
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                user.name.split(' ').map((n) => n[0]).join(''),
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF3D2619)
                          : const Color(0xFFFFF0E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.memberStatus.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.joinedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Form / Details
            Text(
              'ACCOUNT INFORMATION',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  if (profCtrl.isEditing.value) ...[
                    _buildInputField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const Divider(height: 24),
                    _buildInputField(
                      controller: emailController,
                      label: 'Email Address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Divider(height: 24),
                    _buildInputField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ] else ...[
                    _buildDetailRow(context, 'Full Name', user.name, Icons.person_outline),
                    const Divider(height: 24),
                    _buildDetailRow(context, 'Email Address', user.email, Icons.mail_outline_rounded),
                    const Divider(height: 24),
                    _buildDetailRow(context, 'Phone Number', user.phone, Icons.phone_android_outlined),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (profCtrl.isEditing.value)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: profCtrl.isSaving.value
                          ? null
                          : () => profCtrl.cancelEditing(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.poppins(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: profCtrl.isSaving.value
                          ? null
                          : () {
                              profCtrl.nameEditVal.value =
                                  nameController.text;
                              profCtrl.emailEditVal.value =
                                  emailController.text;
                              profCtrl.phoneEditVal.value =
                                  phoneController.text;
                              profCtrl.saveProfile();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: profCtrl.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'SAVE',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon, {bool isReadOnly = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isReadOnly ? Theme.of(context).textTheme.bodySmall?.color : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        if (isReadOnly)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D2D) : Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'LOCKED',
              style: GoogleFonts.poppins(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
