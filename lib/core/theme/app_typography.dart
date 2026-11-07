import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme createTextTheme(BuildContext context, {required bool isDark}) {
    final locale = Localizations.maybeLocaleOf(context);
    final isBangla = locale?.languageCode == 'bn';

    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    // Apply primary font based on active locale
    final fontFunction = isBangla
        ? GoogleFonts.notoSansBengaliTextTheme
        : GoogleFonts.plusJakartaSansTextTheme;

    final theme = fontFunction(baseTextTheme);

    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: theme.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineLarge: theme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      headlineMedium: theme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: theme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: theme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleMedium: theme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleSmall: theme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: theme.bodyLarge?.copyWith(
        height: 1.45,
      ),
      bodyMedium: theme.bodyMedium?.copyWith(
        height: 1.45,
      ),
      labelLarge: theme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }
}
