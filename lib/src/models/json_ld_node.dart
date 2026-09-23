import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'json_ld_value.dart';

/// Context representation for resolving compact terms to full IRIs.
@immutable
class JsonLdContext {
  final Map<String, dynamic> terms;
  final List<String> remoteUrls;

  const JsonLdContext({
    this.terms = const {},
    this.remoteUrls = const [],
  });

  factory JsonLdContext.fromJson(dynamic json) {
    final termsMap = <String, dynamic>{};
    final urls = <String>[];

    void processEntry(dynamic entry) {
      if (entry is String) {
        urls.add(entry);
      } else if (entry is Map<String, dynamic>) {
        termsMap.addAll(entry);
      } else if (entry is List) {
        for (final item in entry) {
          processEntry(item);
        }
      }
    }

    processEntry(json);
    return JsonLdContext(terms: termsMap, remoteUrls: urls);
  }

  /// Resolves a compacted term or return the term itself if unresolved.
  String expandTerm(String term) {
    if (terms.containsKey(term)) {
      final val = terms[term];
      if (val is String) return val;
      if (val is Map<String, dynamic> && val.containsKey('@id')) {
        return val['@id'].toString();
      }
    }
    return term;
  }
}

/// Dynamic, flexible representation of ANY JSON-LD Node object.
/// Supports @id, @type (single or array), @graph, @list, @set, @reverse, @index, @nest,
/// and arbitrary custom properties.
@immutable
class JsonLdNode {
  /// Node identity IRI (`@id`).
  final String? id;

  /// Types assigned to node (`@type`).
  final List<String> types;

  /// Scoped context (`@context`).
  final JsonLdContext? context;

  /// Main property map holding literals, localized sets, nested nodes, or collections.
  final Map<String, dynamic> properties;

  /// Inverse relationships (`@reverse`).
  final Map<String, dynamic> reverseProperties;

  /// Optional `@index` key.
  final String? index;

  /// Embedded graph nodes if payload is `@graph` container.
  final List<JsonLdNode> graphNodes;

  const JsonLdNode({
    this.id,
    this.types = const [],
    this.context,
    this.properties = const {},
    this.reverseProperties = const {},
    this.index,
    this.graphNodes = const [],
  });

  /// Primary `@type` IRI or term.
  String get primaryType => types.isNotEmpty ? types.first : 'schema:Thing';

  /// Helper to check if node matches a given type IRI/term.
  bool isType(String typeName) => types.contains(typeName);

  /// Helper to determine if this document is a top-level `@graph` document.
  bool get isGraph => graphNodes.isNotEmpty;

  /// Parses any JSON-LD object payload safely into a `JsonLdNode`.
  factory JsonLdNode.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const JsonLdNode();
    }

    // Extract Context
    JsonLdContext? ctx;
    if (json.containsKey('@context')) {
      ctx = JsonLdContext.fromJson(json['@context']);
    }

    // Extract Top-Level @graph
    if (json.containsKey('@graph')) {
      final graphRaw = json['@graph'];
      final nodes = <JsonLdNode>[];
      if (graphRaw is List) {
        for (final item in graphRaw) {
          if (item is Map<String, dynamic>) {
            nodes.add(JsonLdNode.fromJson(item));
          }
        }
      }
      return JsonLdNode(
        id: json['@id'] as String?,
        context: ctx,
        graphNodes: nodes,
      );
    }

    // Extract @id
    final idStr = json['@id'] as String?;

    // Extract @type (can be String or List<dynamic>)
    final typeList = <String>[];
    if (json.containsKey('@type')) {
      final typeRaw = json['@type'];
      if (typeRaw is String) {
        typeList.add(typeRaw);
      } else if (typeRaw is List) {
        for (final item in typeRaw) {
          if (item != null) typeList.add(item.toString());
        }
      }
    }

    // Extract @index
    final indexStr = json['@index'] as String?;

    // Extract @reverse
    final reverseMap = <String, dynamic>{};
    if (json.containsKey('@reverse') && json['@reverse'] is Map<String, dynamic>) {
      final revRaw = json['@reverse'] as Map<String, dynamic>;
      revRaw.forEach((k, v) {
        reverseMap[k] = _parsePropertyValue(v);
      });
    }

    // Extract Properties (including handling @nest)
    final props = <String, dynamic>{};

    void extractProps(Map<String, dynamic> rawMap) {
      rawMap.forEach((key, value) {
        if (key.startsWith('@')) {
          if (key == '@nest' && value is Map<String, dynamic>) {
            extractProps(value);
          }
          // Other keywords (@id, @type, @context, @index, @reverse) handled separately.
          return;
        }

        props[key] = _parsePropertyValue(value);
      });
    }

    extractProps(json);

    return JsonLdNode(
      id: idStr,
      types: typeList,
      context: ctx,
      properties: props,
      reverseProperties: reverseMap,
      index: indexStr,
    );
  }

  /// Helper to recursively parse property values into structured JSON-LD types.
  static dynamic _parsePropertyValue(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      // Check for @list container
      if (value.containsKey('@list')) {
        final listVal = value['@list'];
        if (listVal is List) {
          return listVal.map((e) => _parsePropertyValue(e)).toList();
        }
      }

      // Check for @set container
      if (value.containsKey('@set')) {
        final setVal = value['@set'];
        if (setVal is List) {
          return setVal.map((e) => _parsePropertyValue(e)).toList();
        }
      }

      // Check if it's a value object (@value)
      if (value.containsKey('@value')) {
        return JsonLdValue.fromJson(value);
      }

      // Check if it's a reference node (only @id) or full nested JsonLdNode
      return JsonLdNode.fromJson(value);
    }

    if (value is List) {
      // Return list of parsed children or LocalizedSet if all are value objects
      final parsedList = value.map((item) => _parsePropertyValue(item)).toList();
      final isAllValues = parsedList.every((e) => e is JsonLdValue);
      if (isAllValues && parsedList.isNotEmpty) {
        return JsonLdLocalizedSet(parsedList.cast<JsonLdValue>());
      }
      return parsedList;
    }

    // Direct scalar literal
    return JsonLdValue.fromJson(value);
  }

  /// Safely converts Node to JSON map.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (id != null) map['@id'] = id;
    if (types.isNotEmpty) {
      map['@type'] = types.length == 1 ? types.first : types;
    }
    if (index != null) map['@index'] = index;

    if (reverseProperties.isNotEmpty) {
      final revMap = <String, dynamic>{};
      reverseProperties.forEach((k, v) {
        revMap[k] = _serializePropertyValue(v);
      });
      map['@reverse'] = revMap;
    }

    properties.forEach((k, v) {
      map[k] = _serializePropertyValue(v);
    });

    if (graphNodes.isNotEmpty) {
      map['@graph'] = graphNodes.map((n) => n.toJson()).toList();
    }

    return map;
  }

  static dynamic _serializePropertyValue(dynamic value) {
    if (value is JsonLdValue) return value.toJson();
    if (value is JsonLdLocalizedSet) return value.toJson();
    if (value is JsonLdNode) return value.toJson();
    if (value is List) {
      return value.map((e) => _serializePropertyValue(e)).toList();
    }
    return value;
  }

  /// Creates a copy of the node with modified property map.
  JsonLdNode copyWithProperty(String key, dynamic value) {
    final updatedProps = Map<String, dynamic>.from(properties);
    if (value == null) {
      updatedProps.remove(key);
    } else {
      updatedProps[key] = value;
    }
    return JsonLdNode(
      id: id,
      types: types,
      context: context,
      properties: updatedProps,
      reverseProperties: reverseProperties,
      index: index,
      graphNodes: graphNodes,
    );
  }
}
