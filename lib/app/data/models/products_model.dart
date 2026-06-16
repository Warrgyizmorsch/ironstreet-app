class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String shortDescription;
  final String price;
  final String regularPrice;
  final String salePrice;
  final bool onSale;
  final String stockStatus;
  final String averageRating;
  final List<ProductCategory> categories;
  final List<ProductImage> images;
  final List<ProductAttribute> attributes;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.onSale,
    required this.stockStatus,
    required this.averageRating,
    required this.categories,
    required this.images,
    required this.attributes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      // Note: These contain HTML tags. Use flutter_html to render them.
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      
      // Converting to strings safely in case API returns ints occasionally
      price: json['price']?.toString() ?? '',
      regularPrice: json['regular_price']?.toString() ?? '',
      salePrice: json['sale_price']?.toString() ?? '',
      
      onSale: json['on_sale'] ?? false,
      stockStatus: json['stock_status'] ?? 'outofstock',
      averageRating: json['average_rating']?.toString() ?? '0.00',
      
      // Parse nested arrays safely
      categories: json['categories'] != null
          ? List<ProductCategory>.from(
              json['categories'].map((x) => ProductCategory.fromJson(x)))
          : [],
      images: json['images'] != null
          ? List<ProductImage>.from(
              json['images'].map((x) => ProductImage.fromJson(x)))
          : [],
      attributes: json['attributes'] != null
          ? List<ProductAttribute>.from(
              json['attributes'].map((x) => ProductAttribute.fromJson(x)))
          : [],
    );
  }
}

class ProductCategory {
  final int id;
  final String name;
  final String slug;

  ProductCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}

class ProductImage {
  final int id;
  final String src;
  final String alt;

  ProductImage({
    required this.id,
    required this.src,
    required this.alt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      src: json['src'] ?? '',
      alt: json['alt'] ?? '',
    );
  }
}

class ProductAttribute {
  final int id;
  final String name;
  final List<String> options;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.options,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    return ProductAttribute(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      // Extract the array of string options (e.g., ["Matte black / Optional metallic finishes"])
      options: json['options'] != null ? List<String>.from(json['options']) : [],
    );
  }
}