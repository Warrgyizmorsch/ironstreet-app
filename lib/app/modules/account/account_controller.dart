import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otpless_headless_flutter/otpless_flutter.dart';
import 'package:iron_street_app/app/routes/app_pages.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'package:iron_street_app/app/utills/helpers/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iron_street_app/app/data/local/session_manager.dart';
import 'package:iron_street_app/app/data/repositories/user_repository/user_repository.dart';
import '../address/address_controller.dart';
import '../cart/cart_controller.dart';
import '../wishlist/wishlist_controller.dart';
import '../profile/profile_controller.dart';
import '../orders/orders_controller.dart';

class AccountController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final SessionManager _sessionManager = Get.find<SessionManager>();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var isRegisterLoading = false.obs;

  var token = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var name = ''.obs;

  // Headless OTPless States
  final Otpless _otplessHeadless = Otpless();
  final RxString phoneNo = ''.obs;
  final RxBool isSendingOtp = false.obs;
  final phoneController = TextEditingController();
  final RxBool showPhoneLoginForm = false.obs;

  // OTPless Credentials
  static const String otplessAppId = "";
  static const String otplessClientId = "";
  static const String otplessClientSecret = "";

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
    _otplessHeadless.initialize(otplessAppId);
    _otplessHeadless.setResponseCallback(_onOtplessResponse);
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final savedToken = _sessionManager.getToken();
      final savedEmail = _sessionManager.getEmail();
      final savedName = _sessionManager.getName();

      if (savedToken.isNotEmpty) {
        token.value = savedToken;
        email.value = savedEmail;
        name.value = savedName;
        isLoggedIn.value = true;

        // Refresh full profile from API on every cold start
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }
      }
    } catch (_) {}
  }

  Future<void> login(String username, String pass) async {
    final cleanUsername = username.trim();
    final cleanPassword = pass.trim();

    if (cleanUsername.isEmpty && cleanPassword.isEmpty) {
      CustomToast.show(
        'Please enter both username/email and password.',
        isError: true,
      );
      return;
    }
    if (cleanUsername.isEmpty) {
      CustomToast.show(
        'Please enter username/email.',
        isError: true,
      );
      return;
    }
    if (cleanPassword.isEmpty) {
      CustomToast.show(
        'Please enter password.',
        isError: true,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _userRepository.loginUser(
        username: cleanUsername,
        password: cleanPassword,
      );

      final String jwtToken = response['token'] ?? '';
      final String userEmail = response['user_email'] ?? '';
      final String displayName = response['user_display_name'] ?? '';

      if (jwtToken.isNotEmpty) {
        // Clear guest nonce to prevent cryptographic validation errors on user cart fetch
        await _sessionManager.clearNonce();

        await _sessionManager.saveSession(
          token: jwtToken,
          email: userEmail,
          name: displayName,
        );

        token.value = jwtToken;
        email.value = userEmail;
        name.value = displayName;
        isLoggedIn.value = true;

        // Fetch live cart, wishlist and profile
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().fetchCart();
        }
        if (Get.isRegistered<WishlistController>()) {
          Get.find<WishlistController>().fetchWishlistFromServer();
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }

        CustomToast.show(
          'Logged in successfully as $displayName!',
          isSuccess: true,
        );

        // If opened in a bottom sheet, close it; otherwise pop the route
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        } else if (Get.previousRoute.isNotEmpty &&
            Get.previousRoute != Routes.HOME) {
          Get.back();
        }
      } else {
        CustomToast.show(
          'Invalid response from authorization server.',
          isError: true,
        );
      }
    } catch (e) {
      CustomToast.show(
        // e.toString().replaceAll('Exception: ', '').replaceAll('FetchDataException: ', ''),
        'Something went wrong. try again!',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String username,
    required String emailAddress,
    required String pass,
    required String firstName,
    required String lastName,
  }) async {
    final cleanUsername = username.trim();
    final cleanEmail = emailAddress.trim();
    final cleanPassword = pass.trim();
    final cleanFirst = firstName.trim();
    final cleanLast = lastName.trim();

    if (cleanUsername.isEmpty ||
        cleanEmail.isEmpty ||
        cleanPassword.isEmpty ||
        cleanFirst.isEmpty ||
        cleanLast.isEmpty) {
      CustomToast.show(
        'Please fill in all register fields.',
        isError: true,
      );
      return;
    }

    try {
      isRegisterLoading.value = true;

      final response = await _userRepository.registerUser(
        username: cleanUsername,
        email: cleanEmail,
        password: cleanPassword,
        firstName: cleanFirst,
        lastName: cleanLast,
      );

      final bool success = response['success'] ?? false;
      final String msg = response['message'] ?? 'Registration complete!';

      if (success) {
        CustomToast.show(
          msg,
        );
        // Automatically login the newly registered user
        await login(cleanUsername, cleanPassword);
      } else {
        CustomToast.show(
          msg,
          isError: true,
        );
      }
    } catch (e) {
      CustomToast.show(
        e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('FetchDataException: ', ''),
        isError: true,
      );
    } finally {
      isRegisterLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _sessionManager.clearSession();

      isLoggedIn.value = false;
      token.value = '';
      email.value = '';
      name.value = '';

      // Clear in-memory address book
      if (Get.isRegistered<AddressController>()) {
        Get.find<AddressController>().addresses.clear();
      }

      // Clear in-memory cart details
      if (Get.isRegistered<CartController>()) {
        final cartCtrl = Get.find<CartController>();
        cartCtrl.cartItems.clear();
        cartCtrl.subtotalValue.value = 0.0;
        cartCtrl.deliveryPriceValue.value = 0.0;
        cartCtrl.totalTaxValue.value = 0.0;
        cartCtrl.totalAmountValue.value = 0.0;
        cartCtrl.totalDiscountValue.value = 0.0;
        cartCtrl.shippingAddress.value = null;
        cartCtrl.billingAddress.value = null;
      }

      // Clear in-memory wishlist details
      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().clearWishlist();
      }

      // Clear in-memory profile details
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().userProfile.value = null;
      }

      // Clear in-memory orders details
      if (Get.isRegistered<OrdersController>()) {
        final ordCtrl = Get.find<OrdersController>();
        ordCtrl.orders.clear();
        ordCtrl.activeOrderDetail.value = null;
      }

      CustomToast.show(
        'You have been logged out of Iron Street.',
      );
    } catch (e) {
      CustomToast.show('Logout failed: $e', isError: true);
    }
  }

  void _onOtplessResponse(dynamic result) async {
    _otplessHeadless.commitResponse(result);
    AppLogger.debug("OTPless Callback Response: $result");
    try {
      final responseType = result['responseType'];

      // Auto launch intentUrl for WhatsApp / channel redirection if provided
      if (result['response'] != null &&
          result['response']['intentUrl'] != null) {
        final String intentUrl = result['response']['intentUrl'].toString();
        if (intentUrl.isNotEmpty) {
          AppLogger.debug("Launching OTPless Redirect URL: $intentUrl");
          await launchUrl(
            Uri.parse(intentUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }

      switch (responseType) {
        case "SDK_READY":
          AppLogger.debug("OTPless SDK initialized successfully.");
          break;
        case "FAILED":
          final int? statusCode = result['statusCode'];
          if (statusCode == 5003) {
            _otplessHeadless.initialize(otplessAppId);
          } else {
            CustomToast.show('Initialization failed.', isError: true);
          }
          break;
        case "INITIATE":
          final int? statusCodeInit = result['statusCode'];
          if (statusCodeInit != 200) {
            CustomToast.show('Failed to initiate verification.', isError: true);
          } else if (result['response']?['authType'] == 'SILENT_AUTH') {
            AppLogger.debug("SNA is being attempted — show loading.");
          }
          break;
        case "VERIFY":
          final String? authType = result['response']?['authType'];
          final int? statusCodeVerify = result['statusCode'];
          if (authType == "SILENT_AUTH" && statusCodeVerify == 9106) {
            CustomToast.show('SNA verification failed.', isError: true);
          }
          break;
        case "ONETAP":
          CustomToast.show('Authentication successful!', isSuccess: true);
          await login('testuser1122', 'testuser1122');
          phoneNo.value = '';
          if (Get.isBottomSheetOpen == true) {
            Get.back();
          } else if (Get.previousRoute.isNotEmpty &&
              Get.previousRoute != Routes.HOME) {
            Get.back();
          }
          break;
        case "AUTH_TERMINATED":
          CustomToast.show('Authentication terminated.', isError: true);
          break;
      }
    } catch (e) {
      CustomToast.show('OTPless processing error: $e', isError: true);
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<void> loginWithWhatsapp() async {
    try {
      isSendingOtp.value = true;
      Map<String, dynamic> arg = {
        "channelType": "WHATSAPP",
        "channel": "WHATSAPP",
        "appId": otplessAppId,
      };
      _otplessHeadless.start(_onOtplessResponse, arg);
    } catch (e) {
      CustomToast.show('Failed to open WhatsApp: $e', isError: true);
      isSendingOtp.value = false;
    }
  }

  Future<void> loginWithPhone(String phone) async {
    if (phone.length < 10) {
      CustomToast.show('Please enter a valid 10-digit mobile number',
          isError: true);
      return;
    }
    try {
      isSendingOtp.value = true;
      phoneNo.value = phone;

      // 1. Call Create API to generate requestId
      final dio = Dio();
      final response = await dio.post(
        'https://auth.otpless.app/auth/v1/create',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'clientId': otplessClientId,
            'clientSecret': otplessClientSecret,
          },
        ),
        data: {
          'phoneNumber': phone,
          'countryCode': '91',
          'expiry': 300,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final requestId = response.data['requestId'];
        if (requestId != null) {
          AppLogger.debug("Successfully generated requestId: $requestId");

          Map<String, dynamic> arg = {
            "requestId": requestId,
            "phone": phone,
            "countryCode": "91",
          };
          _otplessHeadless.start(_onOtplessResponse, arg);

          // 3. Start authoritative status polling in parallel
          _pollStatus(requestId, 1);
        } else {
          CustomToast.show('Failed to retrieve requestId from OTPless',
              isError: true);
          isSendingOtp.value = false;
        }
      } else {
        CustomToast.show('Create API response failed: ${response.statusCode}',
            isError: true);
        isSendingOtp.value = false;
      }
    } catch (e) {
      CustomToast.show('Failed to start mobile login: $e', isError: true);
      isSendingOtp.value = false;
    }
  }

  Future<void> _pollStatus(String requestId, int attempt) async {
    if (!isSendingOtp.value) return;

    if (attempt > 30) {
      isSendingOtp.value = false;
      CustomToast.show('SIM verification timed out. Please try again.',
          isError: true);
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://auth.otpless.app/auth/v2/status',
        queryParameters: {
          'requestId': requestId,
        },
        options: Options(
          headers: {
            'clientId': otplessClientId,
            'clientSecret': otplessClientSecret,
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 400) {
        AppLogger.debug(
            "SNA Status Check: Auth not started yet (400). Continuing polling...");
      } else if (response.statusCode == 200 && response.data != null) {
        final auths = response.data['auths'] as List?;
        if (auths != null && auths.isNotEmpty) {
          final primaryAuth = auths.firstWhere(
            (element) => element['type'] == 'PRIMARY',
            orElse: () => null,
          );

          if (primaryAuth != null) {
            final status = primaryAuth['status'];
            if (status == 'SUCCESS') {
              CustomToast.show('SIM verification successful!', isSuccess: true);
              await login('testuser1122', 'testuser1122');
              phoneNo.value = '';
              isSendingOtp.value = false;
              if (Get.isBottomSheetOpen == true) {
                Get.back();
              }
              return;
            } else if (status == 'FAILED') {
              isSendingOtp.value = false;
              final errorMsg = primaryAuth['error']?['message'] ??
                  'SIM verification failed.';
              CustomToast.show(errorMsg, isError: true);
              return;
            }
          }
        }
      }
    } catch (e) {
      AppLogger.debug("SNA status check polling error: $e");
    }

    // Poll again after 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    await _pollStatus(requestId, attempt + 1);
  }
}
