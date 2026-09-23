import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';

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

    testWidgets('Renders RecipeWidget with ingredients and instructions', (WidgetTester tester) async {
      final recipeNode = JsonLdNode.fromJson({
        "@type": "schema:Recipe",
        "schema:name": "Gourmet Pasta",
        "schema:prepTime": "PT10M",
        "schema:recipeIngredient": ["Spaghetti", "Parmesan"]
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecipeWidget(
              node: recipeNode,
              isEditable: false,
              activeLanguage: 'en',
            ),
          ),
        ),
      );

      expect(find.text('Gourmet Pasta'), findsOneWidget);
      expect(find.text('Prep: PT10M'), findsOneWidget);
    });

    testWidgets('Renders PlaceWidget with address', (WidgetTester tester) async {
      final placeNode = JsonLdNode.fromJson({
        "@type": "schema:Place",
        "schema:name": "Central Park",
        "schema:address": "New York, NY"
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlaceWidget(
              node: placeNode,
              isEditable: false,
              activeLanguage: 'en',
            ),
          ),
        ),
      );

      expect(find.text('Central Park'), findsOneWidget);
      expect(find.text('New York, NY'), findsOneWidget);
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
