import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class CropDocThemeExtension extends ThemeExtension<CropDocThemeExtension> {
  const CropDocThemeExtension({
    required this.confidentColor,
    required this.confidentBg,
    required this.uncertainColor,
    required this.uncertainBg,
    required this.unknownColor,
    required this.unknownBg,
    required this.cardBorder,
    required this.scanLineColor,
    required this.accentLime,
  });

  final Color confidentColor;
  final Color confidentBg;
  final Color uncertainColor;
  final Color uncertainBg;
  final Color unknownColor;
  final Color unknownBg;
  final Color cardBorder;
  final Color scanLineColor;
  final Color accentLime;

  static const light = CropDocThemeExtension(
    confidentColor: AppColors.statusConfident,
    confidentBg: AppColors.statusConfidentBg,
    uncertainColor: AppColors.statusUncertain,
    uncertainBg: AppColors.statusUncertainBg,
    unknownColor: AppColors.statusUnknown,
    unknownBg: AppColors.statusUnknownBg,
    cardBorder: AppColors.borderLight,
    scanLineColor: AppColors.accentLime,
    accentLime: AppColors.accentLime,
  );

  static const dark = CropDocThemeExtension(
    confidentColor: AppColors.accentLime,
    confidentBg: AppColors.statusConfidentBgDark,
    uncertainColor: Color(0xFFFBBF24),
    uncertainBg: AppColors.statusUncertainBgDark,
    unknownColor: Color(0xFFF87171),
    unknownBg: AppColors.statusUnknownBgDark,
    cardBorder: AppColors.borderDark,
    scanLineColor: AppColors.accentLime,
    accentLime: AppColors.accentLime,
  );

  @override
  CropDocThemeExtension copyWith({
    Color? confidentColor,
    Color? confidentBg,
    Color? uncertainColor,
    Color? uncertainBg,
    Color? unknownColor,
    Color? unknownBg,
    Color? cardBorder,
    Color? scanLineColor,
    Color? accentLime,
  }) {
    return CropDocThemeExtension(
      confidentColor: confidentColor ?? this.confidentColor,
      confidentBg: confidentBg ?? this.confidentBg,
      uncertainColor: uncertainColor ?? this.uncertainColor,
      uncertainBg: uncertainBg ?? this.uncertainBg,
      unknownColor: unknownColor ?? this.unknownColor,
      unknownBg: unknownBg ?? this.unknownBg,
      cardBorder: cardBorder ?? this.cardBorder,
      scanLineColor: scanLineColor ?? this.scanLineColor,
      accentLime: accentLime ?? this.accentLime,
    );
  }

  @override
  CropDocThemeExtension lerp(ThemeExtension<CropDocThemeExtension>? other, double t) {
    if (other is! CropDocThemeExtension) return this;
    return CropDocThemeExtension(
      confidentColor: Color.lerp(confidentColor, other.confidentColor, t)!,
      confidentBg: Color.lerp(confidentBg, other.confidentBg, t)!,
      uncertainColor: Color.lerp(uncertainColor, other.uncertainColor, t)!,
      uncertainBg: Color.lerp(uncertainBg, other.uncertainBg, t)!,
      unknownColor: Color.lerp(unknownColor, other.unknownColor, t)!,
      unknownBg: Color.lerp(unknownBg, other.unknownBg, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      scanLineColor: Color.lerp(scanLineColor, other.scanLineColor, t)!,
      accentLime: Color.lerp(accentLime, other.accentLime, t)!,
    );
  }
}
