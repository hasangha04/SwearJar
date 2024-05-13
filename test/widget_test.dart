import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swear_jar/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that our counter starts at 0.
    expect(find.text('Swears in Jar: 0'), findsOneWidget);
    expect(find.text('Swears in Jar: 1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('Swears in Jar: 0'), findsNothing);
    expect(find.text('Swears in Jar: 1'), findsOneWidget);
  });
}