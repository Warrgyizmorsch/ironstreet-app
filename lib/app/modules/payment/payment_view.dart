// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'payment_controller.dart';
import '../../data/models/payment_method_model.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final payCtrl = Get.isRegistered<PaymentController>()
        ? Get.find<PaymentController>()
        : Get.put(PaymentController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Select Payment',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'STEP 3/3',
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (payCtrl.isProcessing.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Processing Secure Payment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please do not press back or close the application.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        final billTotal = payCtrl.checkCtrl.checkoutTotal;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFEFEF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL AMOUNT TO PAY',
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${NumberFormat('#,##,###').format(billTotal)}',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security, color: Colors.green, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'PAYMENT OPTIONS',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Payment Options List
            ...payCtrl.paymentMethods.map((method) {
              final isSelected = payCtrl.selectedMethodId.value == method.id;
              
              IconData methodIcon;
              switch (method.type) {
                case PaymentType.upi:
                  methodIcon = Icons.mobile_screen_share_outlined;
                  break;
                case PaymentType.card:
                  methodIcon = Icons.credit_card_outlined;
                  break;
                case PaymentType.netBanking:
                  methodIcon = Icons.account_balance_outlined;
                  break;
                case PaymentType.cod:
                  methodIcon = Icons.payments_outlined;
                  break;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : const Color(0xFFEFEFEF),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: ListTile(
                  onTap: () => payCtrl.selectMethod(method.id),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFF0E6) : const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      methodIcon,
                      color: isSelected ? AppColors.primary : Colors.grey[700],
                      size: 24,
                    ),
                  ),
                  title: Text(
                    method.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF222222),
                    ),
                  ),
                  subtitle: Text(
                    method.details,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Radio<String>(
                    value: method.id,
                    groupValue: payCtrl.selectedMethodId.value,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      if (val != null) payCtrl.selectMethod(val);
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Testing simulation option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.yellow[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ DEVELOPER TESTING SIMULATION',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[900]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Test the Payment Failure flow screen by using the failure button instead of Pay Now.',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange[850]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => payCtrl.processPayment(simulateFailure: true),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red[100],
                          foregroundColor: Colors.red[850],
                        ),
                        child: Text(
                          'Simulate Fail',
                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (payCtrl.isProcessing.value) return const SizedBox.shrink();
        
        final method = payCtrl.selectedMethod;
        final buttonLabel = method?.type == PaymentType.cod ? 'CONFIRM ORDER' : 'PAY SECURELY';

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F1F1)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => payCtrl.processPayment(),
                icon: const Icon(Icons.lock_outline, size: 16, color: Colors.white),
                label: Text(
                  buttonLabel,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
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
