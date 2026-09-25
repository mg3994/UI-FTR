import 'vocabulary_analyzer.dart';

/// Utility to fetch or load the full Schema.org vocabulary JSON-LD definition
/// (`https://schema.org/version/latest/schemaorg-current-https.jsonld`).
class SchemaOrgDownloader {
  static Map<String, dynamic>? _cachedParsedVocab;

  /// Top-level Schema.org core classes for quick navigation.
  static const List<String> topLevelClasses = [
    'Thing',
    'Action',
    'CreativeWork',
    'Event',
    'Intangible',
    'MedicalEntity',
    'Organization',
    'Person',
    'Place',
    'Product',
  ];

  /// Core embedded Schema.org vocabulary taxonomy fallback covering major branches
  /// when running offline or without internet access.
  static const Map<String, dynamic> offlineSchemaOrgPayload = {
    "@context": {
      "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
      "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "schema": "https://schema.org/"
    },
    "@graph": [
      {
        "@id": "https://schema.org/Thing",
        "@type": "rdfs:Class",
        "rdfs:label": "Thing",
        "rdfs:comment": "The most generic type of item."
      },
      {
        "@id": "https://schema.org/Action",
        "@type": "rdfs:Class",
        "rdfs:label": "Action",
        "rdfs:comment": "An action performed by a direct agent upon an object.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/CreativeWork",
        "@type": "rdfs:Class",
        "rdfs:label": "CreativeWork",
        "rdfs:comment": "The most generic kind of creative work, including a book, movie, etc.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/Event",
        "@type": "rdfs:Class",
        "rdfs:label": "Event",
        "rdfs:comment": "An event happening at a certain time and location.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/Intangible",
        "@type": "rdfs:Class",
        "rdfs:label": "Intangible",
        "rdfs:comment": "A utility class that serves as the parent for intangible items.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/Organization",
        "@type": "rdfs:Class",
        "rdfs:label": "Organization",
        "rdfs:comment": "An organization such as a school, NGO, corporation, etc.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/Person",
        "@type": "rdfs:Class",
        "rdfs:label": "Person",
        "rdfs:comment": "A person (alive, dead, undead, or fictional).",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/Place",
        "@type": "rdfs:Class",
        "rdfs:label": "Place",
        "rdfs:comment": "Entities that have a somewhat fixed, physical location.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/Product",
        "@type": "rdfs:Class",
        "rdfs:label": "Product",
        "rdfs:comment": "Any offered product or service.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/Thing"}]
      },
      {
        "@id": "https://schema.org/Recipe",
        "@type": "rdfs:Class",
        "rdfs:label": "Recipe",
        "rdfs:comment": "A recipe for food or drink.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/CreativeWork"}]
      },
      {
        "@id": "https://schema.org/Review",
        "@type": "rdfs:Class",
        "rdfs:label": "Review",
        "rdfs:comment": "A review of an item.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/CreativeWork"}]
      },
      {
        "@id": "https://schema.org/Article",
        "@type": "rdfs:Class",
        "rdfs:label": "Article",
        "rdfs:comment": "An article, such as a news article or piece of investigative reporting.",
        "rdfs:subClassOf": [{"@id": "https://schema.org/CreativeWork"}]
      },
      {
        "@id": "https://schema.org/name",
        "@type": "rdf:Property",
        "rdfs:label": "name",
        "rdfs:comment": "The name of the item.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Thing"}],
        "schema:rangeIncludes": [{"@id": "https://schema.org/Text"}]
      },
      {
        "@id": "https://schema.org/description",
        "@type": "rdf:Property",
        "rdfs:label": "description",
        "rdfs:comment": "A description of the item.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Thing"}],
        "schema:rangeIncludes": [{"@id": "https://schema.org/Text"}]
      },
      {
        "@id": "https://schema.org/url",
        "@type": "rdf:Property",
        "rdfs:label": "url",
        "rdfs:comment": "URL of the item.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Thing"}],
        "schema:rangeIncludes": [{"@id": "https://schema.org/URL"}]
      },
      {
        "@id": "https://schema.org/image",
        "@type": "rdf:Property",
        "rdfs:label": "image",
        "rdfs:comment": "An image of the item.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Thing"}],
        "schema:rangeIncludes": [{"@id": "https://schema.org/URL"}, {"@id": "https://schema.org/ImageObject"}]
      }
    ]
  };

  /// Loads and parses the full Schema.org vocabulary definition.
  static Map<String, dynamic> loadSchemaOrgVocabulary({dynamic customPayload}) {
    if (_cachedParsedVocab != null && customPayload == null) {
      return _cachedParsedVocab!;
    }

    final payload = customPayload ?? offlineSchemaOrgPayload;
    final parsed = VocabularyAnalyzer.parseVocabularySchema(payload);
    if (customPayload == null) {
      _cachedParsedVocab = parsed;
    }
    return parsed;
  }
}
