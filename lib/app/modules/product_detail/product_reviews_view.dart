import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:iron_street_app/app/data/models/product_review_model.dart';
import 'package:iron_street_app/app/modules/product_detail/product_detail_controller.dart';
import 'package:iron_street_app/app/utills/theme/app_colors.dart';

class ProductReviewsView extends StatelessWidget {
  const ProductReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailController>();
    final prodName = controller.productDetail.value?.name ?? 'Product Reviews';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color ?? Theme.of(context).textTheme.titleLarge?.color),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Reviews',
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              prodName,
              style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isReviewsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (controller.reviewsList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 60,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Reviews Yet',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no reviews for this product yet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculations for overview
        final reviews = controller.reviewsList;
        final int total = reviews.length;
        double sum = 0;
        final Map<int, int> ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
        for (var r in reviews) {
          sum += r.rating;
          ratingCounts[r.rating] = (ratingCounts[r.rating] ?? 0) + 1;
        }
        final double average = total > 0 ? sum / total : 0.0;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Overview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    // Average Rating Column
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            average.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          _buildReviewStars(average, size: 16),
                          const SizedBox(height: 6),
                          Text(
                            'Based on $total review${total > 1 ? 's' : ''}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      height: 80,
                      width: 1,
                      color: Theme.of(context).dividerColor,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Rating bars column
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [5, 4, 3, 2, 1].map((stars) {
                          final count = ratingCounts[stars] ?? 0;
                          final double pct = total > 0 ? count / total : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Text(
                                  '$stars ★',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 6,
                                      backgroundColor: Theme.of(context).dividerColor,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        stars >= 4
                                            ? Colors.green[600]!
                                            : stars == 3
                                                ? Colors.amber[600]!
                                                : Colors.orange[600]!,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 16,
                                  child: Text(
                                    count.toString(),
                                    textAlign: TextAlign.end,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'All Reviews',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: 16),
              // Review Cards List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                ),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return _buildReviewItem(context, review);
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewStars(double rating, {double size = 14}) {
    int fullStars = rating.floor();
    bool hasHalf = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, size: size, color: Colors.amber[700]);
        } else if (index == fullStars && hasHalf) {
          return Icon(Icons.star_half, size: size, color: Colors.amber[700]);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.amber[700]);
        }
      }),
    );
  }

  Widget _buildReviewItem(BuildContext context, ProductReviewModel review) {
    // Format date
    String dateStr = review.dateCreated;
    try {
      final DateTime parsed = DateTime.parse(review.dateCreated);
      dateStr = DateFormat('MMM dd, yyyy').format(parsed);
    } catch (_) {}

    final avatarUrl = review.reviewerAvatarUrls.size96.isNotEmpty
        ? review.reviewerAvatarUrls.size96
        : (review.reviewerAvatarUrls.size48.isNotEmpty
            ? review.reviewerAvatarUrls.size48
            : review.reviewerAvatarUrls.size24);

    final initial = review.reviewer.isNotEmpty
        ? review.reviewer.trim().substring(0, 1).toUpperCase()
        : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 36,
                height: 36,
                color: Theme.of(context).dividerColor,
                child: avatarUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            // Reviewer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          review.reviewer,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleSmall?.color,
                          ),
                        ),
                      ),
                      if (review.verified) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E3524) : Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 10, color: Theme.of(context).brightness == Brightness.dark ? Colors.green[300] : Colors.green[700]),
                              const SizedBox(width: 2),
                              Text(
                                'Verified',
                                style: GoogleFonts.poppins(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.green[300] : Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Stars
            _buildReviewStars(review.rating.toDouble(), size: 12),
          ],
        ),
        const SizedBox(height: 10),
        // Review Text
        Text(
          _cleanHtml(review.review),
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  String _cleanHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8377;', '₹')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
