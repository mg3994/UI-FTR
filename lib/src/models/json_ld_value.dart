import 'package:flutter/foundation.dart';

/// Represents a direction attribute for localized JSON-LD text (`@direction`).
enum TextDirectionality { ltr, rtl }

/// Encapsulates a JSON-LD value, supporting typed literals, localized strings
/// (`@value`, `@language`, `@direction`), and primitive scalar wrappers.
@immutable
class JsonLdValue {
  /// Raw value (String, num, bool, DateTime, etc.)
  final dynamic value;

  /// Optional language tag, e.g., "en", "es-ES", "ar" (`@language`).
  final String? language;

  /// Optional text directionality, e.g., "ltr" or "rtl" (`@direction`).
  final TextDirectionality? direction;

  /// Optional literal type IRI, e.g., "http://www.w3.org/2001/XMLSchema#dateTime" (`@type`).
  final String? type;

  /// Optional index for `@index` scoped values.
  final String? index;

  const JsonLdValue({
    required this.value,
    this.language,
    this.direction,
    this.type,
    this.index,
  });

  /// Factory constructor to parse any JSON-LD value payload.
  factory JsonLdValue.fromJson(dynamic json) {
    if (json == null) {
      return const JsonLdValue(value: null);
    }

    if (json is JsonLdValue) {
      return json;
    }

    if (json is Map<String, dynamic>) {
      // Check for value object form: {"@value": ..., "@language": ..., "@direction": ...}
      if (json.containsKey('@value')) {
        final rawVal = json['@value'];
        final lang = json['@language'] as String?;
        final dirStr = json['@direction'] as String?;
        final typeStr = json['@type'] as String?;
        final indexStr = json['@index'] as String?;

        TextDirectionality? dir;
        if (dirStr == 'rtl') {
          dir = TextDirectionality.rtl;
        } else if (dirStr == 'ltr') {
          dir = TextDirectionality.ltr;
        }

        return JsonLdValue(
          value: rawVal,
          language: lang,
          direction: dir,
          type: typeStr,
          index: indexStr,
        );
      }
    }

    // Direct primitive literal (String, num, bool)
    return JsonLdValue(value: json);
  }

  /// Converts this value object back to a JSON-LD map or raw scalar.
  dynamic toJson() {
    if (language != null || direction != null || type != null || index != null) {
      final map = <String, dynamic>{'@value': value};
      if (language != null) map['@language'] = language;
      if (direction != null) {
        map['@direction'] = direction == TextDirectionality.rtl ? 'rtl' : 'ltr';
      }
      if (type != null) map['@type'] = type;
      if (index != null) map['@index'] = index;
      return map;
    }
    return value;
  }

  /// Helper to stringify value.
  String get displayString => value?.toString() ?? '';

  /// Copies this value with updated fields for inline editing.
  JsonLdValue copyWith({
    dynamic value,
    String? language,
    TextDirectionality? direction,
    String? type,
    String? index,
  }) {
    return JsonLdValue(
      value: value ?? this.value,
      language: language ?? this.language,
      direction: direction ?? this.direction,
      type: type ?? this.type,
      index: index ?? this.index,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonLdValue &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          language == other.language &&
          direction == other.direction &&
          type == other.type &&
          index == other.index;

  @override
  int get hashCode =>
      Object.hash(value, language, direction, type, index);

  @override
  String toString() => 'JsonLdValue(value: $value, language: $language, dir: $direction)';
}

/// Utility for managing localized values across multiple language tags.
@immutable
class JsonLdLocalizedSet {
  final List<JsonLdValue> values;

  const JsonLdLocalizedSet(this.values);

  factory JsonLdLocalizedSet.fromJson(dynamic json) {
    if (json is List) {
      return JsonLdLocalizedSet(
        json.map((e) => JsonLdValue.fromJson(e)).toList(),
      );
    } else if (json != null) {
      return JsonLdLocalizedSet([JsonLdValue.fromJson(json)]);
    }
    return const JsonLdLocalizedSet([]);
  }

  /// Resolves the best matching `JsonLdValue` according to preferred language tag,
  /// falling back to language-agnostic or the first available value.
  JsonLdValue? resolve(String preferredLanguage) {
    if (values.isEmpty) return null;

    final prefLower = preferredLanguage.toLowerCase();

    // 1. Exact language match (e.g., "en-us" == "en-us")
    for (final val in values) {
      if (val.language?.toLowerCase() == prefLower) {
        return val;
      }
    }

    // 2. Primary language subtag match (e.g., "en" matching "en-US")
    final primaryPref = prefLower.split('-').first;
    for (final val in values) {
      if (val.language?.toLowerCase().split('-').first == primaryPref) {
        return val;
      }
    }

    // 3. Fallback to value with no language tag specified
    for (final val in values) {
      if (val.language == null) {
        return val;
      }
    }

    // 4. Default to first entry
    return values.first;
  }

  List<dynamic> toJson() => values.map((e) => e.toJson()).toList();
}
