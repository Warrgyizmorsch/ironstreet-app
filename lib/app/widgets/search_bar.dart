/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String value;
  final String placeholder;

  const CustomSearchBar({
    Key? key,
    required this.onChanged,
    required this.value,
    this.placeholder = 'Search sofas, beds, decor items...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF222222),
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (value.isNotEmpty)
            GestureDetector(
              onTap: () {
                onChanged('');
              },
              child: const Icon(Icons.close, color: Colors.grey, size: 18),
            ),
        ],
      ),
    );
  }
}
