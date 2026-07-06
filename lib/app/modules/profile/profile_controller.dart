import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../account/account_controller.dart';

class ProfileController extends GetxController {
  final userProfile = Rxn<UserModel>();

  // Observables for editing fields
  var isEditing = false.obs;
  var nameEditVal = ''.obs;
  var phoneEditVal = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  void _loadProfile() {
    // Seed with a default user profile matching Ananya Sharma from the account module
    userProfile.value = UserModel(
      id: 'usr_7341',
      name: 'Imam',
      email: 'imam123@gmail.com',
      phone: '+91 7321862469',
      profileImage: 'https://i.pravatar.cc/300?u=user123',
      memberStatus: 'Gold Club Member',
      joinedDate: 'Joined April 2024',
    );
  }

  void startEditing() {
    if (userProfile.value != null) {
      nameEditVal.value = userProfile.value!.name;
      phoneEditVal.value = userProfile.value!.phone;
      isEditing.value = true;
    }
  }

  void cancelEditing() {
    isEditing.value = false;
  }

  void saveProfile() {
    if (nameEditVal.value.trim().isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (phoneEditVal.value.trim().isEmpty) {
      Get.snackbar('Error', 'Phone number cannot be empty',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (userProfile.value != null) {
      userProfile.value = userProfile.value!.copyWith(
        name: nameEditVal.value.trim(),
        phone: phoneEditVal.value.trim(),
      );

      // Update AccountController as well if it is registered
      if (Get.isRegistered<AccountController>()) {
        Get.find<AccountController>().name.value = nameEditVal.value.trim();
        Get.find<AccountController>().email.value = userProfile.value!.email;
      }

      isEditing.value = false;
      Get.snackbar('Success', 'Profile updated successfully!',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
