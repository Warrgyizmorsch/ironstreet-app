class ProductRelatedListModel {
  final int id;
  final String name;
  final String price;
  final String regularPrice;
  final String salePrice;
  final List<ProductListImageModel> images;

  ProductRelatedListModel({
    required this.id,
    required this.name,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.images,
  });

  factory ProductRelatedListModel.fromJson(Map<String, dynamic> json) {
    return ProductRelatedListModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] ?? '0',
      regularPrice: json['regular_price'] ?? '0',
      salePrice: json['sale_price'] ?? '0',
      images: (json['images'] as List? ?? [])
          .map((e) => ProductListImageModel.fromJson(e))
          .toList(),
    );
  }
}

class ProductListImageModel {
  final String src;

  ProductListImageModel({
    required this.src,
  });

  factory ProductListImageModel.fromJson(Map<String, dynamic> json) {
    return ProductListImageModel(
      src: json['src'] ?? '',
    );
  }
}