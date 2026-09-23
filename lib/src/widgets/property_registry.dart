import 'package:flutter/material.dart';

/// Signature for custom property widget builders.
typedef JsonLdPropertyWidgetBuilder = Widget Function(
  BuildContext context,
  String propertyName,
  dynamic propertyValue, {
  required bool isEditable,
  required String activeLanguage,
  void Function(dynamic updatedValue)? onChanged,
  void Function(String id)? onNodeTap,
});

/// Pluggable registry mapping specific property IRIs or terms (e.g., `schema:ratingValue`, `schema:price`, `schema:geo`)
/// to custom UI renderer widgets without modifying core rendering logic.
class JsonLdPropertyRegistry {
  static final JsonLdPropertyRegistry _instance = JsonLdPropertyRegistry._internal();
  factory JsonLdPropertyRegistry() => _instance;
  JsonLdPropertyRegistry._internal();

  final Map<String, JsonLdPropertyWidgetBuilder> _registry = {};

  /// Registers a custom builder for a given property key/IRI.
  void register(String propertyKey, JsonLdPropertyWidgetBuilder builder) {
    _registry[propertyKey] = builder;
  }

  /// Removes property builder registration.
  void unregister(String propertyKey) {
    _registry.remove(propertyKey);
  }

  /// Looks up custom builder for a property.
  JsonLdPropertyWidgetBuilder? lookup(String propertyKey) {
    if (_registry.containsKey(propertyKey)) {
      return _registry[propertyKey];
    }
    // Try matching short term (e.g. "ratingValue" for "schema:ratingValue")
    for (final key in _registry.keys) {
      if (propertyKey.endsWith(key) || key.endsWith(propertyKey)) {
        return _registry[key];
      }
    }
    return null;
  }

  /// Checks if registry has builder for property key.
  bool hasProperty(String propertyKey) => lookup(propertyKey) != null;
}
