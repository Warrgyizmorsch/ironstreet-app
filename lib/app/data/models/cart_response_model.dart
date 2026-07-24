import 'package:iron_street_app/app/data/models/product_model.dart';
import 'package:iron_street_app/app/data/models/address_model.dart';

class CartResponseModel {
  final List<CartItemModel> items;
  final CartTotalsModel totals;
  final int itemsCount;
  final CartAddressModel? shippingAddress;
  final CartAddressModel? billingAddress;

  CartResponseModel({
    required this.items,
    required this.totals,
    required this.itemsCount,
    this.shippingAddress,
    this.billingAddress,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      items: (json['items'] as List? ?? [])
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totals: CartTotalsModel.fromJson(json['totals'] ?? {}),
      itemsCount: json['items_count'] ?? 0,
      shippingAddress: json['shipping_address'] != null 
          ? CartAddressModel.fromJson(json['shipping_address']) 
          : null,
      billingAddress: json['billing_address'] != null 
          ? CartAddressModel.fromJson(json['billing_address']) 
          : null,
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
  final double? weightKg;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;

  CartItemModel({
    required this.key,
    required this.id,
    required this.quantity,
    required this.name,
    required this.image,
    required this.price,
    required this.regularPrice,
    this.weightKg,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
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

    final extensionsObj = json['extensions'] ?? {};
    final ironstreetShipping = extensionsObj['ironstreet_shipping'] ?? {};
    
    final weightObj = ironstreetShipping['weight'] ?? {};
    final double? weightVal = double.tryParse(weightObj['value']?.toString() ?? '');
    
    final dimObj = ironstreetShipping['dimensions'] ?? {};
    final double? lengthVal = double.tryParse(dimObj['length']?.toString() ?? '');
    final double? widthVal = double.tryParse(dimObj['width']?.toString() ?? '');
    final double? heightVal = double.tryParse(dimObj['height']?.toString() ?? '');

    return CartItemModel(
      key: json['key'] ?? '',
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 1,
      name: json['name'] ?? '',
      image: imageUrl,
      price: priceVal,
      regularPrice: regPriceVal,
      weightKg: weightVal,
      lengthCm: lengthVal,
      widthCm: widthVal,
      heightCm: heightVal,
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
  final double totalDiscount;
  final double totalShippingTax;

  CartTotalsModel({
    required this.totalPrice,
    required this.totalItems,
    required this.totalTax,
    required this.totalShipping,
    required this.totalDiscount,
    required this.totalShippingTax,
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
    final double discountVal = (double.tryParse(json['total_discount']?.toString() ?? '0') ?? 0.0) / factor;
    final double shippingTaxVal = (double.tryParse(json['total_shipping_tax']?.toString() ?? '0') ?? 0.0) / factor;

    return CartTotalsModel(
      totalPrice: totalVal,
      totalItems: itemsVal,
      totalTax: taxVal,
      totalShipping: shippingVal,
      totalDiscount: discountVal,
      totalShippingTax: shippingTaxVal,
    );
  }
}

class CartAddressModel {
  final String firstName;
  final String lastName;
  final String company;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String phone;
  final String email;

  CartAddressModel({
    required this.firstName,
    required this.lastName,
    required this.company,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    required this.phone,
    required this.email,
  });

  factory CartAddressModel.fromJson(Map<String, dynamic> json) {
    return CartAddressModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      company: json['company'] ?? '',
      address1: json['address_1'] ?? '',
      address2: json['address_2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  String get fullAddress {
    return [address1, address2, city, state, postcode, country]
        .where((s) => s.isNotEmpty)
        .join(', ');
  }

  AddressModel toAddressModel() {
    return AddressModel(
      id: '',
      name: '$firstName $lastName'.trim(),
      phone: phone,
      addressLine1: address1,
      addressLine2: address2,
      city: city,
      state: state,
      postalCode: postcode,
      country: country.isEmpty ? 'India' : country,
      addressType: 'Home',
      isDefault: true,
    );
  }
}
