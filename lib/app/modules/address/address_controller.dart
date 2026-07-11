import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/main_repositories.dart';
import '../cart/cart_controller.dart';

class AddressController extends GetxController {
  final MainRepositories repositories = Get.isRegistered<MainRepositories>()
      ? Get.find<MainRepositories>()
      : Get.put(MainRepositories());

  // Addresses represents a reactive view of the active WooCommerce session address
  var addresses = <AddressModel>[].obs;

  void syncFromWooCommerce(dynamic wcAddr) {
    if (wcAddr == null || (wcAddr.firstName.isEmpty && wcAddr.address1.isEmpty)) {
      addresses.clear();
      return;
    }
    
    addresses.assignAll([
      AddressModel(
        id: 'wc_active',
        name: '${wcAddr.firstName} ${wcAddr.lastName}'.trim(),
        phone: wcAddr.phone,
        addressLine1: wcAddr.address1,
        addressLine2: wcAddr.address2,
        city: wcAddr.city,
        state: wcAddr.state,
        postalCode: wcAddr.postcode,
        country: wcAddr.country.isNotEmpty ? wcAddr.country : 'India',
        addressType: 'Active Address',
        isDefault: true,
      )
    ]);
  }

  Future<void> syncAddressToWooCommerce(AddressModel address) async {
    try {
      final wcAddress = address.toWcAddress();
      // Update WooCommerce cart session addresses
      final response = await repositories.updateCustomerAddress(
        shippingAddress: wcAddress,
        billingAddress: wcAddress,
      );
      if (response != null) {
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().fetchCart();
        }
      }
    } catch (e) {
      String errMsg = e.toString();
      if (errMsg.contains('invalid_state') || errMsg.contains('is not valid')) {
        errMsg = "Invalid state code selected. If country is India, please enter a valid 2-letter state code (e.g., KA for Karnataka, MH for Maharashtra, DL for Delhi) or type the full name (e.g. Karnataka).";
      }
      Get.snackbar(
        'Address Sync Failed',
        errMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: const Color(0xFFC62828),
        duration: const Duration(seconds: 5),
      );
    }
  }

  void addAddress(AddressModel newAddress) {
    syncAddressToWooCommerce(newAddress);
  }

  void updateAddress(String id, AddressModel updatedAddress) {
    syncAddressToWooCommerce(updatedAddress);
  }

  void deleteAddress(String id) {
    _clearWooCommerceAddress();
  }

  void selectDefaultAddress(String id) {}

  AddressModel? get defaultAddress {
    return addresses.isNotEmpty ? addresses[0] : null;
  }

  Future<void> _clearWooCommerceAddress() async {
    try {
      final emptyAddress = {
        'first_name': '',
        'last_name': '',
        'company': '',
        'address_1': '',
        'address_2': '',
        'city': '',
        'state': '',
        'postcode': '',
        'country': '',
        'phone': '',
      };
      await repositories.updateCustomerAddress(
        shippingAddress: emptyAddress,
        billingAddress: emptyAddress,
      );
      addresses.clear();
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().fetchCart();
      }
    } catch (e) {
      // Fail silently to keep UX smooth
    }
  }
}
