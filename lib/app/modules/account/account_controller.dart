

import 'package:get/get.dart';

class AccountController extends GetxController {
  var isLoggedIn = false.obs;
  var email = ''.obs;
  var password = ''.obs;
  var name = 'Ananya Sharma'.obs;

  void login(String emailAddress, String pass) {
    if (emailAddress.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a valid email to sign in.');
      return;
    }
    email.value = emailAddress;
    password.value = pass;
    isLoggedIn.value = true;
    Get.snackbar(
      'Success',
      'Logged in securely!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    isLoggedIn.value = false;
    email.value = '';
    password.value = '';
    Get.snackbar(
      'Signed Out',
      'You have been logged out of Iron Street.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
