import 'package:flutter_test/flutter_test.dart';
import 'package:gym_frontend/main.dart';

void main() {
  testWidgets('Gym app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const GymApp());

    expect(find.text('Gym Management System'), findsOneWidget);
    expect(find.text('Welcome to PeakForge Gym'), findsOneWidget);
  });
}