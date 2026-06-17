

import 'package:get/get.dart';
import '../../data/models/product_model.dart';

class ProductDetailController extends GetxController {
  late Product product;
  var selectedImageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Product) {
      product = Get.arguments as Product;
    } else {
      // Fallback or handle null/incorrect arguments gracefully
      Get.back();
    }
  }

  void updateImageIndex(int index) {
    selectedImageIndex.value = index;
  }
}
