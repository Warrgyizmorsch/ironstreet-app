import 'package:iron_street_app/app/data/models/product_model.dart';

class CartResponseModel {
  final List<CartItemModel> items;
  final CartTotalsModel totals;
  final int itemsCount;

  CartResponseModel({
    required this.items,
    required this.totals,
    required this.itemsCount,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      items: (json['items'] as List? ?? [])
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totals: CartTotalsModel.fromJson(json['totals'] ?? {}),
      itemsCount: json['items_count'] ?? 0,
    );
  }
}

class CartItemModel {
  final String key;
  final int id;
  final int quantity;
  final String name;
  final String image;
  final double price;
  final double regularPrice;

  CartItemModel({
    required this.key,
    required this.id,
    required this.quantity,
    required this.name,
    required this.image,
    required this.price,
    required this.regularPrice,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List? ?? [];
    final imageUrl = imagesList.isNotEmpty ? (imagesList[0]['src'] ?? '') : '';

    final pricesObj = json['prices'] ?? {};
    final int minorUnit = pricesObj['currency_minor_unit'] ?? 2;
    
    double factor = 1.0;
    for (int i = 0; i < minorUnit; i++) {
      factor *= 10.0;
    }

    final double priceVal = (double.tryParse(pricesObj['price']?.toString() ?? '0') ?? 0.0) / factor;
    final double regPriceVal = (double.tryParse(pricesObj['regular_price']?.toString() ?? '0') ?? 0.0) / factor;

    return CartItemModel(
      key: json['key'] ?? '',
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      name: json['name'] ?? '',
      image: imageUrl,
      price: priceVal,
      regularPrice: regPriceVal,
    );
  }

  Product toProduct() {
    return Product(
      id: id.toString(),
      name: name,
      brand: '',
      price: price,
      oldPrice: regularPrice,
      discount: regularPrice > price ? (((regularPrice - price) / regularPrice) * 100) : 0.0,
      rating: 0.0,
      reviewsCount: 0,
      image: image,
      images: [image],
      description: '',
      deliveryText: '',
      dimensions: '',
      material: '',
      category: '',
    );
  }
}

class CartTotalsModel {
  final double totalPrice;
  final double totalItems;
  final double totalTax;
  final double totalShipping;

  CartTotalsModel({
    required this.totalPrice,
    required this.totalItems,
    required this.totalTax,
    required this.totalShipping,
  });

  factory CartTotalsModel.fromJson(Map<String, dynamic> json) {
    final int minorUnit = json['currency_minor_unit'] ?? 2;
    
    double factor = 1.0;
    for (int i = 0; i < minorUnit; i++) {
      factor *= 10.0;
    }

    final double totalVal = (double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0) / factor;
    final double itemsVal = (double.tryParse(json['total_items']?.toString() ?? '0') ?? 0.0) / factor;
    final double taxVal = (double.tryParse(json['total_tax']?.toString() ?? '0') ?? 0.0) / factor;
    final double shippingVal = (double.tryParse(json['total_shipping']?.toString() ?? '0') ?? 0.0) / factor;

    return CartTotalsModel(
      totalPrice: totalVal,
      totalItems: itemsVal,
      totalTax: taxVal,
      totalShipping: shippingVal,
    );
  }
}
