import '../models/json_ld_node.dart';

enum JsonLdDocumentType {
  vocabulary, // Vocabulary schema definition file (contains rdfs:Class, rdf:Property, rdfs:type, etc.)
  instanceData, // Instance data payload (schema:Event, schema:Product, etc.)
  unknown,
}

/// Analyzer utility to inspect JSON-LD documents and determine if payload
/// is a vocabulary specification vs instance data payload.
class VocabularyAnalyzer {
  static JsonLdDocumentType detectDocumentType(dynamic rawJson) {
    if (rawJson == null) return JsonLdDocumentType.unknown;

    final node = JsonLdNode.fromJson(rawJson);

    // If @graph contains vocabulary elements
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

  /// Extracts classes and properties when processing vocabulary file
  /// for code generation or dynamic schema building.
  static Map<String, List<String>> extractVocabularyTerms(dynamic rawJson) {
    final node = JsonLdNode.fromJson(rawJson);
    final classes = <String>[];
    final properties = <String>[];

    final nodesToInspect = node.isGraph ? node.graphNodes : [node];

    for (final item in nodesToInspect) {
      if (item.id != null) {
        if (item.types.any((t) => t.toLowerCase().contains('class'))) {
          classes.add(item.id!);
        } else if (item.types.any((t) => t.toLowerCase().contains('property'))) {
          properties.add(item.id!);
        }
      }
    }

    return {
      'classes': classes,
      'properties': properties,
    };
  }
}
