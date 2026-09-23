import '../models/json_ld_node.dart';

/// Engine for JSON-LD Framing algorithms.
/// Filters, re-shapes, and expands multi-node graphs into target nested trees according to frame criteria.
class JsonLdFraming {
  /// Frames a multi-entity JSON-LD document or `@graph` against a frame specification map.
  static Map<String, dynamic> frameDocument(
    Map<String, dynamic> doc,
    Map<String, dynamic> frame,
  ) {
    final rootNode = JsonLdNode.fromJson(doc);
    final nodesToFrame = rootNode.isGraph ? rootNode.graphNodes : [rootNode];

    final targetType = frame['@type'];
    final targetId = frame['@id'];

    JsonLdNode? matchingRoot;

    for (final candidate in nodesToFrame) {
      bool typeMatch = true;
      bool idMatch = true;

      if (targetType != null) {
        typeMatch = candidate.types.contains(targetType) ||
            candidate.types.any((t) => t.endsWith(targetType.toString()));
      }

      if (targetId != null) {
        idMatch = candidate.id == targetId;
      }

      if (typeMatch && idMatch) {
        matchingRoot = candidate;
        break;
      }
    }

    if (matchingRoot == null) {
      return {'@context': doc['@context'], '@graph': []};
    }

    // Embed matching references from graph into target root tree
    final framedMap = _expandReferencesInMap(
      matchingRoot.toJson(),
      nodesToFrame.map((n) => n.toJson()).toList(),
    );

    if (doc.containsKey('@context')) {
      framedMap['@context'] = doc['@context'];
    }

    return framedMap;
  }

  static Map<String, dynamic> _expandReferencesInMap(
    Map<String, dynamic> nodeMap,
    List<Map<String, dynamic>> allGraphNodes,
  ) {
    final result = Map<String, dynamic>.from(nodeMap);

    result.forEach((key, val) {
      if (key == '@id' || key == '@type' || key == '@context') return;

      if (val is Map<String, dynamic> && val.containsKey('@id') && val.length == 1) {
        final refId = val['@id'];
        final found = allGraphNodes.firstWhere(
          (element) => element['@id'] == refId,
          orElse: () => val,
        );
        if (found != val) {
          result[key] = _expandReferencesInMap(found, allGraphNodes);
        }
      } else if (val is List) {
        result[key] = val.map((item) {
          if (item is Map<String, dynamic> && item.containsKey('@id') && item.length == 1) {
            final refId = item['@id'];
            final found = allGraphNodes.firstWhere(
              (element) => element['@id'] == refId,
              orElse: () => item,
            );
            if (found != item) {
              return _expandReferencesInMap(found, allGraphNodes);
            }
          }
          return item;
        }).toList();
      }
    });

    return result;
  }
}
