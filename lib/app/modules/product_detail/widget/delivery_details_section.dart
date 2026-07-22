import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/data/models/address_model.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'package:iron_street_app/app/modules/product_detail/product_detail_controller.dart';

class DeliveryDetailsSection extends StatefulWidget {
  final AddressModel? selectedAddress;
  final VoidCallback? onAddressTap;

  const DeliveryDetailsSection({
    super.key,
    required this.selectedAddress,
    required this.onAddressTap,
  });

  @override
  State<DeliveryDetailsSection> createState() => _DeliveryDetailsSectionState();
}

class _DeliveryDetailsSectionState extends State<DeliveryDetailsSection> {
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updatePincodeFromAddress();
    // Auto-trigger shipping and TAT checks if pincode is pre-populated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pinController.text.trim().length == 6) {
        final controller = Get.find<ProductDetailController>();
        controller.checkDelhiveryPincode(_pinController.text.trim());
      }
    });
  }

  @override
  void didUpdateWidget(covariant DeliveryDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddress?.postalCode !=
        oldWidget.selectedAddress?.postalCode) {
      _updatePincodeFromAddress();
      if (_pinController.text.trim().length == 6) {
        final controller = Get.find<ProductDetailController>();
        controller.checkDelhiveryPincode(_pinController.text.trim());
      }
    }
  }

  void _updatePincodeFromAddress() {
    if (widget.selectedAddress != null &&
        widget.selectedAddress!.postalCode.isNotEmpty) {
      _pinController.text = widget.selectedAddress!.postalCode;
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title heading
        Text(
          'Check delivery date',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 10),

        // Main Pincode and Serviceability Container
        Obx(() {
          final isChecking = controller.isCheckingPincode.value;
          final isCalculating = controller.isCalculatingDelivery.value;
          final result = controller.pincodeResult.value;
          final error = controller.pincodeError.value;
          final liveDate = controller.estimatedDelhiveryDate.value;
          final price = controller.deliveryCharge.value;

          final bool hasResult = result != null;
          final bool isUnserviceable =
              hasResult && result['unserviceable'] == true;
          final bool isServiceable = hasResult && !isUnserviceable;

          // Case A: Serviceable (Pincode & City Container + Price/Date Info Box below)
          if (isServiceable) {
            final String city =
                result['city'] ?? result['district'] ?? 'Your Location';
            final String state = result['state_code'] ?? '';
            final String pin = controller.enteredPincode.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container with Pincode and City
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFFAF9F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$pin, $city, $state',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Change button
                      GestureDetector(
                        onTap: () {
                          controller.pincodeResult.value = null;
                          controller.estimatedDelhiveryDate.value = '';
                          controller.deliveryCharge.value = 0.0;
                          _pinController.clear();
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Delivery Info specifications card below
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item 1: Serviceable Status
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery Available',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Item 2: Shipping Charges
                      Row(
                        children: [
                          Icon(Icons.currency_rupee,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              size: 15),
                          const SizedBox(width: 9),
                          Text(
                            'Shipping Charges: ',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          isCalculating
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                  ),
                                )
                              : Text(
                                  price > 0
                                      ? '₹${NumberFormat('#,##,###').format(price)}'
                                      : 'Free',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Item 3: Expected Delivery Date
                      if (liveDate.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                size: 14),
                            const SizedBox(width: 10),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                                children: [
                                  const TextSpan(text: 'Estimated Delivery: '),
                                  TextSpan(
                                    text: liveDate,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Case B: Unserviceable (Pincode Container + Unserviceable Alert below)
          if (isUnserviceable) {
            final String pin = controller.enteredPincode.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFFAF9F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          pin,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Change button
                      GestureDetector(
                        onTap: () {
                          controller.pincodeResult.value = null;
                          controller.estimatedDelhiveryDate.value = '';
                          controller.deliveryCharge.value = 0.0;
                          _pinController.clear();
                        },
                        child: Text(
                          'Change',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivery not available to this location',
                          style: GoogleFonts.poppins(
                            color: Colors.red[800],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Case C: Initial State (Pincode input field nested inside the same container)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Colors.grey, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        onChanged: (val) {
                          if (val.trim().length == 6 &&
                              int.tryParse(val.trim()) != null) {
                            FocusScope.of(context).unfocus();
                            controller.checkDelhiveryPincode(val.trim());
                          }
                        },
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Pincode',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Apply text button
                    isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              controller.checkDelhiveryPincode(
                                  _pinController.text.trim());
                            },
                            child: Text(
                              'Apply',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                  ],
                ),
              ),
              if (error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                  child: Text(
                    error,
                    style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}
