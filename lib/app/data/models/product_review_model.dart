class ProductReviewModel {
  final int id;
  final String dateCreated;
  final int productId;
  final String productName;
  final String reviewer;
  final String review;
  final int rating;
  final bool verified;
  final ReviewerAvatarUrls reviewerAvatarUrls;

  ProductReviewModel({
    required this.id,
    required this.dateCreated,
    required this.productId,
    required this.productName,
    required this.reviewer,
    required this.review,
    required this.rating,
    required this.verified,
    required this.reviewerAvatarUrls,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    return ProductReviewModel(
      id: json['id'] ?? 0,
      dateCreated: json['date_created'] ?? '',
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      reviewer: json['reviewer'] ?? '',
      review: json['review'] ?? '',
      rating: json['rating'] ?? 0,
      verified: json['verified'] ?? false,
      reviewerAvatarUrls: ReviewerAvatarUrls.fromJson(json['reviewer_avatar_urls'] ?? {}),
    );
  }
}

class ReviewerAvatarUrls {
  final String size24;
  final String size48;
  final String size96;

  ReviewerAvatarUrls({
    required this.size24,
    required this.size48,
    required this.size96,
  });

  factory ReviewerAvatarUrls.fromJson(Map<String, dynamic> json) {
    return ReviewerAvatarUrls(
      size24: json['24'] ?? '',
      size48: json['48'] ?? '',
      size96: json['96'] ?? '',
    );
  }
}
