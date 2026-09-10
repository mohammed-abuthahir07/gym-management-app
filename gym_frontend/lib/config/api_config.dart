import 'dart:io';

import 'package:flutter/foundation.dart';

/// Single source of truth for backend URLs.
///
/// Windows / iOS simulator / web local: http://localhost:5000
/// Android emulator: http://10.0.2.2:5000
/// Physical Android device: set [physicalDeviceUrl] to your PC LAN IP.
class ApiConfig {
  static const String windowsUrl = 'http://localhost:5000';
  static const String androidEmulatorUrl = 'http://10.0.2.2:5000';

  /// Example: http://192.168.1.10:5000
  static const String physicalDeviceUrl = 'http://192.168.1.10:5000';

  /// Set true only when running on a physical Android phone.
  static const bool usePhysicalDeviceUrl = false;

  static const String productionUrl = 'https://api.peakforge.example.com';
  static const bool useProduction = false;

  static String get baseUrl {
    if (useProduction) return productionUrl;
    if (kIsWeb) return windowsUrl;
    if (!kIsWeb && Platform.isAndroid) {
      return usePhysicalDeviceUrl ? physicalDeviceUrl : androidEmulatorUrl;
    }
    return windowsUrl;
  }

  static String fileUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final value = path.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) return '$baseUrl$value';
    return '$baseUrl/$value';
  }
}
