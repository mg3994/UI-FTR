import 'package:flutter_test/flutter_test.dart';
import 'package:app/json_ld_framework.dart';

void main() {
  group('JSON-LD Framing Tests', () {
    test('JsonLdFraming reshapes multi-node @graph by target @type', () {
      final doc = {
        "@context": "https://schema.org",
        "@graph": [
          {
            "@id": "https://example.com/event/1",
            "@type": "schema:Event",
            "schema:name": "Tech Conference",
            "schema:location": {"@id": "https://example.com/place/1"}
          },
          {
            "@id": "https://example.com/place/1",
            "@type": "schema:Place",
            "schema:name": "Convention Center"
          }
        ]
      };

      final frame = {"@type": "schema:Event"};
      final framed = JsonLdFraming.frameDocument(doc, frame);

      expect(framed['@type'], equals("schema:Event"));
      expect(framed['schema:name'], equals("Tech Conference"));
      expect(framed['schema:location']['schema:name'], equals("Convention Center"));
    });
  });
}
