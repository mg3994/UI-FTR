import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/src/models/json_ld_node.dart';
import 'package:app/src/widgets/complex_event_widget.dart';
import 'package:app/src/widgets/person_widget.dart';
import 'package:app/src/widgets/product_widget.dart';
import 'package:app/src/widgets/widget_registry.dart';

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
    });

    testWidgets('Renders ProductWidget with brand and offer details', (WidgetTester tester) async {
      final productNode = JsonLdNode.fromJson({
        "@type": "schema:Product",
        "schema:name": "Developer Laptop Pro",
        "schema:brand": "TechCorp",
        "schema:description": "High performance workstation",
        "schema:offers": {
          "@type": "schema:Offer",
          "schema:price": 1999.99
        }
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductWidget(
              node: productNode,
              isEditable: false,
              activeLanguage: 'en',
            ),
          ),
        ),
      );

      expect(find.text('Developer Laptop Pro'), findsOneWidget);
      expect(find.text('TechCorp'), findsOneWidget);
    });

    testWidgets('Renders PersonWidget with jobTitle and worksFor', (WidgetTester tester) async {
      final personNode = JsonLdNode.fromJson({
        "@type": "schema:Person",
        "schema:name": "Jules Architect",
        "schema:jobTitle": "Lead UI Architect",
        "schema:worksFor": "Global Tech"
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PersonWidget(
              node: personNode,
              isEditable: false,
              activeLanguage: 'en',
            ),
          ),
        ),
      );

      expect(find.text('Jules Architect'), findsOneWidget);
      expect(find.text('Lead UI Architect'), findsOneWidget);
      expect(find.text('Works at: Global Tech'), findsOneWidget);
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
            body: Builder(
              builder: (context) {
                return builder!(
                  context,
                  articleNode,
                  isEditable: false,
                  activeLanguage: 'en',
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Article Custom Builder Widget'), findsOneWidget);
    });
  });
}
