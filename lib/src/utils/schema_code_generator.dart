import '../models/json_ld_node.dart';
import 'vocabulary_analyzer.dart';

/// Code generator capable of auto-generating Dart model classes and Flutter widget builder
/// registrations from any JSON-LD document or vocabulary definition.
class JsonLdSchemaCodeGenerator {
  /// Generates Dart class definitions from a JSON-LD node structure or vocabulary term.
  static String generateDartClass(
    String className,
    Map<String, dynamic> properties,
  ) {
    final buffer = StringBuffer();
    final cleanClassName = _sanitizeName(className);

    buffer.writeln('/// Auto-generated Dart model for JSON-LD type: $className');
    buffer.writeln('class $cleanClassName {');
    buffer.writeln('  final String? id;');

    properties.forEach((key, val) {
      final fieldName = _sanitizeFieldName(key);
      final fieldType = _inferDartType(val);
      buffer.writeln('  final $fieldType? $fieldName;');
    });

    buffer.writeln();
    buffer.writeln('  const $cleanClassName({');
    buffer.writeln('    this.id,');
    properties.forEach((key, val) {
      final fieldName = _sanitizeFieldName(key);
      buffer.writeln('    this.$fieldName,');
    });
    buffer.writeln('  });');

    buffer.writeln();
    buffer.writeln('  factory $cleanClassName.fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return $cleanClassName(');
    buffer.writeln('      id: json[\'@id\'] as String?,');
    properties.forEach((key, val) {
      final fieldName = _sanitizeFieldName(key);
      buffer.writeln('      $fieldName: json[\'$key\'],');
    });
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generates Flutter JsonLdWidgetRegistry code snippet for a type.
  static String generateWidgetRegistrationCode(String typeName) {
    final cleanType = _sanitizeName(typeName);
    return '''
// Register custom widget builder for $typeName
JsonLdWidgetRegistry().register('$typeName', (context, node, {
  required isEditable,
  required activeLanguage,
  onChanged,
  onNodeTap,
}) {
  return ${cleanType}Widget(
    node: node,
    isEditable: isEditable,
    activeLanguage: activeLanguage,
    onChanged: onChanged,
    onNodeTap: onNodeTap,
  );
});
''';
  }

  static String _sanitizeName(String name) {
    final short = name.split('/').last.split('#').last.split(':').last;
    if (short.isEmpty) return 'GeneratedModel';
    return short[0].toUpperCase() + short.substring(1);
  }

  static String _sanitizeFieldName(String key) {
    final short = key.split('/').last.split('#').last.split(':').last;
    if (short.isEmpty) return 'field';
    final camel = short[0].toLowerCase() + short.substring(1);
    if (camel == 'id' || camel == 'type') return '${camel}Value';
    return camel;
  }

  static String _inferDartType(dynamic val) {
    if (val is int) return 'int';
    if (val is double || val is num) return 'double';
    if (val is bool) return 'bool';
    if (val is List) return 'List<dynamic>';
    if (val is Map) return 'Map<String, dynamic>';
    return 'String';
  }
}
