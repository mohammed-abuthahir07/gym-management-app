import 'package:flutter/material.dart';

/// A selectable brand palette.
///
/// [primary] drives the energetic brand accents (buttons, highlights),
/// [secondary] drives the deep "premium" surfaces (rails, hero panels),
/// and [accent] is a complementary colour used for secondary data accents.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    this.accent = const Color(0xFF14B8A6),
  });

  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;

  /// Brand gradient used for hero panels, side navigation and headers.
  List<Color> get heroGradient => <Color>[
        secondary,
        Color.lerp(secondary, primary, 0.45) ?? primary,
      ];

  /// Vivid gradient used for primary call-to-action surfaces.
  List<Color> get actionGradient => <Color>[
        primary,
        Color.lerp(primary, accent, 0.55) ?? primary,
      ];
}

class AppPalettes {
  static const peakForge = AppPalette(
    id: 'peakforge',
    name: 'PeakForge Default',
    primary: Color(0xFFE4572E),
    secondary: Color(0xFF1B1F3B),
    accent: Color(0xFFF7B32B),
  );

  static const blue = AppPalette(
    id: 'blue',
    name: 'Blue',
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF0F172A),
    accent: Color(0xFF22D3EE),
  );

  static const green = AppPalette(
    id: 'green',
    name: 'Green',
    primary: Color(0xFF059669),
    secondary: Color(0xFF064E3B),
    accent: Color(0xFFA3E635),
  );

  static const purple = AppPalette(
    id: 'purple',
    name: 'Purple',
    primary: Color(0xFF7C3AED),
    secondary: Color(0xFF312E81),
    accent: Color(0xFFEC4899),
  );

  static const orange = AppPalette(
    id: 'orange',
    name: 'Orange',
    primary: Color(0xFFF97316),
    secondary: Color(0xFF7C2D12),
    accent: Color(0xFFFACC15),
  );

  static const red = AppPalette(
    id: 'red',
    name: 'Red',
    primary: Color(0xFFDC2626),
    secondary: Color(0xFF7F1D1D),
    accent: Color(0xFFFB923C),
  );

  // --- Newly Added Color Combinations ---

  static const teal = AppPalette(
    id: 'teal',
    name: 'Teal',
    primary: Color(0xFF0D9488),
    secondary: Color(0xFF134E4A),
    accent: Color(0xFF5EEAD4),
  );

  static const cyan = AppPalette(
    id: 'cyan',
    name: 'Cyan',
    primary: Color(0xFF0284C7),
    secondary: Color(0xFF082F49),
    accent: Color(0xFF38BDF8),
  );

  static const pink = AppPalette(
    id: 'pink',
    name: 'Pink',
    primary: Color(0xFFDB2777),
    secondary: Color(0xFF831843),
    accent: Color(0xFFFB7185),
  );

  static const indigo = AppPalette(
    id: 'indigo',
    name: 'Indigo',
    primary: Color(0xFF4F46E5),
    secondary: Color(0xFF311059),
    accent: Color(0xFF818CF8),
  );

  static const amber = AppPalette(
    id: 'amber',
    name: 'Amber',
    primary: Color(0xFFD97706),
    secondary: Color(0xFF78350F),
    accent: Color(0xFFFCD34D),
  );

  static const slate = AppPalette(
    id: 'slate',
    name: 'Slate Dark',
    primary: Color(0xFF64748B),
    secondary: Color(0xFF020617),
    accent: Color(0xFF94A3B8),
  );

  static const all = <AppPalette>[
    peakForge,
    blue,
    green,
    purple,
    orange,
    red,
    teal,
    cyan,
    pink,
    indigo,
    amber,
    slate,
  ];

  static AppPalette byId(String? id) {
    return all.firstWhere(
      (item) => item.id == id,
      orElse: () => peakForge,
    );
  }
}

/// Fixed semantic colours shared by every palette so that "success" always
/// reads as success regardless of the selected brand colour.
class AppSemanticColors {
  const AppSemanticColors._();

  static const successLight = Color(0xFF15803D);
  static const successDark = Color(0xFF4ADE80);

  static const warningLight = Color(0xFFB45309);
  static const warningDark = Color(0xFFFBBF24);

  static const dangerLight = Color(0xFFDC2626);
  static const dangerDark = Color(0xFFF87171);

  static const infoLight = Color(0xFF1D4ED8);
  static const infoDark = Color(0xFF60A5FA);
}

/// Neutral surface ramp. Light mode avoids pure white and dark mode avoids
/// pure black so cards read as distinct layers instead of a flat page.
class AppNeutrals {
  const AppNeutrals._();

  static const lightBackground = Color(0xFFF4F6FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceMuted = Color(0xFFEDF0F7);
  static const lightBorder = Color(0xFFE2E6F0);
  static const lightTextPrimary = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF5B6478);

  static const darkBackground = Color(0xFF0A0D16);
  static const darkSurface = Color(0xFF141A28);
  static const darkSurfaceMuted = Color(0xFF1C2333);
  static const darkBorder = Color(0xFF29324A);
  static const darkTextPrimary = Color(0xFFF3F5FA);
  static const darkTextSecondary = Color(0xFF9AA5BD);
}
