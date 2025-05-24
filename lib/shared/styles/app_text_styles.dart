import 'package:flutter/material.dart';
import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';

class AppTextStyles {
  // App Bar
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.appBarTitle,
  );

  // Pet Card
  static const TextStyle cardTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 18,
    color: AppColors.textWhite,
  );

  static const TextStyle cardDistance = TextStyle(
    fontSize: 14,
    color: AppColors.textWhite,
  );

  static const TextStyle cardDescription = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static const TextStyle petName = TextStyle(
    color: AppColors.textWhite,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle petInfo = TextStyle(
    color: AppColors.textWhite,
    fontSize: 14,
  );

  static const TextStyle description = TextStyle(fontSize: 15);

  static const TextStyle tagText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Buttons
  static const TextStyle buttonText = TextStyle(fontWeight: FontWeight.bold);

  // Swipe Indicators
  static const TextStyle swipeIndicator = TextStyle(
    color: AppColors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  // Navigation
  static const TextStyle navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
