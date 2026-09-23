import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';

enum JsonLdDocumentType {
  vocabulary, // Vocabulary schema definition file (contains rdfs:Class, rdf:Property, etc.)
  instanceData, // Instance data payload (schema:Event, schema:Product, etc.)
  unknown,
}

class SchemaClassTerm {
  final String id;
  final String label;
  final String comment;
  final List<String> subClassOf;

  const SchemaClassTerm({
    required this.id,
    required this.label,
    required this.comment,
    this.subClassOf = const [],
  });
}

class SchemaPropertyTerm {
  final String id;
  final String label;
  final String comment;
  final List<String> domainIncludes;
  final List<String> rangeIncludes;

  const SchemaPropertyTerm({
    required this.id,
    required this.label,
    required this.comment,
    this.domainIncludes = const [],
    this.rangeIncludes = const [],
  });
}

/// Analyzer utility to inspect JSON-LD documents, detect vocabulary files vs
/// instance data payloads, and index full vocabulary schemas like schemaorg-current-https.jsonld.
class VocabularyAnalyzer {
  static JsonLdDocumentType detectDocumentType(dynamic rawJson) {
    if (rawJson == null) return JsonLdDocumentType.unknown;

    final node = JsonLdNode.fromJson(rawJson);

    if (node.isGraph) {
      final vocabCount = node.graphNodes.where((child) => _isVocabNode(child)).length;
      if (vocabCount > 0) {
        return JsonLdDocumentType.vocabulary;
      }
    } else {
      if (_isVocabNode(node)) {
        return JsonLdDocumentType.vocabulary;
      }
    }

    return JsonLdDocumentType.instanceData;
  }

  static bool _isVocabNode(JsonLdNode node) {
    for (final type in node.types) {
      final lower = type.toLowerCase();
      if (lower.contains('rdfs:class') ||
          lower.contains('rdf:property') ||
          lower.contains('owl:class') ||
          lower.contains('http://www.w3.org/2000/01/rdf-schema#class') ||
          lower.contains('http://www.w3.org/1999/02/22-rdf-syntax-ns#property')) {
        return true;
      }
    }
    return false;
  }

  /// Parses and indexes full vocabulary schema definitions (e.g. Schema.org vocabulary)
  /// into structured classes and properties.
  static Map<String, dynamic> parseVocabularySchema(dynamic rawJson) {
    final node = JsonLdNode.fromJson(rawJson);
    final classesMap = <String, SchemaClassTerm>{};
    final propertiesMap = <String, SchemaPropertyTerm>{};

    final nodesToInspect = node.isGraph ? node.graphNodes : [node];

    for (final item in nodesToInspect) {
      if (item.id == null) continue;

      final itemId = item.id!;
      final label = _extractStringProp(item, 'rdfs:label') ?? _getShortTerm(itemId);
      final comment = _extractStringProp(item, 'rdfs:comment') ?? '';

      final isClass = item.types.any((t) => t.toLowerCase().contains('class'));
      final isProperty = item.types.any((t) => t.toLowerCase().contains('property'));

      if (isClass) {
        final parents = _extractRefList(item, 'rdfs:subClassOf');
        classesMap[itemId] = SchemaClassTerm(
          id: itemId,
          label: label,
          comment: comment,
          subClassOf: parents,
        );
      } else if (isProperty) {
        final domains = _extractRefList(item, 'schema:domainIncludes');
        final ranges = _extractRefList(item, 'schema:rangeIncludes');
        propertiesMap[itemId] = SchemaPropertyTerm(
          id: itemId,
          label: label,
          comment: comment,
          domainIncludes: domains,
          rangeIncludes: ranges,
        );
      }
    }

    return {
      'classes': classesMap,
      'properties': propertiesMap,
    };
  }

  /// Generates a blank JSON-LD template object for a given Schema.org class IRI.
  static Map<String, dynamic> generateInstanceTemplate(
    String classIri,
    Map<String, SchemaPropertyTerm> propertiesMap,
  ) {
    final shortClass = _getShortTerm(classIri);
    final template = <String, dynamic>{
      '@context': 'https://schema.org',
      '@type': shortClass,
      '@id': 'https://example.com/new-$shortClass-${DateTime.now().millisecondsSinceEpoch}',
    };

    // Find properties where domain includes this class
    int propCount = 0;
    propertiesMap.forEach((propId, propTerm) {
      if (propCount >= 8) return; // Limit top template properties for UI clarity
      final matchesDomain = propTerm.domainIncludes.any(
        (domain) => domain == classIri || _getShortTerm(domain) == shortClass,
      );

      if (matchesDomain) {
        final propName = propTerm.label.isNotEmpty ? propTerm.label : _getShortTerm(propId);
        final rangeFirst = propTerm.rangeIncludes.isNotEmpty
            ? _getShortTerm(propTerm.rangeIncludes.first)
            : 'Text';

        if (rangeFirst == 'Text' || rangeFirst == 'URL') {
          template['schema:$propName'] = 'Sample $propName value';
        } else if (rangeFirst == 'Date' || rangeFirst == 'DateTime') {
          template['schema:$propName'] = DateTime.now().toIso8601String();
        } else {
          template['schema:$propName'] = {
            '@type': 'schema:$rangeFirst',
            'schema:name': 'Sample $rangeFirst Item',
          };
        }
        propCount++;
      }
    });

    if (propCount == 0) {
      template['schema:name'] = 'Sample $shortClass';
      template['schema:description'] = 'Sample description for $shortClass';
    }

    return template;
  }

  static String? _extractStringProp(JsonLdNode node, String propName) {
    final raw = node.properties[propName];
    if (raw is JsonLdValue) return raw.displayString;
    if (raw is String) return raw;
    return null;
  }

  static List<String> _extractRefList(JsonLdNode node, String propName) {
    final refs = <String>[];
    final raw = node.properties[propName];

    void addRef(dynamic item) {
      if (item is JsonLdNode && item.id != null) {
        refs.add(item.id!);
      } else if (item is Map<String, dynamic> && item.containsKey('@id')) {
        refs.add(item['@id'].toString());
      } else if (item is String) {
        refs.add(item);
      }
    }

    if (raw is List) {
      for (final e in raw) {
        addRef(e);
      }
    } else if (raw != null) {
      addRef(raw);
    }
    return refs;
  }

  static String _getShortTerm(String iri) {
    if (iri.contains('#')) return iri.split('#').last;
    if (iri.contains('/')) return iri.split('/').last;
    if (iri.contains(':')) return iri.split(':').last;
    return iri;
  }
}
