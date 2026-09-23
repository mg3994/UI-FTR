import '../models/json_ld_context.dart';

/// Processor providing basic JSON-LD processing algorithms:
/// IRI Expansion, Term Compaction, and Document Flattening.
class JsonLdProcessor {
  /// Expands all compacted terms in a map to full IRIs based on context.
  static Map<String, dynamic> expandDocument(
    Map<String, dynamic> doc,
    JsonLdContext context,
  ) {
    final expanded = <String, dynamic>{};

    doc.forEach((key, val) {
      if (key == '@context') return; // Strip context in expanded form

      final expandedKey = context.expandTerm(key);

      if (val is Map<String, dynamic>) {
        expanded[expandedKey] = expandDocument(val, context);
      } else if (val is List) {
        expanded[expandedKey] = val.map((item) {
          if (item is Map<String, dynamic>) {
            return expandDocument(item, context);
          }
          return item;
        }).toList();
      } else {
        expanded[expandedKey] = val;
      }
    });

    return expanded;
  }

  /// Compacts full IRIs back into short terms if found in context terms map.
  static Map<String, dynamic> compactDocument(
    Map<String, dynamic> doc,
    JsonLdContext context,
  ) {
    final compacted = <String, dynamic>{};
    final reverseTerms = <String, String>{};

    context.terms.forEach((term, iri) {
      if (iri is String) {
        reverseTerms[iri] = term;
      }
    });

    doc.forEach((key, val) {
      final compactedKey = reverseTerms[key] ?? key;

      if (val is Map<String, dynamic>) {
        compacted[compactedKey] = compactDocument(val, context);
      } else if (val is List) {
        compacted[compactedKey] = val.map((item) {
          if (item is Map<String, dynamic>) {
            return compactDocument(item, context);
          }
          return item;
        }).toList();
      } else {
        compacted[compactedKey] = val;
      }
    });

    return compacted;
  }

  /// Flattens nested nodes into a single flat `@graph` array linked by `@id`.
  static List<Map<String, dynamic>> flattenDocument(Map<String, dynamic> doc) {
    final flatGraph = <Map<String, dynamic>>[];

    void extractNode(Map<String, dynamic> nodeMap) {
      final cleanedNode = Map<String, dynamic>.from(nodeMap);

      cleanedNode.forEach((k, v) {
        if (v is Map<String, dynamic> && v.containsKey('@id')) {
          extractNode(v);
          cleanedNode[k] = {'@id': v['@id']}; // Replace embedded child with reference
        } else if (v is List) {
          final updatedList = [];
          for (final item in v) {
            if (item is Map<String, dynamic> && item.containsKey('@id')) {
              extractNode(item);
              updatedList.add({'@id': item['@id']});
            } else {
              updatedList.add(item);
            }
          }
          cleanedNode[k] = updatedList;
        }
      });

      flatGraph.add(cleanedNode);
    }

    extractNode(doc);
    return flatGraph;
  }
}
