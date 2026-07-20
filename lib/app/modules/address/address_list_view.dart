// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'address_controller.dart';
import 'add_edit_address_view.dart';

class AddressListView extends GetView<AddressController> {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    // If the controller isn't registered, register it.
    final addrCtrl = Get.isRegistered<AddressController>()
        ? Get.find<AddressController>()
        : Get.put(AddressController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0.5,
        title: Text(
          'Address Book',
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
      ),
      body: Obx(() {
        if (addrCtrl.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Saved Addresses',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please add an address to speed up checkout.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const AddEditAddressView()),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add First Address',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addrCtrl.addresses.length,
          itemBuilder: (context, index) {
            final address = addrCtrl.addresses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: address.isDefault ? AppColors.primary.withValues(alpha: 0.3) : Theme.of(context).dividerColor,
                  width: address.isDefault ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: address.isDefault
                                    ? (Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF3D2619)
                                        : const Color(0xFFFFF0E6))
                                    : (Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF2D2D2D)
                                        : const Color(0xFFF1F1F1)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                address.addressType.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: address.isDefault
                                      ? AppColors.primary
                                      : Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (address.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DEFAULT',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Get.to(() => AddEditAddressView(address: address));
                            } else if (value == 'delete') {
                              Get.dialog(
                                AlertDialog(
                                  title: Text('Delete Address', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                  content: Text('Are you sure you want to delete this address?', style: GoogleFonts.poppins()),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        addrCtrl.deleteAddress(address.id);
                                        Get.back();
                                      },
                                      child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            } else if (value == 'default') {
                              addrCtrl.selectDefaultAddress(address.id);
                            }
                          },
                          icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                          itemBuilder: (context) => [
                            if (!address.isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Text('Set as Default'),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Address'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      address.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          address.phone,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        final reachedLimit = addrCtrl.addresses.length >= 2;
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: reachedLimit ? null : () => Get.to(() => const AddEditAddressView()),
                icon: Icon(Icons.add, color: reachedLimit ? Colors.grey : Colors.white),
                label: Text(
                  reachedLimit ? 'ADDRESS LIMIT REACHED (MAX 2)' : 'ADD NEW ADDRESS',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: reachedLimit ? Colors.grey : Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: reachedLimit
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF222222)
                          : Colors.grey[300])
                      : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
