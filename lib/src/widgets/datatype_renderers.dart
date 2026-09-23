import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';
import 'widget_registry.dart';

/// Comprehensive datatype renderers for JSON-LD properties including
/// strings, localized strings, dates, image URLs, links, nested objects, and collections.
class JsonLdPropertyRenderer extends StatelessWidget {
  final String propertyName;
  final dynamic propertyValue;
  final bool isEditable;
  final String activeLanguage;
  final void Function(dynamic updatedValue)? onChanged;
  final void Function(String id)? onNodeTap;

  const JsonLdPropertyRenderer({
    super.key,
    required this.propertyName,
    required this.propertyValue,
    this.isEditable = false,
    this.activeLanguage = 'en',
    this.onChanged,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (propertyValue == null) {
      return const SizedBox.shrink();
    }

    // 1. Single Localized or Typed Value
    if (propertyValue is JsonLdValue) {
      return _buildValueRenderer(context, propertyValue as JsonLdValue);
    }

    // 2. Set of Localized Values
    if (propertyValue is JsonLdLocalizedSet) {
      final locSet = propertyValue as JsonLdLocalizedSet;
      final activeVal = locSet.resolve(activeLanguage) ??
          (locSet.values.isNotEmpty ? locSet.values.first : const JsonLdValue(value: ''));

      return _buildValueRenderer(
        context,
        activeVal,
        availableLanguages: locSet.values,
      );
    }

    // 3. Nested JSON-LD Node (Object)
    if (propertyValue is JsonLdNode) {
      final node = propertyValue as JsonLdNode;
      return _buildNestedNodeRenderer(context, node);
    }

    // 4. Collection / List (@list or @set)
    if (propertyValue is List) {
      final items = propertyValue as List;
      return _buildListRenderer(context, items);
    }

    // Fallback scalar
    return Text('$propertyName: $propertyValue');
  }

  Widget _buildValueRenderer(
    BuildContext context,
    JsonLdValue valueObj, {
    List<JsonLdValue>? availableLanguages,
  }) {
    final strVal = valueObj.displayString;

    // A. Image Object / Image URL
    if (_isImageProperty(propertyName, strVal)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatLabel(propertyName),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                strVal,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Image unable to load: $strVal'),
                    ],
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 120,
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // B. URL Link Property
    if (_isUrlProperty(propertyName, strVal)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: InkWell(
          onTap: () {
            if (onNodeTap != null) {
              onNodeTap!(strVal);
            }
          },
          child: Row(
            children: [
              const Icon(Icons.link, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  strVal,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // C. Editable Field
    if (isEditable) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: TextFormField(
          initialValue: strVal,
          textDirection: valueObj.direction == TextDirectionality.rtl
              ? TextDirection.rtl
              : TextDirection.ltr,
          decoration: InputDecoration(
            labelText: _formatLabel(propertyName) +
                (valueObj.language != null ? ' (${valueObj.language})' : ''),
            border: const OutlineInputBorder(),
            suffixIcon: valueObj.language != null
                ? Chip(
                    label: Text(
                      valueObj.language!,
                      style: const TextStyle(fontSize: 10),
                    ),
                  )
                : null,
          ),
          onChanged: (val) {
            if (onChanged != null) {
              onChanged!(valueObj.copyWith(value: val));
            }
          },
        ),
      );
    }

    // D. Display Read-Only Value
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Directionality(
        textDirection: valueObj.direction == TextDirectionality.rtl
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                _formatLabel(propertyName),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                strVal,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (valueObj.language != null)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  valueObj.language!,
                  style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade800),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNestedNodeRenderer(BuildContext context, JsonLdNode node) {
    // Check if node is just an @id reference
    if (node.id != null && node.properties.isEmpty && node.types.isEmpty) {
      return ListTile(
        leading: const Icon(Icons.arrow_forward, color: Colors.indigo),
        title: Text('Reference: ${node.id}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (onNodeTap != null) {
            onNodeTap!(node.id!);
          }
        },
      );
    }

    // Custom Builder Lookup
    final builder = JsonLdWidgetRegistry().lookup(node.types);
    if (builder != null) {
      return builder(
        context,
        node,
        isEditable: isEditable,
        activeLanguage: activeLanguage,
        onChanged: (updated) {
          if (onChanged != null) onChanged!(updated);
        },
        onNodeTap: onNodeTap,
      );
    }

    // Generic Nested Card Fallback
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          '${_formatLabel(propertyName)} (${node.primaryType})',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: node.id != null ? Text('ID: ${node.id}') : null,
        children: node.properties.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: JsonLdPropertyRenderer(
              propertyName: entry.key,
              propertyValue: entry.value,
              isEditable: isEditable,
              activeLanguage: activeLanguage,
              onChanged: (newVal) {
                final updatedNode = node.copyWithProperty(entry.key, newVal);
                if (onChanged != null) onChanged!(updatedNode);
              },
              onNodeTap: onNodeTap,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListRenderer(BuildContext context, List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            '${_formatLabel(propertyName)} (${items.length})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        ...items.map((item) => JsonLdPropertyRenderer(
              propertyName: propertyName,
              propertyValue: item,
              isEditable: isEditable,
              activeLanguage: activeLanguage,
              onChanged: onChanged,
              onNodeTap: onNodeTap,
            )),
      ],
    );
  }

  bool _isImageProperty(String name, String value) {
    final lowerName = name.toLowerCase();
    final lowerVal = value.toLowerCase();
    return lowerName.contains('image') ||
        lowerName.contains('photo') ||
        lowerName.contains('logo') ||
        lowerVal.endsWith('.jpg') ||
        lowerVal.endsWith('.png') ||
        lowerVal.endsWith('.webp');
  }

  bool _isUrlProperty(String name, String value) {
    final lowerName = name.toLowerCase();
    return (lowerName.contains('url') ||
            lowerName.contains('sameas') ||
            lowerName.contains('website')) &&
        value.startsWith('http');
  }

  String _formatLabel(String key) {
    if (key.startsWith('http://') || key.startsWith('https://')) {
      final uri = Uri.parse(key);
      return uri.fragment.isNotEmpty ? uri.fragment : uri.pathSegments.last;
    }
    if (key.contains(':')) {
      return key.split(':').last;
    }
    return key;
  }
}
