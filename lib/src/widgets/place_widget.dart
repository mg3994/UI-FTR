import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';
import 'datatype_renderers.dart';

/// Custom widget for rendering and editing `schema:Place` / `schema:PostalAddress` nodes.
class PlaceWidget extends StatelessWidget {
  final JsonLdNode node;
  final bool isEditable;
  final String activeLanguage;
  final void Function(JsonLdNode updatedNode)? onChanged;
  final void Function(String id)? onNodeTap;

  const PlaceWidget({
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
    final addressVal = _extractStringValue('schema:address');
    final telephoneVal = _extractStringValue('schema:telephone');
    final geoNode = node.properties['schema:geo'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.place, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        node.primaryType,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTitle(context, nameVal),
            if (addressVal.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(addressVal)),
                ],
              ),
            ],
            if (telephoneVal.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(telephoneVal),
                ],
              ),
            ],
            if (geoNode != null) ...[
              const Divider(height: 20),
              JsonLdPropertyRenderer(
                propertyName: 'schema:geo',
                propertyValue: geoNode,
                isEditable: isEditable,
                activeLanguage: activeLanguage,
                onNodeTap: onNodeTap,
                onChanged: (updated) => _updateProperty('schema:geo', updated),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, JsonLdValue nameVal) {
    if (isEditable) {
      return TextFormField(
        initialValue: nameVal.displayString,
        decoration: const InputDecoration(
          labelText: 'Place Name',
          border: OutlineInputBorder(),
        ),
        onChanged: (val) {
          _updateProperty('schema:name', nameVal.copyWith(value: val));
        },
      );
    }

    return Text(
      nameVal.displayString,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
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
