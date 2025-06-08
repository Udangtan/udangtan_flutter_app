import 'package:flutter/material.dart';

class AppColors {
  // Primary colors - 더 모던한 보라색 톤
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFF9E4BDE);
  static const Color primaryDark = Color(0xFF5B4EC7);
  static Color primaryWithOpacity10 = primary.withValues(alpha: 0.1);
  static Color primaryWithOpacity30 = primary.withValues(alpha: 0.3);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  // App Bar colors
  static const Color appBarBackground = Colors.white;
  static const Color appBarTitle = Color(0xFF2D3436);
  static const Color appBarIcon = Color(0xFF636E72);

  // Bottom Navigation colors
  static const Color bottomNavBackground = Colors.white;
  static const Color bottomNavSelected = primary;
  static const Color bottomNavUnselected = Color(0xFFB2BEC3);

  // Background colors
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color containerBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color inputBackground = Colors.white;

  // Border and divider colors
  static const Color borderLight = Color(0xFFE1E5E9);
  static const Color borderDark = Color(0xFFCED6E0);
  static const Color divider = Color(0xFFF0F0F0);

  // Text colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textHint = Color(0xFFDDD6FE);
  static const Color textWhite = Colors.white;

  // Button colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = Color(0xFFE17055);
  static const Color buttonDisabled = Color(0xFFDDD6FE);
  static const Color buttonText = Colors.white;

  // Status colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDBB2D);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF0984E3);

  // Pet type colors
  static const Color dogColor = Color(0xFFE17055);
  static const Color catColor = Color(0xFF00B894);

  // Gender colors
  static const Color maleColor = Color(0xFF0984E3);
  static const Color femaleColor = Color(0xFFE84393);

  // Shadow colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.1);
  static Color shadowDark = Colors.black.withValues(alpha: 0.15);

  // Chat colors
  static const Color chatBubbleOwn = primary;
  static const Color chatBubbleOther = Color(0xFFF1F3F4);
  static const Color chatTextOwn = Colors.white;
  static const Color chatTextOther = textPrimary;

  // Additional UI colors
  static const Color surface = Colors.white;
  static const Color onSurface = textPrimary;
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color onSurfaceVariant = textSecondary;

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
