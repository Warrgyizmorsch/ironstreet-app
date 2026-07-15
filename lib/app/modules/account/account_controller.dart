import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
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

    if (cleanUsername.isEmpty || cleanPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both username/email and password.',
        snackPosition: SnackPosition.BOTTOM,
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

        Get.snackbar(
          'Success',
          'Logged in successfully as $displayName!',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Invalid response from authorization server.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login Failed',
        e.toString().replaceAll('Exception: ', '').replaceAll('FetchDataException: ', ''),
        snackPosition: SnackPosition.BOTTOM,
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

    if (cleanUsername.isEmpty || cleanEmail.isEmpty || cleanPassword.isEmpty || cleanFirst.isEmpty || cleanLast.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all register fields.',
        snackPosition: SnackPosition.BOTTOM,
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
        Get.snackbar(
          'Registered Successfully',
          msg,
          snackPosition: SnackPosition.BOTTOM,
        );
        // Automatically login the newly registered user
        await login(cleanUsername, cleanPassword);
      } else {
        Get.snackbar(
          'Registration Failed',
          msg,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.toString().replaceAll('Exception: ', '').replaceAll('FetchDataException: ', ''),
        snackPosition: SnackPosition.BOTTOM,
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

      Get.snackbar(
        'Signed Out',
        'You have been logged out of Iron Street.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {}
  }
}
