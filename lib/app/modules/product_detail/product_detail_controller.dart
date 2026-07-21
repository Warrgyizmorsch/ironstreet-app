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

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:iron_street_app/app/widgets/custom_toast.dart';
import 'package:iron_street_app/app/data/models/product_detail_model.dart';
import 'package:iron_street_app/app/data/models/product_review_model.dart';
import 'package:iron_street_app/app/data/models/product_list_model.dart';
import 'package:iron_street_app/app/data/local/session_manager.dart';
import 'package:iron_street_app/app/data/repositories/product_repository/product_repository.dart';
import 'package:iron_street_app/app/data/repositories/delivery_repository/delivery_repository.dart';
import 'package:iron_street_app/app/modules/cart/cart_controller.dart';

class ProductDetailController extends GetxController {
  final ProductRepository productRepository = Get.find<ProductRepository>();

  var isLoading = false.obs;
  var isRelatedProductsLoading = false.obs;
  var isReviewsLoading = false.obs;

  var productDetail = Rxn<ProductDetailModel>();
  var relatedProducts = <ProductListModel>[].obs;
  var reviewsList = <ProductReviewModel>[].obs;

  var selectedImageIndex = 0.obs;
  var quantity = 1.obs;

  // Delhivery Pincode Serviceability variables
  final DeliveryRepository _deliveryRepository = DeliveryRepository();
  var isCheckingPincode = false.obs;
  var enteredPincode = ''.obs;
  var pincodeResult = Rxn<Map<String, dynamic>>();
  var pincodeError = ''.obs;

  int productId = 0;

  final PageController imagePageController = PageController();

  Timer? imageAutoScrollTimer;

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
      CustomToast.show('Invalid product id', isError: true);
    }
  }

  @override
  void onClose() {
    imageAutoScrollTimer?.cancel();
    imagePageController.dispose();
    super.onClose();
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
  //     CustomToast.show('Failed to load product detail', isError: true);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> fetchProductDetail(int id) async {
    try {
      isLoading.value = true;
      selectedImageIndex.value = 0;
      relatedProducts.clear();
      reviewsList.clear();

      imageAutoScrollTimer?.cancel();

      dynamic response = await productRepository.fetchProductDetail(productId: id);

      final detail = ProductDetailModel.fromJson(response);

      productDetail.value = detail;
      if (imagePageController.hasClients) {
        imagePageController.jumpToPage(0);
      }
      _startImageAutoScroll();

      // Trigger automatic pincode check from address if available
      autoCheckSavedAddressPincode();

      // IMPORTANT: Load related products and reviews after product detail loaded
      await Future.wait([
        fetchRelatedProducts(detail.relatedIds),
        fetchProductReviews(id),
      ]);
    } catch (e) {
      CustomToast.show('Failed to load product detail', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProductReviews(int id) async {
    try {
      isReviewsLoading.value = true;
      dynamic response = await productRepository.fetchProductReviews(productId: id);
      List<ProductReviewModel> fetchedReviews = (response as List)
          .map((json) => ProductReviewModel.fromJson(json))
          .toList();
      reviewsList.assignAll(fetchedReviews);
    } catch (e) {
      CustomToast.show('Failed to load reviews', isError: true);
    } finally {
      isReviewsLoading.value = false;
    }
  }

  void _startImageAutoScroll() {
    imageAutoScrollTimer?.cancel();

    final int totalImages = productDetail.value?.images.length ?? 0;

    if (totalImages <= 1) return;

    imageAutoScrollTimer = Timer.periodic(
      const Duration(seconds: 4),
      (timer) {
        if (!imagePageController.hasClients) return;

        int nextPage = selectedImageIndex.value + 1;

        if (nextPage >= totalImages) {
          nextPage = 0;
        }

        imagePageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOut,
        );

        selectedImageIndex.value = nextPage;
      },
    );
  }

  Future<void> checkDelhiveryPincode(String pincode) async {
    final cleaned = pincode.trim();
    if (cleaned.length != 6 || int.tryParse(cleaned) == null) {
      pincodeError.value = 'Please enter a valid 6-digit pincode';
      pincodeResult.value = null;
      return;
    }

    try {
      isCheckingPincode.value = true;
      pincodeError.value = '';
      enteredPincode.value = cleaned;

      final response = await _deliveryRepository.checkPincodeServiceability(cleaned);

      if (response != null && response['delivery_codes'] != null) {
        final List deliveryCodes = response['delivery_codes'];
        if (deliveryCodes.isNotEmpty) {
          final postalCodeData = deliveryCodes.first['postal_code'];
          if (postalCodeData != null) {
            pincodeResult.value = Map<String, dynamic>.from(postalCodeData);
            return;
          }
        }
      }
      pincodeResult.value = {'unserviceable': true};
    } catch (e) {
      pincodeError.value = 'Failed to verify pincode serviceability';
      pincodeResult.value = null;
    } finally {
      isCheckingPincode.value = false;
    }
  }

  void autoCheckSavedAddressPincode() {
    try {
      if (Get.isRegistered<CartController>()) {
        final cartController = Get.find<CartController>();
        final shippingAddr = cartController.shippingAddress.value;
        if (shippingAddr != null && shippingAddr.postcode.isNotEmpty) {
          final pincode = shippingAddr.postcode.trim();
          if (pincode.length == 6 && int.tryParse(pincode) != null) {
            checkDelhiveryPincode(pincode);
          }
        }
      }
    } catch (e) {
      // Silent catch
    }
  }

  Future<void> fetchRelatedProducts(List<int> relatedIds) async {
    if (relatedIds.isEmpty) return;

    try {
      isRelatedProductsLoading.value = true;

      dynamic response = await productRepository.fetchRelatedProductsByIds(
        productIds: relatedIds,
      );

      List<ProductListModel> fetchedProducts = (response as List)
          .map((json) => ProductListModel.fromJson(json))
          .toList();

      relatedProducts.assignAll(fetchedProducts);
    } catch (e) {
      CustomToast.show('Failed to load related products', isError: true);
    } finally {
      isRelatedProductsLoading.value = false;
    }
  }

  var isSubmittingReview = false.obs;

  Future<bool> submitReview({
    required String review,
    required int rating,
  }) async {
    final prod = productDetail.value;
    if (prod == null) return false;

    final sessionManager = Get.find<SessionManager>();
    final reviewerName = sessionManager.getName();
    final reviewerEmail = sessionManager.getEmail();

    try {
      isSubmittingReview.value = true;

      final response = await productRepository.submitProductReview(
        productId: prod.id,
        reviewer: reviewerName.isNotEmpty ? reviewerName : 'Anonymous',
        email: reviewerEmail.isNotEmpty ? reviewerEmail : 'anonymous@example.com',
        review: review,
        rating: rating,
      );

      if (response != null) {
        CustomToast.show('Review submitted successfully!', isSuccess: true);
        // Refresh reviews list
        await fetchProductReviews(prod.id);
        return true;
      }
      return false;
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('comment_duplicate') || errorMsg.contains('duplicate')) {
        CustomToast.show('You have already submitted a review for this product.', isError: true);
      } else {
        CustomToast.show('Failed to submit review. Please try again.', isError: true);
      }
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  void changeImage(int index) {
    selectedImageIndex.value = index;
    if (imagePageController.hasClients &&
        imagePageController.page?.round() != index) {
      imagePageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void openRelatedProduct(ProductListModel product) {
    if (product.id == 0) {
      CustomToast.show('Invalid related product id', isError: true);
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
