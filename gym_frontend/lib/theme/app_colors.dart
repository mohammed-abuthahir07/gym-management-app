import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
  });

  final String id;
  final String name;
  final Color primary;
  final Color secondary;
}

class AppPalettes {
  static const peakForge = AppPalette(
    id: 'peakforge',
    name: 'PeakForge Default',
    primary: Color(0xFFE4572E),
    secondary: Color(0xFF1B1F3B),
  );

  static const blue = AppPalette(
    id: 'blue',
    name: 'Blue',
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF0F172A),
  );

  static const green = AppPalette(
    id: 'green',
    name: 'Green',
    primary: Color(0xFF059669),
    secondary: Color(0xFF064E3B),
  );

  static const purple = AppPalette(
    id: 'purple',
    name: 'Purple',
    primary: Color(0xFF7C3AED),
    secondary: Color(0xFF312E81),
  );

  static const orange = AppPalette(
    id: 'orange',
    name: 'Orange',
    primary: Color(0xFFF97316),
    secondary: Color(0xFF7C2D12),
  );

  static const red = AppPalette(
    id: 'red',
    name: 'Red',
    primary: Color(0xFFDC2626),
    secondary: Color(0xFF7F1D1D),
  );

  static const all = <AppPalette>[
    peakForge,
    blue,
    green,
    purple,
    orange,
    red,
  ];

  static AppPalette byId(String? id) {
    return all.firstWhere(
      (item) => item.id == id,
      orElse: () => peakForge,
    );
  }
}
