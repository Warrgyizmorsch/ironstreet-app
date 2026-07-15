
import 'package:get/get.dart';
import 'package:iron_street_app/app/data/repositories/category_repository/category_repository.dart';
import 'category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryRepository>(() => CategoryRepository());
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
