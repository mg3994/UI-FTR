import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';
import 'package:app/src/widgets/property_registry.dart';
import 'package:app/src/widgets/custom_property_widgets.dart';
import 'package:app/src/theme/json_ld_theme.dart';

void main() {
  group('JSON-LD Framework Tests', () {
    test('JsonLdPropertyRegistry correctly registers and looks up custom property builders', () {
      final registry = JsonLdPropertyRegistry();
      registry.register('schema:ratingValue', (context, propertyName, value,
          {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
        return CustomPropertyWidgets.buildRatingWidget(
          context, propertyName, value, isEditable: isEditable, onChanged: onChanged
        );
      });

      expect(registry.hasProperty('schema:ratingValue'), isTrue);
      expect(registry.lookup('ratingValue'), isNotNull);
    });

    test('JsonLdTheme provides correct density padding and styling', () {
      const themeCompact = JsonLdTheme(density: JsonLdDensity.compact);
      expect(themeCompact.contentPadding, equals(const EdgeInsets.all(8.0)));

      const themeExpanded = JsonLdTheme(density: JsonLdDensity.expanded);
      expect(themeExpanded.contentPadding, equals(const EdgeInsets.all(24.0)));
    });

    testWidgets('Renders CustomPropertyWidgets star rating widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return CustomPropertyWidgets.buildRatingWidget(
                  context,
                  'schema:ratingValue',
                  4.5,
                  isEditable: false,
                );
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(4));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
    });
  });
}
