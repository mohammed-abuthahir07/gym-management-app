import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light(AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      secondary: palette.secondary,
      brightness: Brightness.light,
    );
    return _build(scheme, palette);
  }

  static ThemeData dark(AppPalette palette) {
    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      secondary: palette.secondary,
      brightness: Brightness.dark,
    );
    return _build(scheme, palette);
  }

  static ThemeData _build(ColorScheme scheme, AppPalette palette) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        selectedIconTheme: IconThemeData(color: palette.primary),
        selectedLabelTextStyle: TextStyle(
          color: palette.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.secondary,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
