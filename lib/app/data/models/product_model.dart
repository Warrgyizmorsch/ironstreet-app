/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

class Product {
  final String id;
  final String name;
  final String brand;
  final double price;
  final double oldPrice;
  final double discount;
  final double rating;
  final int reviewsCount;
  final String image;
  final List<String> images;
  final String description;
  final String deliveryText;
  final String dimensions;
  final String material;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.rating,
    required this.reviewsCount,
    required this.image,
    required this.images,
    required this.description,
    required this.deliveryText,
    required this.dimensions,
    required this.material,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      oldPrice: (json['oldPrice'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      image: json['image'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      description: json['description'] ?? '',
      deliveryText: json['deliveryText'] ?? '',
      dimensions: json['dimensions'] ?? '',
      material: json['material'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': price,
      'oldPrice': oldPrice,
      'discount': discount,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'image': image,
      'images': images,
      'description': description,
      'deliveryText': deliveryText,
      'dimensions': dimensions,
      'material': material,
      'category': category,
    };
  }
}
