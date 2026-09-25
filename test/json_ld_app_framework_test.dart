import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';

void main() {
  group('Declarative JSON-LD Framework & Plugin Tests', () {
    testWidgets('JsonLdApp injects JsonLdScope into widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(
        JsonLdApp(
          initialDocument: const {
            "@context": "https://schema.org",
            "@type": "Event",
            "name": "Framework Test Event"
          },
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final scope = JsonLdScope.of(context);
                  final storeNode = scope?.store.value.rootNode;
                  return Text('Loaded: ${storeNode?.properties['name']}');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loaded: Framework Test Event'), findsOneWidget);
    });

    test('SchemaOrgCorePlugin auto-registers core schema types in widget registry', () {
      final widgetRegistry = JsonLdWidgetRegistry();
      final propertyRegistry = JsonLdPropertyRegistry();

      final plugin = SchemaOrgCorePlugin();
      plugin.register(widgetRegistry, propertyRegistry);

      expect(widgetRegistry.hasType('schema:Event'), isTrue);
      expect(widgetRegistry.hasType('schema:Product'), isTrue);
      expect(widgetRegistry.hasType('schema:Recipe'), isTrue);
      expect(widgetRegistry.hasType('schema:Place'), isTrue);
      expect(widgetRegistry.hasType('schema:Review'), isTrue);
    });
  });
}
