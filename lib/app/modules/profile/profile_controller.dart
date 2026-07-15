import 'dart:developer';
import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../data/local/session_manager.dart';
import '../../data/repositories/user_repository/user_repository.dart';
import '../account/account_controller.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final SessionManager _sessionManager = Get.find<SessionManager>();

  final userProfile = Rxn<UserModel>();
  var isLoading = false.obs;
  var isSaving = false.obs;
  var hasError = false.obs;

  // Observables for editing fields
  var isEditing = false.obs;
  var nameEditVal = ''.obs;
  var emailEditVal = ''.obs;
  var phoneEditVal = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  /// Fetches the authenticated user profile from WP REST API.
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final token = _sessionManager.getToken();
      if (token.isEmpty) {
        log('[ProfileController] No token — skipping profile fetch');
        return;
      }

      final profile = await _userRepository.fetchProfile(token: token);
      userProfile.value = profile;

      log('[ProfileController] Profile loaded: ${profile.name} (${profile.email})');
    } catch (e) {
      hasError.value = true;
      log('[ProfileController] ERROR fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void startEditing() {
    if (userProfile.value != null) {
      nameEditVal.value = userProfile.value!.name;
      emailEditVal.value = userProfile.value!.email;
      phoneEditVal.value = userProfile.value!.phone;
      isEditing.value = true;
    }
  }

  void cancelEditing() {
    isEditing.value = false;
  }

  /// Saves name and email to WP REST API, then updates local state.
  Future<void> saveProfile() async {
    final newName = nameEditVal.value.trim();
    final newEmail = emailEditVal.value.trim();

    if (newName.isEmpty) {
      Get.snackbar(
        'Error',
        'Name cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Basic email format check before hitting the API
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');
    if (newEmail.isEmpty || !emailRegex.hasMatch(newEmail)) {
      Get.snackbar(
        'Error',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSaving.value = true;

      final token = _sessionManager.getToken();
      if (token.isEmpty) {
        Get.snackbar(
          'Error',
          'You are not logged in.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // POST to WP REST API — send name and email
      final updated = await _userRepository.updateProfile(
        token: token,
        name: newName,
        email: newEmail,
      );

      // Update reactive state with the server-confirmed response
      userProfile.value = updated.copyWith(
        phone: phoneEditVal.value.trim(), // phone is local-only
      );

      // Keep AccountController display name + email in sync
      if (Get.isRegistered<AccountController>()) {
        Get.find<AccountController>().name.value = updated.name;
        Get.find<AccountController>().email.value = updated.email;
      }

      isEditing.value = false;

      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );

      log('[ProfileController] Profile updated: ${updated.name}');
    } catch (e) {
      final message = e
          .toString()
          .replaceAll('Exception: ', '')
          .replaceAll('FetchDataException: ', '');
      Get.snackbar(
        'Update Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
      log('[ProfileController] ERROR updating profile: $e');
    } finally {
      isSaving.value = false;
    }
  }
}
