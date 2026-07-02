// import 'package:get/get.dart';
// import '../../data/models/product_model.dart';

// class ProductDetailController extends GetxController {
//   late Product product;
//   var selectedImageIndex = 0.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     if (Get.arguments is Product) {
//       product = Get.arguments as Product;
//     } else {
//       // Fallback or handle null/incorrect arguments gracefully
//       Get.back();
//     }
//   }

//   void updateImageIndex(int index) {
//     selectedImageIndex.value = index;
//   }
// }

import 'package:get/get.dart';
import 'package:iron_street_app/app/data/models/product_detail_model.dart';
import 'package:iron_street_app/app/data/models/related_product_list.dart';
import 'package:iron_street_app/app/data/repositories/main_repositories.dart';

class ProductDetailController extends GetxController {
  final MainRepositories repositories;

  ProductDetailController({required this.repositories});

  var isLoading = false.obs;
  var isRelatedProductsLoading = false.obs;

  var productDetail = Rxn<ProductDetailModel>();
  var relatedProducts = <ProductRelatedListModel>[].obs;

  var selectedImageIndex = 0.obs;
  var quantity = 1.obs;

  int productId = 0;

  @override
  void onInit() {
    super.onInit();

    // final args = Get.arguments;

    // if (args is int) {
    //   productId = args;
    // } else if (args is String) {
    //   productId = int.tryParse(args) ?? 0;
    // } else if (args is Map && args['productId'] != null) {
    //   productId = int.tryParse(args['productId'].toString()) ?? 0;
    // }
    productId = _getProductIdFromArguments();

    if (productId != 0) {
      fetchProductDetail(productId);
    } else {
      Get.snackbar('Error', 'Invalid product id');
    }
  }

  int _getProductIdFromArguments() {
    final args = Get.arguments;

    if (args is int) {
      return args;
    }

    if (args is String) {
      return int.tryParse(args) ?? 0;
    }

    if (args is Map && args['productId'] != null) {
      return int.tryParse(args['productId'].toString()) ?? 0;
    }

    return 0;
  }

  // Future<void> fetchProductDetail(int id) async {
  //   try {
  //     isLoading.value = true;

  //     dynamic response = await repositories.fetchProductDetail(productId: id);

  //     productDetail.value = ProductDetailModel.fromJson(response);

  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load product detail');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchProductDetail(int id) async {
    try {
      isLoading.value = true;
      selectedImageIndex.value = 0;
      relatedProducts.clear();

      dynamic response = await repositories.fetchProductDetail(productId: id);

      final detail = ProductDetailModel.fromJson(response);

      productDetail.value = detail;

      // IMPORTANT: Load related products after product detail loaded
      await fetchRelatedProducts(detail.relatedIds);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load product detail');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRelatedProducts(List<int> relatedIds) async {
    if (relatedIds.isEmpty) return;

    try {
      isRelatedProductsLoading.value = true;

      dynamic response = await repositories.fetchRelatedProductsByIds(
        productIds: relatedIds,
      );

      List<ProductRelatedListModel> fetchedProducts = (response as List)
          .map((json) => ProductRelatedListModel.fromJson(json))
          .toList();

      relatedProducts.assignAll(fetchedProducts);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load related products');
    } finally {
      isRelatedProductsLoading.value = false;
    }
  }

  void changeImage(int index) {
    selectedImageIndex.value = index;
  }

  void openRelatedProduct(ProductRelatedListModel product) {
    if (product.id == 0) {
      Get.snackbar('Error', 'Invalid related product id');
      return;
    }
    // Get.toNamed(Routes.PRODUCT_DETAIL,
    //     // arguments: {
    //     //   'productId': product.id,
    //     // },
    //     arguments: product.id);
    fetchProductDetail(product.id);
  }

  void increaseQuantity() {
    quantity.value++;
  }

  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  String cleanHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8377;', '₹')
        .trim();
  }
}
