import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swear_jar/main.dart';

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
      
      expect(find.text('Money in Jar: \$0.00'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('Money in Jar: \$0.01'), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      
      expect(find.text('Money in Jar: \$0.00'), findsOneWidget);
    });

    testWidgets('MyJarPage resets counter', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Reset All'));
      await tester.pumpAndSettle();

      expect(find.text('Money in Jar: \$0.00'), findsOneWidget);
    });

    testWidgets('Navigation to DaresPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Dares'));
      await tester.pumpAndSettle();
      
      expect(find.text('Dares Page'), findsOneWidget);
    });

    testWidgets('Navigation to StatsPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();

      expect(find.text('Stats Page'), findsOneWidget);
    });

    testWidgets('Navigation to ActsOfKindnessPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Acts of Kindness'));
      await tester.pumpAndSettle();
      
      expect(find.text('Acts of Kindness Page'), findsOneWidget);
    });

    testWidgets('Shows set name dialog on Join Game button tap', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Join Game'));
      await tester.pumpAndSettle();
      
      expect(find.text('Set Display Name'), findsOneWidget);
    });

    testWidgets('Shows join game dialog after setting name', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Join Game'));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'TestUser');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      expect(find.text('Join Game'), findsOneWidget);
    });

    testWidgets('Add Dare through AddDarePage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Dares'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Test Dare');
      await tester.enterText(find.byType(TextField).last, '2');
      await tester.tap(find.text('Add Dare'));
      await tester.pumpAndSettle();
      
      expect(find.text('Test Dare'), findsOneWidget);
    });

    testWidgets('Add Act through AddActPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Acts of Kindness'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).first, 'Test Act');
      await tester.enterText(find.byType(TextField).last, '3');
      await tester.tap(find.text('Add Act'));
      await tester.pumpAndSettle();
      
      expect(find.text('Test Act'), findsOneWidget);
    });

    testWidgets('Display stats on StatsPage', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      
      expect(find.text('Total Swears: 10'), findsOneWidget);
      expect(find.text('Total Money: \$1.00'), findsOneWidget);
    });

    testWidgets('DaresPage loads dares', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Dares'));
      await tester.pumpAndSettle();
      
      expect(find.text('Severity: 2'), findsWidgets);
    });

    testWidgets('ActsOfKindnessPage loads acts', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Acts of Kindness'));
      await tester.pumpAndSettle();
      
      expect(find.text('Severity: 3'), findsWidgets);
    });

    testWidgets('MyJarPage displays game ID', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();
      
      expect(find.text('Game ID: testGameId'), findsOneWidget);
    });

    testWidgets('Decrement button shows Remove Swear dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();
      
      expect(find.text('Remove Swear'), findsOneWidget);
    });

    testWidgets('Reset button in Remove Swear dialog works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MyJarPage(title: 'Swear Jar')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset All'));
      await tester.pumpAndSettle();
      
      expect(find.text('Money in Jar: \$0.00'), findsOneWidget);
    });
  });
}
