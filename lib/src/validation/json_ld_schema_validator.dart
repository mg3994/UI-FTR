import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';

class ValidationError {
  final String propertyName;
  final String message;

  const ValidationError({
    required this.propertyName,
    required this.message,
  });

  @override
  String toString() => '$propertyName: $message';
}

/// Validator for checking JSON-LD nodes against expected property rules,
/// required fields, and URL/Date format constraints.
class JsonLdSchemaValidator {
  /// Validates a JsonLdNode and returns a list of validation errors.
  static List<ValidationError> validateNode(
    JsonLdNode node, {
    List<String> requiredProperties = const [],
  }) {
    final errors = <ValidationError>[];

    // Check required properties
    for (final reqProp in requiredProperties) {
      if (!node.properties.containsKey(reqProp) || node.properties[reqProp] == null) {
        errors.add(ValidationError(
          propertyName: reqProp,
          message: 'Property is required for ${node.primaryType}.',
        ));
      }
    }

    // Validate individual property values
    node.properties.forEach((key, val) {
      if (val is JsonLdValue) {
        final err = _validateValue(key, val);
        if (err != null) errors.add(err);
      } else if (val is JsonLdLocalizedSet) {
        for (final item in val.values) {
          final err = _validateValue(key, item);
          if (err != null) errors.add(err);
        }
      }
    });

    return errors;
  }

  static ValidationError? _validateValue(String propertyName, JsonLdValue valueObj) {
    final strVal = valueObj.displayString;
    final lowerProp = propertyName.toLowerCase();

    // URL validation
    if ((lowerProp.contains('url') || lowerProp.contains('sameas') || lowerProp.contains('image')) &&
        strVal.isNotEmpty) {
      final uri = Uri.tryParse(strVal);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        return ValidationError(
          propertyName: propertyName,
          message: 'Invalid URL format: "$strVal".',
        );
      }
    }

    // Date validation
    if ((lowerProp.contains('date') || lowerProp.contains('time')) && strVal.isNotEmpty) {
      final parsed = DateTime.tryParse(strVal);
      if (parsed == null) {
        return ValidationError(
          propertyName: propertyName,
          message: 'Invalid ISO date/time format: "$strVal".',
        );
      }
    }

    return null;
  }
}
