import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swear_jar/main.dart'; // Adjust the import based on the actual path of your main.dart file

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Widget Tests', () {
    testWidgets('MyApp initializes and displays MyJarPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Swear Jar'), findsOneWidget);
    });

    testWidgets('MyJarPage increments and decrements counter', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();

      // Verify initial counter value
      expect(find.text('Money in Jar: \$0.00'), findsOneWidget);

      // Tap the increment button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Verify incremented counter value
      expect(find.text('Money in Jar: \$0.01'), findsOneWidget);

      // Tap the decrement button
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Verify decremented counter value
      expect(find.text('Money in Jar: \$0.00'), findsOneWidget);
    });

    testWidgets('Navigation to DaresPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap the bottom navigation bar item for Dares
      await tester.tap(find.text('Dares'));
      await tester.pumpAndSettle();

      // Verify we are on the DaresPage
      expect(find.text('Dares Page'), findsOneWidget);
    });

    testWidgets('Navigation to StatsPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap the bottom navigation bar item for Stats
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();

      // Verify we are on the StatsPage
      expect(find.text('Stats Page'), findsOneWidget);
    });

    testWidgets('Navigation to ActsOfKindnessPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap the bottom navigation bar item for Acts of Kindness
      await tester.tap(find.text('Acts of Kindness'));
      await tester.pumpAndSettle();

      // Verify we are on the ActsOfKindnessPage
      expect(find.text('Acts of Kindness Page'), findsOneWidget);
    });

    testWidgets('Shows set name dialog on Join Game button tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();

      // Tap the Join Game button
      await tester.tap(find.text('Join Game'));
      await tester.pumpAndSettle();

      // Verify the dialog is shown
      expect(find.text('Set Display Name'), findsOneWidget);
    });

    testWidgets('Shows join game dialog after setting name', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();

      // Tap the Join Game button
      await tester.tap(find.text('Join Game'));
      await tester.pumpAndSettle();

      // Enter a display name and save
      await tester.enterText(find.byType(TextField).first, 'TestUser');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify the join game dialog is shown
      expect(find.text('Join Game'), findsOneWidget);
    });
  });
}
