import 'package:flutter/material.dart';

import 'package:udangtan_flutter_app/shared/styles/app_colors.dart';

class AppStyles {
  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardDecorationWithBorder({
    Color? borderColor,
    double borderWidth = 1,
  }) => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: borderColor ?? AppColors.borderLight,
      width: borderWidth,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonPrimary,
    foregroundColor: AppColors.buttonText,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.buttonSecondary,
    foregroundColor: AppColors.buttonText,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 0,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    fillColor: AppColors.inputBackground,
    filled: true,
  );

  // Avatar Decoration
  static BoxDecoration circleAvatarDecoration(Color color) =>
      BoxDecoration(color: color, shape: BoxShape.circle);

  // Selection Card Style (for pet registration)
  static BoxDecoration selectionCardDecoration({
    required bool isSelected,
    Color? selectedBorderColor,
  }) => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color:
          isSelected
              ? (selectedBorderColor ?? AppColors.primary)
              : AppColors.borderLight,
      width: isSelected ? 2 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Tag/Chip Decoration
  static BoxDecoration tagDecoration({required bool isSelected}) =>
      BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.tagBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.tagBorder,
        ),
      );

  // Common Paddings
  static const EdgeInsets paddingAll20 = EdgeInsets.all(20);
  static const EdgeInsets paddingHorizontal20 = EdgeInsets.symmetric(
    horizontal: 20,
  );
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(
    vertical: 16,
  );
  static const EdgeInsets paddingSymmetric16_8 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  // Common Margins
  static const EdgeInsets marginAll20 = EdgeInsets.all(20);
  static const EdgeInsets marginHorizontal20 = EdgeInsets.symmetric(
    horizontal: 20,
  );
  static const EdgeInsets marginVertical8 = EdgeInsets.symmetric(vertical: 8);

  // Common Border Radius
  static BorderRadius get borderRadius12 => BorderRadius.circular(12);
  static BorderRadius get borderRadius8 => BorderRadius.circular(8);
  static BorderRadius get borderRadius20 => BorderRadius.circular(20);
}
