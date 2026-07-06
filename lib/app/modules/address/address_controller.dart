import 'package:get/get.dart';
import '../../data/models/address_model.dart';


class AddressController extends GetxController {
  var addresses = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyAddresses();
  }

  void _loadDummyAddresses() {
    addresses.assignAll([
      AddressModel(
        id: 'addr_1',
        name: 'Ananya Sharma',
        phone: '+91 98765 43210',
        addressLine1: 'Flat 402, Sunshine Residency',
        addressLine2: '12th Main, 4th Sector, HSR Layout',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560102',
        country: 'India',
        addressType: 'Home',
        isDefault: true,
      ),
      AddressModel(
        id: 'addr_2',
        name: 'Ananya Sharma (Office)',
        phone: '+91 98765 11223',
        addressLine1: 'Tower B, Global Tech Park',
        addressLine2: 'Outer Ring Road, Devarabeesanahalli',
        city: 'Bengaluru',
        state: 'Karnataka',
        postalCode: '560103',
        country: 'India',
        addressType: 'Work',
        isDefault: false,
      ),
    ]);
  }

  void addAddress(AddressModel newAddress) {
    if (newAddress.isDefault) {
      // Set all other addresses to non-default
      for (var i = 0; i < addresses.length; i++) {
        if (addresses[i].isDefault) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }
    }
    // If it's the first address, make it default anyway
    if (addresses.isEmpty) {
      newAddress = newAddress.copyWith(isDefault: true);
    }
    addresses.add(newAddress);
    Get.snackbar(
      'Address Added',
      'Successfully added new address: ${newAddress.addressType}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateAddress(String id, AddressModel updatedAddress) {
    if (updatedAddress.isDefault) {
      // Set all other addresses to non-default
      for (var i = 0; i < addresses.length; i++) {
        if (addresses[i].id != id && addresses[i].isDefault) {
          addresses[i] = addresses[i].copyWith(isDefault: false);
        }
      }
    }
    
    int index = addresses.indexWhere((element) => element.id == id);
    if (index != -1) {
      addresses[index] = updatedAddress;
      
      // Ensure at least one default address exists
      bool hasDefault = addresses.any((element) => element.isDefault);
      if (!hasDefault && addresses.isNotEmpty) {
        addresses[0] = addresses[0].copyWith(isDefault: true);
      }
      
      Get.snackbar(
        'Address Updated',
        'Successfully updated address details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteAddress(String id) {
    var item = addresses.firstWhereOrNull((e) => e.id == id);
    if (item == null) return;
    
    bool deletedWasDefault = item.isDefault;
    addresses.removeWhere((element) => element.id == id);
    
    if (deletedWasDefault && addresses.isNotEmpty) {
      addresses[0] = addresses[0].copyWith(isDefault: true);
    }
    
    Get.snackbar(
      'Address Deleted',
      'Address was removed from your address book',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void selectDefaultAddress(String id) {
    for (var i = 0; i < addresses.length; i++) {
      if (addresses[i].id == id) {
        addresses[i] = addresses[i].copyWith(isDefault: true);
      } else if (addresses[i].isDefault) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }
    }
    addresses.refresh();
    Get.snackbar(
      'Default Updated',
      'Changed default delivery address',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  AddressModel? get defaultAddress {
    return addresses.firstWhereOrNull((element) => element.isDefault) ?? 
           (addresses.isNotEmpty ? addresses[0] : null);
  }
}
