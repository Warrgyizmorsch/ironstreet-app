class ProductListModel {
  final int id;
  final String name;
  final double price;
  final double oldPrice;
  final double discount;
  final String image;
  final String brand;
  final double rating;
  final int reviewsCount;
  final String description;

  ProductListModel({
    required this.id,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.image,
    required this.brand,
    required this.rating,
    required this.reviewsCount,
    required this.description,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    // 1. Parse Prices Safely (WooCommerce sends prices as Strings)
    double currentPrice = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
    double regularPrice = double.tryParse(json['regular_price']?.toString() ?? '0') ?? 0.0;
    
    // If no regular price is set, make it equal to current price so UI doesn't break
    if (regularPrice == 0.0) {
      regularPrice = currentPrice;
    }

    // 2. Calculate Discount Percentage Automatically
    double calculatedDiscount = 0.0;
    if (regularPrice > currentPrice && regularPrice > 0) {
      calculatedDiscount = ((regularPrice - currentPrice) / regularPrice) * 100;
    }

    // 3. Extract the First Image Safely
    String imageUrl = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imageUrl = json['images'][0]['src'] ?? '';
    }

    // 4. Extract "Brand Name" from Attributes Array
    String brandName = 'Ironstreets'; // Default fallback
    if (json['attributes'] != null) {
      var attributes = json['attributes'] as List;
      for (var attr in attributes) {
        if (attr['name'] == 'Brand Name' || attr['name'] == 'Brand') {
          if (attr['options'] != null && (attr['options'] as List).isNotEmpty) {
            brandName = attr['options'][0].toString();
            break; // Found the brand, exit loop
          }
        }
      }
    }

    // 5. Parse Rating Safely
    double ratingVal = double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0;

    return ProductListModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: currentPrice,
      oldPrice: regularPrice,
      discount: calculatedDiscount,
      image: imageUrl,
      brand: brandName,
      rating: ratingVal,
      reviewsCount: json['rating_count'] ?? 0,
      description: json['short_description'] ?? json['description'] ?? '',
    );
  }
}