// class CategoryModel {
//   final int id;
//   final String name;
//   final String slug;
//   final int parentId;
//   final int count;
//   final String? imageUrl;

//   CategoryModel({
//     required this.id,
//     required this.name,
//     required this.slug,
//     required this.parentId,
//     required this.count,
//     this.imageUrl,
//   });

//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     String? parsedImageUrl;
//     if (json['image'] != null && json['image'] is Map) {
//       parsedImageUrl = json['image']['src'];
//     } else if (json['imageUrl'] != null) {
//       parsedImageUrl = json['imageUrl'];
//     }

//     return CategoryModel(
//       id: json['id'] ?? 0,
//       name: json['name'] ?? '',
//       slug: json['slug'] ?? '',
//       // WooCommerce uses 'parent', but Node.js BFF might map it to 'parentId'
//       parentId: json['parent'] ?? json['parentId'] ?? 0,
//       count: json['count'] ?? 0,
//       imageUrl: parsedImageUrl,
//     );
//   }
// }

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int parentId;
  final int count;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.parentId,
    required this.count,
    this.image = '',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      parentId: json['parent'] ?? 0,
      count: json['count'] ?? 0,
      image: json['image'] != null ? json['image']['src'] ?? '' : '',
    );
  }
}
