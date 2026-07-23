import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iron_street_app/app/modules/account/account_view.dart';

class AuthHelper {
  static void showLoginBottomSheet() {
    Get.bottomSheet(
      AnimatedPadding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          height: Get.height * 0.55,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400]?.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              const Expanded(
                child: AccountView(isBottomSheet: true),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }
}
