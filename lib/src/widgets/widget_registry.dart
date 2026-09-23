import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';

/// Signature for custom type widget builders.
typedef JsonLdWidgetBuilder = Widget Function(
  BuildContext context,
  JsonLdNode node, {
  required bool isEditable,
  required String activeLanguage,
  void Function(JsonLdNode updatedNode)? onChanged,
  void Function(String id)? onNodeTap,
});

/// Registry for mapping `@type` IRIs/terms to specific Flutter Widget builders.
class JsonLdWidgetRegistry {
  static final JsonLdWidgetRegistry _instance = JsonLdWidgetRegistry._internal();
  factory JsonLdWidgetRegistry() => _instance;
  JsonLdWidgetRegistry._internal();

  final Map<String, JsonLdWidgetBuilder> _registry = {};

  /// Registers a custom builder for a given @type IRI or term.
  void register(String type, JsonLdWidgetBuilder builder) {
    _registry[type] = builder;
  }

  /// Removes a type builder registration.
  void unregister(String type) {
    _registry.remove(type);
  }

  /// Finds builder for given types or null if no custom builder matches.
  JsonLdWidgetBuilder? lookup(List<String> types) {
    for (final type in types) {
      if (_registry.containsKey(type)) {
        return _registry[type];
      }
    }
    return null;
  }

  /// Checks if registry has custom builder for type.
  bool hasType(String type) => _registry.containsKey(type);
}
