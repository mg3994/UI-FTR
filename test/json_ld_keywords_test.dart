import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';

void main() {
  group('JSON-LD Keywords & Semantics Tests', () {
    testWidgets('Renders KeywordMatrixWidget and selects keyword specs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KeywordMatrixWidget(),
          ),
        ),
      );

      expect(find.text('@context'), findsAtLeastNWidgets(1));
      expect(find.text('@id'), findsAtLeastNWidgets(1));
      expect(find.text('@type'), findsAtLeastNWidgets(1));
      expect(find.text('@language'), findsAtLeastNWidgets(1));

      // Tap on @language keyword in list
      await tester.tap(find.text('@language').first);
      await tester.pumpAndSettle();

      expect(find.text('@language (BCP-47 Language Tag)'), findsOneWidget);
    });
  });
}
