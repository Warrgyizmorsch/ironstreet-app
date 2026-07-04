class ProductTagModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final int count;

  ProductTagModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.count,
  });

  factory ProductTagModel.fromJson(Map<String, dynamic> json) {
    return ProductTagModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}