import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Extra PeakForge colours stored on [ThemeData] so screens can stay
/// theme-aware without hard-coding brand or semantic colours.
class PeakForgeColors extends ThemeExtension<PeakForgeColors> {
  const PeakForgeColors({
    required this.accent,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.surfaceMuted,
    required this.border,
    required this.textSecondary,
    required this.heroStart,
    required this.heroEnd,
  });

  final Color accent;
  final Color success;
  final Color warning;
  final Color info;
  final Color danger;
  final Color surfaceMuted;
  final Color border;
  final Color textSecondary;
  final Color heroStart;
  final Color heroEnd;

  factory PeakForgeColors.fromPalette(AppPalette palette, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return PeakForgeColors(
      accent: palette.accent,
      success: dark ? AppSemanticColors.successDark : AppSemanticColors.successLight,
      warning: dark ? AppSemanticColors.warningDark : AppSemanticColors.warningLight,
      info: dark ? AppSemanticColors.infoDark : AppSemanticColors.infoLight,
      danger: dark ? AppSemanticColors.dangerDark : AppSemanticColors.dangerLight,
      surfaceMuted: dark ? AppNeutrals.darkSurfaceMuted : AppNeutrals.lightSurfaceMuted,
      border: dark ? AppNeutrals.darkBorder : AppNeutrals.lightBorder,
      textSecondary: dark ? AppNeutrals.darkTextSecondary : AppNeutrals.lightTextSecondary,
      heroStart: palette.secondary,
      heroEnd: Color.lerp(palette.secondary, palette.primary, 0.42) ?? palette.primary,
    );
  }

  List<Color> get heroGradient => <Color>[heroStart, heroEnd];

  /// Distinct accent colours for dashboard statistic cards.
  List<Color> get statAccents => <Color>[
        heroEnd,
        accent,
        success,
        info,
        warning,
        danger,
      ];

  Color statAccent(int index) => statAccents[index % statAccents.length];

  @override
  PeakForgeColors copyWith({
    Color? accent,
    Color? success,
    Color? warning,
    Color? info,
    Color? danger,
    Color? surfaceMuted,
    Color? border,
    Color? textSecondary,
    Color? heroStart,
    Color? heroEnd,
  }) {
    return PeakForgeColors(
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      textSecondary: textSecondary ?? this.textSecondary,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
    );
  }

  @override
  PeakForgeColors lerp(ThemeExtension<PeakForgeColors>? other, double t) {
    if (other is! PeakForgeColors) return this;
    return PeakForgeColors(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      heroStart: Color.lerp(heroStart, other.heroStart, t) ?? heroStart,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t) ?? heroEnd,
    );
  }
}

extension PeakForgeThemeX on BuildContext {
  PeakForgeColors get pf {
    return Theme.of(this).extension<PeakForgeColors>() ??
        PeakForgeColors.fromPalette(AppPalettes.peakForge, Theme.of(this).brightness);
  }
}
