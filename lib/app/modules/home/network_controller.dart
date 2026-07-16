import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';
import 'package:iron_street_app/app/modules/home/home_controller.dart';
import 'package:iron_street_app/app/modules/cart/cart_controller.dart';
import 'package:iron_street_app/app/modules/wishlist/wishlist_controller.dart';

class NetworkController extends GetxController {
  var isOffline = false.obs;
  Timer? _timer;
  bool _isDialogShown = false;

  @override
  void onInit() {
    super.onInit();
    _checkInternetConnection();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkInternetConnection();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<bool> _checkInternetConnectionImmediate() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkInternetConnection() async {
    final hasNet = await _checkInternetConnectionImmediate();
    _updateConnectionStatus(!hasNet);
  }

  void _reloadDataOnRestoration() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadInitialData();
    }
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().fetchWishlistFromServer();
    }
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().fetchCart();
    }
  }

  void _updateConnectionStatus(bool offline) {
    if (isOffline.value != offline) {
      isOffline.value = offline;
      if (offline) {
        _showNoInternetDialog();
      } else {
        if (_isDialogShown) {
          Get.back(); // Close dialog
          _isDialogShown = false;
        }
        
        // Trigger re-fetch of all failed categories and data
        _reloadDataOnRestoration();

        CustomToast.show(
          'Internet connection restored!',
          isSuccess: true,
        );
      }
    }
  }

  void _showNoInternetDialog() {
    if (_isDialogShown) return;
    _isDialogShown = true;

    Get.dialog(
      PopScope(
        canPop: false, // Prevent back button pop
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.red[600], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No Connection',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'We could not connect to the server. Please check your internet connection and try again.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Close app
              },
              child: Text(
                'Close App',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                // Show loading indicator
                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                  barrierDismissible: false,
                );

                final hasInternet = await _checkInternetConnectionImmediate();

                Get.back(); // Dismiss loading indicator

                if (hasInternet) {
                  if (_isDialogShown) {
                    Get.back(); // Dismiss no-internet dialog
                    _isDialogShown = false;
                  }
                  isOffline.value = false;
                  
                  // Trigger re-fetch of all failed categories and data
                  _reloadDataOnRestoration();

                  CustomToast.show(
                    'Connection restored!',
                    isSuccess: true,
                  );
                } else {
                  CustomToast.show(
                    'Still offline. Please check your settings.',
                    isError: true,
                  );
                }
              },
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
