import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/src/models/json_ld_node.dart';
import 'package:app/src/widgets/complex_event_widget.dart';
import 'package:app/src/widgets/widget_registry.dart';
import 'package:app/src/widgets/datatype_renderers.dart';

void main() {
  group('JSON-LD Widget Tests', () {
    testWidgets('Renders ComplexEventWidget in read-only and editable mode', (WidgetTester tester) async {
      final eventNode = JsonLdNode.fromJson({
        "@id": "https://example.com/event/101",
        "@type": "schema:Event",
        "schema:name": [
          {"@value": "Tech Summit 2026", "@language": "en"},
          {"@value": "Cumbre de Tecnología 2026", "@language": "es"}
        ],
        "schema:description": "Annual technology conference",
        "schema:startDate": "2026-11-01"
      });

      // 1. Test Read-Only rendering
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComplexEventWidget(
              node: eventNode,
              isEditable: false,
              activeLanguage: 'en',
            ),
          ),
        ),
      );

      expect(find.text('Tech Summit 2026'), findsOneWidget);
      expect(find.text('Annual technology conference'), findsOneWidget);

      // 2. Test Editable mode rendering
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComplexEventWidget(
              node: eventNode,
              isEditable: true,
              activeLanguage: 'en',
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
    });

    testWidgets('WidgetRegistry correctly looks up registered type builders', (WidgetTester tester) async {
      final registry = JsonLdWidgetRegistry();
      registry.register('schema:Article', (context, node,
          {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
        return const Text('Article Custom Builder Widget');
      });

      final articleNode = JsonLdNode.fromJson({
        "@type": "schema:Article",
        "schema:headline": "Flutter JSON-LD Integration"
      });

      final builder = registry.lookup(articleNode.types);
      expect(builder, isNotNull);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: builder!(
              tester.element(find.byType(Scaffold)),
              articleNode,
              isEditable: false,
              activeLanguage: 'en',
            ),
          ),
        ),
      );

      expect(find.text('Article Custom Builder Widget'), findsOneWidget);
    });
  });
}
