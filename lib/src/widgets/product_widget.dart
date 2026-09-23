import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';
import 'datatype_renderers.dart';
import 'responsive_layout.dart';

/// Custom widget tailored for rendering and editing `schema:Product` nodes.
class ProductWidget extends StatelessWidget {
  final JsonLdNode node;
  final bool isEditable;
  final String activeLanguage;
  final void Function(JsonLdNode updatedNode)? onChanged;
  final void Function(String id)? onNodeTap;

  const ProductWidget({
    super.key,
    required this.node,
    this.isEditable = false,
    this.activeLanguage = 'en',
    this.onChanged,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final nameVal = _extractLocalizedValue('schema:name');
    final descVal = _extractLocalizedValue('schema:description');
    final brandVal = _extractStringValue('schema:brand');
    final skuVal = _extractStringValue('schema:sku');
    final imageVal = _extractStringValue('schema:image');
    final offersNode = node.properties['schema:offers'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag, size: 16, color: Colors.teal),
                      const SizedBox(width: 6),
                      Text(
                        node.primaryType,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
                if (brandVal.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.label, size: 14),
                    label: Text(brandVal),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _buildTitle(context, nameVal),
            const SizedBox(height: 8),
            if (imageVal.isNotEmpty)
              JsonLdPropertyRenderer(
                propertyName: 'schema:image',
                propertyValue: JsonLdValue(value: imageVal),
              ),
            const SizedBox(height: 8),
            _buildDescription(context, descVal),
            if (skuVal.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('SKU: $skuVal', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
            const Divider(height: 24),
            if (offersNode != null)
              JsonLdPropertyRenderer(
                propertyName: 'schema:offers',
                propertyValue: offersNode,
                isEditable: isEditable,
                activeLanguage: activeLanguage,
                onNodeTap: onNodeTap,
                onChanged: (updated) => _updateProperty('schema:offers', updated),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, JsonLdValue nameVal) {
    if (isEditable) {
      return TextFormField(
        initialValue: nameVal.displayString,
        decoration: InputDecoration(
          labelText: 'Product Name (${nameVal.language ?? activeLanguage})',
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          _updateProperty('schema:name', nameVal.copyWith(value: val));
        },
      );
    }

    return Text(
      nameVal.displayString,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescription(BuildContext context, JsonLdValue descVal) {
    if (isEditable) {
      return TextFormField(
        initialValue: descVal.displayString,
        maxLines: 2,
        decoration: InputDecoration(
          labelText: 'Product Description (${descVal.language ?? activeLanguage})',
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          _updateProperty('schema:description', descVal.copyWith(value: val));
        },
      );
    }

    return Text(descVal.displayString, style: Theme.of(context).textTheme.bodyMedium);
  }

  JsonLdValue _extractLocalizedValue(String key) {
    final raw = node.properties[key];
    if (raw is JsonLdValue) return raw;
    if (raw is JsonLdLocalizedSet) {
      return raw.resolve(activeLanguage) ??
          (raw.values.isNotEmpty ? raw.values.first : const JsonLdValue(value: ''));
    }
    return JsonLdValue(value: raw?.toString() ?? '');
  }

  String _extractStringValue(String key) {
    final raw = node.properties[key];
    if (raw is JsonLdValue) return raw.displayString;
    return raw?.toString() ?? '';
  }

  void _updateProperty(String key, dynamic val) {
    if (onChanged != null) {
      onChanged!(node.copyWithProperty(key, val));
    }
  }
}
