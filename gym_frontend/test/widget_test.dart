import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_frontend/screens/public/home_page.dart';

void main() {
  testWidgets('PeakForge Gym home page loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomePage(),
        ),
      ),
    );

    expect(find.text('Welcome to PeakForge Gym'), findsOneWidget);
    expect(find.text('Why Choose PeakForge'), findsOneWidget);
  });
}