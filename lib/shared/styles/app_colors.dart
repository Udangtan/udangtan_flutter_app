import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Colors.purple;
  static Color primaryLight = Colors.purple.shade100;
  static Color primaryDark = Colors.purple.shade600;
  static Color primaryWithOpacity10 = Colors.purple.withValues(alpha: 0.1);
  static Color primaryWithOpacity30 = Colors.purple.withValues(alpha: 0.3);

  // App Bar colors
  static const Color appBarBackground = Colors.white;
  static const Color appBarTitle = Colors.black;
  static const Color appBarIcon = Colors.black;

  // Bottom Navigation colors
  static const Color bottomNavBackground = Colors.white;
  static const Color bottomNavSelected = Colors.purple;
  static const Color bottomNavUnselected = Colors.grey;

  // Background colors
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color containerBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Colors.white;

  // Border and divider colors
  static Color borderLight = Colors.grey.shade300;
  static Color borderDark = Colors.grey.shade400;
  static const Color divider = Color(0xFFF0F0F0);

  // Text colors
  static const Color textPrimary = Colors.black;
  static Color textSecondary = Colors.grey.shade600;
  static const Color textTertiary = Colors.grey;
  static const Color textHint = Colors.grey;
  static const Color textWhite = Colors.white;

  // Button colors
  static const Color buttonPrimary = Colors.purple;
  static const Color buttonSecondary = Color(0xFFE57373);
  static const Color buttonDisabled = Colors.grey;
  static const Color buttonText = Colors.white;

  // Pet type colors
  static const Color dogColor = Colors.orange;
  static const Color catColor = Colors.green;

  // Gender colors
  static const Color maleColor = Colors.blue;
  static const Color femaleColor = Colors.pink;

  // Shadow colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.1);

  // Status colors
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;

  // Swipe indicator colors (for pet cards)
  static Color rejectGradientStart = Colors.red.shade400;
  static Color rejectGradientEnd = Colors.red.shade600;
  static Color approveGradientStart = Colors.green.shade400;
  static Color approveGradientEnd = Colors.green.shade600;

  // Tag colors
  static Color tagBackground = Colors.grey.shade200;
  static Color tagBackgroundSelected = primaryWithOpacity10;
  static Color tagBorder = borderLight;
  static Color tagBorderSelected = primaryWithOpacity30;

  // Common colors
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
