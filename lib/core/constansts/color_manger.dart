import 'package:flutter/material.dart';

/// Centralized color palette for the app.
/// Defines both light and dark theme colors.
class ColorManager {
  ColorManager._();

  // ===== Primary Colors =====
  static const Color primary = Color(0xFF00136B);
  static const Color primaryLight = Color(0xFF334289);
  static const Color primaryDark = Color(0xFF000C48);

  // ===== Background Colors =====
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color scaffoldLight = Color(0xFFFFFFFF);
  static const Color scaffoldDark = Color(0xFF1E1E1E);

  // ===== Text Colors =====
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color titleText = Color(0xFF2F3131);
  static const Color titleText1 = Color(0xFF535353);
  static const Color subtitleText = Color(0xFF686868);
  static const Color subtitleText1 = Color(0xFF60655C);
  static const Color mediumText = Color(0xFF363A33);

  // ===== Button & Label Colors =====
  static const Color buttonText = Color(0xFF334289);
  static const Color hintText = Color(0xFF5B5F5F);

  // ===== Neutral Colors =====
  static const Color blackColor = Color(0xFF000000);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color transparentColor = Colors.transparent;

  // ===== Border Colors =====
  static const Color borderColor = Color(0xFFDADADA);
  static const Color borderColor1 = Color(0xFF00136B);

  // ===== Container & Fill Colors =====
  static const Color containerColor = Color(0xFFEFEFEF);
  static const Color containerColor1 = Color(0xFFD9DDE2);
  static const Color fillColor = Color(0xFFFEF5F3);

  // ===== Feedback Colors =====
  static const Color errorColor = Color(0xFFE25839);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color infoColor = Color(0xFF1976D2);

  // ===== Utility Colors =====
  static const Color shadowColor = Color(0x1A000000); // 10% opacity black
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color overlayColor = Color(0x33000000); // 20% opacity black
}
