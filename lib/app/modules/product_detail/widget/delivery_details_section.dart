// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/data/models/address_model.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';

class DeliveryDetailsSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool hasDeliveryDate =
        estimatedDeliveryDate != null && estimatedDeliveryDate!.isNotEmpty;

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
          onTap: onAddressTap,
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
                              '${(selectedAddress?.addressType ?? "HOME").toUpperCase()}  ',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                        ),
                        TextSpan(
                          text: selectedAddress != null
                              ? selectedAddress!.fullAddress
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

        // 3. Estimated delivery container
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
                          text: estimatedDeliveryDate,
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
}
