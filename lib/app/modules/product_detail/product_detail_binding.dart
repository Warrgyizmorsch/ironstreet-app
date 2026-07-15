import 'package:get/get.dart';
import 'package:iron_street_app/app/data/repositories/product_repository/product_repository.dart';
import 'product_detail_controller.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductRepository>(() => ProductRepository());
    Get.lazyPut<ProductDetailController>(() => ProductDetailController());
  }
}
