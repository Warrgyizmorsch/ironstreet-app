// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:iron_street_app/app/data/models/category_model.dart';

// import '../data/models/other_models.dart';

// class CategoryCard extends StatelessWidget {
//   final CategoryModel category;
//   final VoidCallback onTap;

//   const CategoryCard({
//     Key? key,
//     required this.category,
//     required this.onTap,
//   }) : super(key: key);

// ignore_for_file: deprecated_member_use

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           // Circular Avatar Image Wrapper
//           Container(
//             width: 58,
//             height: 58,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: const Color(0xFFE5E5E5), width: 1.5),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(29),
//               child: CachedNetworkImage(
//                 imageUrl: category.imageUrl ?? '',
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(
//                   color: const Color(0xFFFAF9F6),
//                   child: const Center(
//                     child: SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 1.5,
//                         color: Color(0xFFF37021),
//                       ),
//                     ),
//                   ),
//                 ),
//                 errorWidget: (context, url, error) =>
//                     const Icon(Icons.image, size: 20),
//               ),
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             category.name,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.poppins(
//               fontSize: 8,
//               fontWeight: FontWeight.w700,
//               color: const Color(0xFF444444),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iron_street_app/app/data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Gives the card a modern, slightly wider rectangular shape
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16), // Smooth, modern rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Very soft, modern shadow
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TOP: Image Area ---
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  color: const Color(
                      0xFFF9F9F9), // Light background for transparent images
                  child: CachedNetworkImage(
                    imageUrl: category.imageUrl ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF37021),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Icon(
                        Icons
                            .weekend_outlined, // Better fallback icon for furniture
                        size: 28,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- BOTTOM: Text Area ---
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                child: Center(
                  child: Text(
                    category.name,
                    maxLines: 1, // Allow 2 lines for longer category names
                    overflow: TextOverflow.clip,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(
                          0xFF222222), // Deep charcoal instead of harsh black
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
