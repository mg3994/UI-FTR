import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';
import 'datatype_renderers.dart';

/// Custom widget tailored for rendering and editing `schema:Person` / `schema:Organization` nodes.
class PersonWidget extends StatelessWidget {
  final JsonLdNode node;
  final bool isEditable;
  final String activeLanguage;
  final void Function(JsonLdNode updatedNode)? onChanged;
  final void Function(String id)? onNodeTap;

  const PersonWidget({
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
    final jobTitle = _extractStringValue('schema:jobTitle');
    final worksFor = _extractStringValue('schema:worksFor');
    final imageVal = _extractStringValue('schema:image');
    final email = _extractStringValue('schema:email');
    final sameAs = node.properties['schema:sameAs'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo.shade100,
                backgroundImage: imageVal.isNotEmpty ? NetworkImage(imageVal) : null,
                child: imageVal.isEmpty
                    ? Text(
                        nameVal.displayString.isNotEmpty ? nameVal.displayString[0] : 'P',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      )
                    : null,
              ),
              title: isEditable
                  ? TextFormField(
                      initialValue: nameVal.displayString,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onChanged: (val) {
                        _updateProperty('schema:name', nameVal.copyWith(value: val));
                      },
                    )
                  : Text(
                      nameVal.displayString,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
              subtitle: Text(
                jobTitle.isNotEmpty ? jobTitle : node.primaryType,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            if (worksFor.isNotEmpty || email.isNotEmpty) const Divider(),
            if (worksFor.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.business, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text('Works at: $worksFor'),
                  ],
                ),
              ),
            if (email.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(email),
                  ],
                ),
              ),
            if (sameAs != null) ...[
              const Divider(),
              JsonLdPropertyRenderer(
                propertyName: 'schema:sameAs',
                propertyValue: sameAs,
                onNodeTap: onNodeTap,
              ),
            ],
          ],
        ),
      ),
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
