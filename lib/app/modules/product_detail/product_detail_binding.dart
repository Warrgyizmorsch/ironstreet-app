import 'package:get/get.dart';
import 'package:iron_street_app/app/data/repositories/main_repositories.dart';
import 'product_detail_controller.dart';

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailController>(() => ProductDetailController(
          repositories: Get.find<MainRepositories>(),
        ));
  }
}
