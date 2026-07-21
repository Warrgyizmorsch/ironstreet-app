import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/data/models/address_model.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'package:iron_street_app/app/modules/product_detail/product_detail_controller.dart';

class DeliveryDetailsSection extends StatefulWidget {
  final AddressModel? selectedAddress;
  final String? estimatedDeliveryDate;
  final VoidCallback? onAddressTap;

  const DeliveryDetailsSection({
    super.key,
    required this.selectedAddress,
    required this.estimatedDeliveryDate,
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
  }

  @override
  void didUpdateWidget(covariant DeliveryDetailsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedAddress?.postalCode != oldWidget.selectedAddress?.postalCode) {
      _updatePincodeFromAddress();
    }
  }

  void _updatePincodeFromAddress() {
    if (widget.selectedAddress != null && widget.selectedAddress!.postalCode.isNotEmpty) {
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
    final bool hasDeliveryDate =
        widget.estimatedDeliveryDate != null && widget.estimatedDeliveryDate!.isNotEmpty;
    final controller = Get.find<ProductDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Section heading
        Text(
          'Delivery details',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 12),

        // 2. Address container
        GestureDetector(
          onTap: widget.onAddressTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.home_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${(widget.selectedAddress?.addressType ?? "HOME").toUpperCase()}  ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                        TextSpan(
                          text: widget.selectedAddress != null
                              ? widget.selectedAddress!.fullAddress
                              : 'Select Delivery Address',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3. Delhivery Live Pincode Verification Field
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit Pincode',
                    hintStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 16),
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() {
              final isChecking = controller.isCheckingPincode.value;
              return SizedBox(
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: isChecking
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          controller.checkDelhiveryPincode(_pinController.text);
                        },
                  child: isChecking
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Check',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),

        // 4. Live Pincode Verification Status Box
        Obx(() {
          final error = controller.pincodeError.value;
          final result = controller.pincodeResult.value;

          if (error.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                error,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            );
          }

          if (result != null) {
            final isUnserviceable = result['unserviceable'] == true;
            if (isUnserviceable) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Currently not serviceable to pincode ${controller.enteredPincode.value}',
                        style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }

            final String city = result['city'] ?? result['district'] ?? 'Your Location';
            final String state = result['state_code'] ?? '';
            final bool codAvailable = result['cod'] == 'Y';
            final bool prepaidAvailable = result['pre_paid'] == 'Y';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Serviceable to $city, $state',
                          style: GoogleFonts.poppins(
                            color: Colors.green[700],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 24),
                      _buildServiceBadge(
                        'Prepaid',
                        prepaidAvailable,
                      ),
                      const SizedBox(width: 8),
                      _buildServiceBadge(
                        'COD',
                        codAvailable,
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        }),

        // 5. Estimated delivery container
        if (hasDeliveryDate) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
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
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      ),
                      children: [
                        const TextSpan(text: 'Delivery by '),
                        TextSpan(
                          text: widget.estimatedDeliveryDate,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildServiceBadge(String label, bool isAvailable) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isAvailable
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check : Icons.close,
            color: isAvailable ? Colors.green[700] : Colors.grey[600],
            size: 10,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isAvailable ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
