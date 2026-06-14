/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

class CategoryItem {
  final String id;
  final String title;
  final String image;

  CategoryItem({
    required this.id,
    required this.title,
    required this.image,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class BannerItem {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String promoText;

  BannerItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.promoText,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      promoText: json['promoText'] ?? '',
    );
  }
}

class GridCategory {
  final String id;
  final String title;
  final String image;

  GridCategory({
    required this.id,
    required this.title,
    required this.image,
  });
}

class FurnishingItem {
  final String id;
  final String title;
  final String priceText;
  final String image;

  FurnishingItem({
    required this.id,
    required this.title,
    required this.priceText,
    required this.image,
  });

  factory FurnishingItem.fromJson(Map<String, dynamic> json) {
    return FurnishingItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      priceText: json['priceText'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class DecorItem {
  final String id;
  final String title;
  final String priceText;
  final String image;

  DecorItem({
    required this.id,
    required this.title,
    required this.priceText,
    required this.image,
  });

  factory DecorItem.fromJson(Map<String, dynamic> json) {
    return DecorItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      priceText: json['priceText'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class ExperienceStore {
  final String id;
  final String name;
  final String address;
  final String city;
  final String timings;
  final String phone;
  final String image;

  ExperienceStore({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.timings,
    required this.phone,
    required this.image,
  });

  factory ExperienceStore.fromJson(Map<String, dynamic> json) {
    return ExperienceStore(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      timings: json['timings'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
