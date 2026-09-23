import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';

void main() {
  group('JSON-LD Context Resolver Tests', () {
    test('JsonLdContextResolver resolves built-in schema.org terms offline', () async {
      final context = await JsonLdContextResolver.resolveContext('https://schema.org');
      expect(context.expandTerm('name'), equals('https://schema.org/name'));
      expect(context.expandTerm('startDate'), equals('https://schema.org/startDate'));
    });
  });
}
