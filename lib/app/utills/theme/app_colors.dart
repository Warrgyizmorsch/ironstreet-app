import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 240, 59, 59);
  static Color get background => Get.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF6F6F6);
  static const Color priceC = Color(0xFF16A34A);
  static const Color dishpriceC = Color(0xFFDC2626);
  static const Color addCart = Color(0xFFEA580C);
  static Color get blackC => Get.isDarkMode ? Colors.white : Colors.black;
}
