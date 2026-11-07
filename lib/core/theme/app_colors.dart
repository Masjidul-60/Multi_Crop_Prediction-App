import 'package:flutter/material.dart';

/// Semantic brand colors and status palettes for CropDoc.
class AppColors {
  AppColors._();

  // Primary brand palette
  static const Color primaryGreen = Color(0xFF1F6F43);
  static const Color primaryGreenDark = Color(0xFF165030);
  static const Color primaryGreenLight = Color(0xFF2E8F59);
  
  // Fresh lime accents
  static const Color accentLime = Color(0xFFA8D672);
  static const Color accentLimeLight = Color(0xFFC7EBB4);
  static const Color accentLimeDark = Color(0xFF86B550);

  // Backgrounds & Surfaces (Warm off-white & Rich dark)
  static const Color warmOffWhite = Color(0xFFF7F6F1);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEBE9E1);
  
  static const Color bgDark = Color(0xFF121614);
  static const Color surfaceDark = Color(0xFF1A211D);
  static const Color surfaceVariantDark = Color(0xFF242C27);

  // Charcoal & Muted text
  static const Color textPrimaryLight = Color(0xFF1C1E1B);
  static const Color textSecondaryLight = Color(0xFF555B53);
  static const Color textDisabledLight = Color(0xFF9EA39B);

  static const Color textPrimaryDark = Color(0xFFF3F5F2);
  static const Color textSecondaryDark = Color(0xFFA6ACA3);
  static const Color textDisabledDark = Color(0xFF6B7268);

  // Status Colors (Confident, Uncertain, Unknown/Alert)
  static const Color statusConfident = Color(0xFF1F6F43);
  static const Color statusConfidentBg = Color(0xFFE7F3EC);
  static const Color statusConfidentBgDark = Color(0xFF173825);

  static const Color statusUncertain = Color(0xFFD97706);
  static const Color statusUncertainBg = Color(0xFFFEF3C7);
  static const Color statusUncertainBgDark = Color(0xFF38270A);

  static const Color statusUnknown = Color(0xFFDC2626);
  static const Color statusUnknownBg = Color(0xFFFEE2E2);
  static const Color statusUnknownBgDark = Color(0xFF3A1515);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E0D8);
  static const Color borderDark = Color(0xFF2C352F);
}
