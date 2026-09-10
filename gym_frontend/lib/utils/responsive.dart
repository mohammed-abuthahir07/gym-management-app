import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 800;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1100;

  static int gridCount(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1100) return desktop;
    if (width >= 800) return tablet;
    return mobile;
  }

  static double pagePadding(BuildContext context) =>
      isMobile(context) ? 16 : 28;
}
