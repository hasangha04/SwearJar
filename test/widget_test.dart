import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swear_jar/yaml_reader.dart';
import 'package:swear_jar/models.dart';
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

  group('DaresYamlReader', () {
    testWidgets('Reading dares from YAML file', (WidgetTester tester) async {
      final daresYamlReader = DaresYamlReader();
      final daresList = await daresYamlReader.readDares('dares.yaml');

      expect(daresList, isNotEmpty);
      expect(daresList.length, greaterThan(0));
      expect(daresList[0], isInstanceOf<Dare>());
    });
  });

  group('ActsYamlReader', () {
    testWidgets('Reading acts of kindness from YAML file', (WidgetTester tester) async {
      final actsYamlReader = ActsYamlReader();
      final actsList = await actsYamlReader.readActs('AOK.yaml');

      expect(actsList, isNotEmpty);
      expect(actsList.length, greaterThan(0));
      expect(actsList[0], isInstanceOf<ActOfKindness>());
    });
  });
}
