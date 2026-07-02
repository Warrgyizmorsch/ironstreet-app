class ProductDetailModel {
  final int id;
  final String name;
  final String slug;
  final String permalink;
  final String description;
  final String shortDescription;
  final String sku;
  final String price;
  final String regularPrice;
  final String salePrice;
  final bool onSale;
  final bool purchasable;
  final String stockStatus;
  final String averageRating;
  final int ratingCount;
  final List<ProductImageModel> images;
  final List<ProductAttributeModel> attributes;
  final List<ProductCategoryModel> categories;
  final List<int> relatedIds;

  ProductDetailModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.permalink,
    required this.description,
    required this.shortDescription,
    required this.sku,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.onSale,
    required this.purchasable,
    required this.stockStatus,
    required this.averageRating,
    required this.ratingCount,
    required this.images,
    required this.attributes,
    required this.categories,
    required this.relatedIds,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      permalink: json['permalink'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      sku: json['sku'] ?? '',
      price: json['price'] ?? '0',
      regularPrice: json['regular_price'] ?? '0',
      salePrice: json['sale_price'] ?? '0',
      onSale: json['on_sale'] ?? false,
      purchasable: json['purchasable'] ?? false,
      stockStatus: json['stock_status'] ?? '',
      averageRating: json['average_rating'] ?? '0.00',
      ratingCount: json['rating_count'] ?? 0,
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImageModel.fromJson(e))
          .toList(),
      attributes: (json['attributes'] as List? ?? [])
          .map((e) => ProductAttributeModel.fromJson(e))
          .toList(),
      categories: (json['categories'] as List? ?? [])
          .map((e) => ProductCategoryModel.fromJson(e))
          .toList(),
      relatedIds: (json['related_ids'] as List? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList(),
    );
  }
}

class ProductImageModel {
  final int id;
  final String src;
  final String name;
  final String alt;
  final String thumbnail;

  ProductImageModel({
    required this.id,
    required this.src,
    required this.name,
    required this.alt,
    required this.thumbnail,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? 0,
      src: json['src'] ?? '',
      name: json['name'] ?? '',
      alt: json['alt'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}

class ProductAttributeModel {
  final int id;
  final String name;
  final String slug;
  final bool visible;
  final List<String> options;

  ProductAttributeModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.visible,
    required this.options,
  });

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      visible: json['visible'] ?? false,
      options:
          (json['options'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class ProductCategoryModel {
  final int id;
  final String name;
  final String slug;

  ProductCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
