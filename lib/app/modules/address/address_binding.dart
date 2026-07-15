import 'package:get/get.dart';
import 'package:iron_street_app/app/data/repositories/address_repository/address_repository.dart';
import 'address_controller.dart';

class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressRepository>(() => AddressRepository());
    Get.lazyPut<AddressController>(() => AddressController());
  }
}
