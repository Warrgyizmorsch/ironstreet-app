/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  // Navigation State
  var currentIndex = 0.obs;

  // Selected subcategory for filtering (All, Living, Bedroom, Dining)
  var selectedSubCategory = 'All'.obs;

  // Search filter query
  var searchQuery = ''.obs;

  // Scaffold key for drawer
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Timer Countdown state (simulating real-time lightning deal)
  var minutes = 14.obs;
  var seconds = 59.obs;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        if (minutes.value > 0) {
          minutes.value--;
          seconds.value = 59;
        } else {
          // Restart timer loop for mock realism
          minutes.value = 15;
          seconds.value = 0;
        }
      }
      _startTimer();
    });
  }

  void onTabChanged(int index) {
    currentIndex.value = index;
    // Clear search when manually routing via bottom nav
    searchQuery.value = '';
  }

  void selectSubCategory(String category) {
    selectedSubCategory.value = category;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }
}
