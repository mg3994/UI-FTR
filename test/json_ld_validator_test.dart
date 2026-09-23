import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';

void main() {
  group('JSON-LD Validator & Code Generator Tests', () {
    test('JsonLdSchemaValidator validates required fields and URL/Date formats', () {
      final invalidNode = JsonLdNode.fromJson({
        "@type": "schema:Event",
        "schema:url": "invalid-url",
        "schema:startDate": "invalid-date"
      });

      final errors = JsonLdSchemaValidator.validateNode(
        invalidNode,
        requiredProperties: ['schema:name'],
      );

      expect(errors.length, equals(3));
      expect(errors.any((e) => e.propertyName == 'schema:name'), isTrue);
      expect(errors.any((e) => e.message.contains('Invalid URL')), isTrue);
      expect(errors.any((e) => e.message.contains('Invalid ISO date')), isTrue);
    });

    test('JsonLdSchemaCodeGenerator generates Dart model classes and registration snippets', () {
      final properties = {
        'schema:name': 'Sample Product',
        'schema:price': 99.99,
        'schema:isAvailable': true
      };

      final code = JsonLdSchemaCodeGenerator.generateDartClass('Product', properties);
      expect(code, contains('class Product'));
      expect(code, contains('final String? name;'));
      expect(code, contains('final double? price;'));

      final snippet = JsonLdSchemaCodeGenerator.generateWidgetRegistrationCode('Product');
      expect(snippet, contains('JsonLdWidgetRegistry().register(\'Product\''));
    });
  });
}
