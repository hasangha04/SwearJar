import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:swear_jar/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class MockFirebasePlatform extends Mock implements FirebasePlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    FirebasePlatform.instance = MockFirebasePlatform();
    await Firebase.initializeApp();
  });

  testWidgets('MyJarPage displays initial data', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Push button to add money to the swear jar'), findsOneWidget);
    expect(find.text('Money in Jar: \$0.00'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Increment counter and update money in jar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Money in Jar: \$0.00'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text('Money in Jar: \$0.01'), findsOneWidget);
  });

  testWidgets('BottomNavBar navigation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Dares'));
    await tester.pumpAndSettle();

    expect(find.text('Dares Page'), findsOneWidget);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();

    expect(find.text('Stats Page'), findsOneWidget);

    await tester.tap(find.text('Acts of Kindness'));
    await tester.pumpAndSettle();

    expect(find.text('Acts of Kindness Page'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('Push button to add money to the swear jar'), findsOneWidget);
  });
}
