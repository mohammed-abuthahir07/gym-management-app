import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'app_colors.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;
  AppPalette palette = AppPalettes.peakForge;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeValue = prefs.getString(AppConstants.themeModeKey);
    final paletteId = prefs.getString(AppConstants.themePaletteKey);
    mode = switch (modeValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    palette = AppPalettes.byId(paletteId);
    notifyListeners();
  }

  Future<void> setMode(ThemeMode next) async {
    mode = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.themeModeKey,
      switch (next) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }

  Future<void> setPalette(AppPalette next) async {
    palette = next;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themePaletteKey, next.id);
  }
}
