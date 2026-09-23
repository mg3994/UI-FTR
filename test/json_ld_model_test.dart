import 'package:flutter_test/flutter_test.dart';
import 'package:app/src/models/json_ld_node.dart';
import 'package:app/src/models/json_ld_value.dart';
import 'package:app/src/utils/vocabulary_analyzer.dart';

void main() {
  group('JSON-LD Model Tests', () {
    test('Parses expanded localized value objects correctly', () {
      final json = {
        "@value": "apple",
        "@language": "en",
        "@direction": "ltr"
      };

      final val = JsonLdValue.fromJson(json);
      expect(val.value, equals("apple"));
      expect(val.language, equals("en"));
      expect(val.direction, equals(TextDirectionality.ltr));
    });

    test('Resolves localized strings by preferred language', () {
      final setJson = [
        {"@value": "Apple", "@language": "en"},
        {"@value": "Manzana", "@language": "es"},
        {"@value": "تفاحة", "@language": "ar", "@direction": "rtl"}
      ];

      final set = JsonLdLocalizedSet.fromJson(setJson);

      final esVal = set.resolve('es');
      expect(esVal?.value, equals('Manzana'));

      final arVal = set.resolve('ar');
      expect(arVal?.value, equals('تفاحة'));
      expect(arVal?.direction, equals(TextDirectionality.rtl));

      final fallback = set.resolve('fr');
      expect(fallback?.value, equals('Apple')); // Fallback to first available
    });

    test('Parses complex JSON-LD node with @graph, @id, @type, @nest, @reverse', () {
      final payload = {
        "@context": "https://schema.org",
        "@id": "http://example.org/item/1",
        "@type": ["schema:Product", "schema:Thing"],
        "@nest": {
          "schema:name": "Nested Widget Product",
          "schema:price": 99.99
        },
        "@reverse": {
          "schema:isRelatedTo": {
            "@id": "http://example.org/item/2"
          }
        }
      };

      final node = JsonLdNode.fromJson(payload);
      expect(node.id, equals("http://example.org/item/1"));
      expect(node.types, containsAll(["schema:Product", "schema:Thing"]));
      expect(node.properties.containsKey("schema:name"), isTrue);
      expect(node.reverseProperties.containsKey("schema:isRelatedTo"), isTrue);
    });

    test('Detects vocabulary specification document vs instance data', () {
      final vocabPayload = {
        "@graph": [
          {
            "@id": "https://schema.org/Person",
            "@type": "rdfs:Class",
            "rdfs:label": "Person",
            "rdfs:comment": "A person."
          },
          {
            "@id": "https://schema.org/name",
            "@type": "rdf:Property",
            "rdfs:label": "name",
            "schema:domainIncludes": [{"@id": "https://schema.org/Person"}]
          }
        ]
      };

      final docType = VocabularyAnalyzer.detectDocumentType(vocabPayload);
      expect(docType, equals(JsonLdDocumentType.vocabulary));

      final parsed = VocabularyAnalyzer.parseVocabularySchema(vocabPayload);
      final classes = parsed['classes'] as Map<String, SchemaClassTerm>;
      final properties = parsed['properties'] as Map<String, SchemaPropertyTerm>;

      expect(classes.containsKey("https://schema.org/Person"), isTrue);
      expect(properties.containsKey("https://schema.org/name"), isTrue);

      final template = VocabularyAnalyzer.generateInstanceTemplate("https://schema.org/Person", properties);
      expect(template['@type'], equals('Person'));
      expect(template.containsKey('schema:name'), isTrue);
    });
  });
}
