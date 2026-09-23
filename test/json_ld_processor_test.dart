import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';

void main() {
  group('JSON-LD Processor Tests', () {
    test('JsonLdProcessor expands terms based on context', () {
      final context = JsonLdContext.fromJson({
        "name": "https://schema.org/name",
        "description": "https://schema.org/description"
      });

      final doc = {
        "name": "Pasta Carbonara",
        "description": "Italian pasta"
      };

      final expanded = JsonLdProcessor.expandDocument(doc, context);
      expect(expanded.containsKey("https://schema.org/name"), isTrue);
      expect(expanded["https://schema.org/name"], equals("Pasta Carbonara"));
    });

    test('JsonLdProcessor compacts full IRIs back to context terms', () {
      final context = JsonLdContext.fromJson({
        "name": "https://schema.org/name"
      });

      final expandedDoc = {
        "https://schema.org/name": "Pasta Carbonara"
      };

      final compacted = JsonLdProcessor.compactDocument(expandedDoc, context);
      expect(compacted.containsKey("name"), isTrue);
      expect(compacted["name"], equals("Pasta Carbonara"));
    });

    test('JsonLdProcessor flattens nested embedded nodes into a graph array', () {
      final doc = {
        "@id": "https://example.com/event/1",
        "@type": "schema:Event",
        "schema:name": "Summit 2026",
        "schema:location": {
          "@id": "https://example.com/place/1",
          "@type": "schema:Place",
          "schema:name": "Tech Center"
        }
      };

      final flattened = JsonLdProcessor.flattenDocument(doc);
      expect(flattened.length, equals(2));
      expect(flattened.any((n) => n['@id'] == "https://example.com/place/1"), isTrue);
    });
  });
}
