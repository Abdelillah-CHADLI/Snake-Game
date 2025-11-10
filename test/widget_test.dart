// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:snake_game/main.dart';

void main() {
  testWidgets('Start button opens game and shows score', (WidgetTester tester) async {
    // Build the app.
    await tester.pumpWidget(const MyApp());

    // Verify start button is present.
    expect(find.text('Start'), findsOneWidget);

    // Tap the Start button and navigate to the game screen.
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // The game screen should show the score text with initial value 0.
    expect(find.textContaining('Score:'), findsOneWidget);
    expect(find.text('Score: 0'), findsOneWidget);
  });
}
