import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';
import 'package:app/src/utils/schema_org_downloader.dart';

void main() {
  group('Schema.org Full Vocabulary Tests', () {
    test('SchemaOrgDownloader loads and parses vocabulary taxonomy classes and properties', () {
      final vocab = SchemaOrgDownloader.loadSchemaOrgVocabulary();
      final classes = vocab['classes'] as Map<String, SchemaClassTerm>;
      final properties = vocab['properties'] as Map<String, SchemaPropertyTerm>;

      expect(classes.containsKey('https://schema.org/Thing'), isTrue);
      expect(classes.containsKey('https://schema.org/CreativeWork'), isTrue);
      expect(classes.containsKey('https://schema.org/Recipe'), isTrue);

      expect(properties.containsKey('https://schema.org/name'), isTrue);
      expect(properties.containsKey('https://schema.org/description'), isTrue);
      expect(properties.containsKey('https://schema.org/url'), isTrue);
    });

    test('Generates UI instance template for any top-level Schema.org class', () {
      final vocab = SchemaOrgDownloader.loadSchemaOrgVocabulary();
      final properties = vocab['properties'] as Map<String, SchemaPropertyTerm>;

      final template = VocabularyAnalyzer.generateInstanceTemplate(
        'https://schema.org/CreativeWork',
        properties,
      );

      expect(template['@type'], equals('CreativeWork'));
      expect(template.containsKey('@id'), isTrue);
    });
  });
}
