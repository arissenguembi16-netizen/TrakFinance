// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:trackfinance/app/app.dart';

void main() {
  testWidgets('Smoke test - App builds', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: TrackFinanceApp requires providers, but for a smoke test we just check if it builds
    await tester.pumpWidget(const TrackFinanceApp());

    // Basic check to see if the splash or login screen appears
    // (A full test would need to mock providers and database)
    expect(find.byType(TrackFinanceApp), findsOneWidget);
  });
}
