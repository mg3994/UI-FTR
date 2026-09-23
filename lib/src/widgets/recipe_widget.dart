import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';
import 'datatype_renderers.dart';

/// Custom widget for rendering and editing `schema:Recipe` nodes.
class RecipeWidget extends StatelessWidget {
  final JsonLdNode node;
  final bool isEditable;
  final String activeLanguage;
  final void Function(JsonLdNode updatedNode)? onChanged;
  final void Function(String id)? onNodeTap;

  const RecipeWidget({
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
    final prepTime = _extractStringValue('schema:prepTime');
    final cookTime = _extractStringValue('schema:cookTime');
    final yieldVal = _extractStringValue('schema:recipeYield');
    final imageVal = _extractStringValue('schema:image');
    final ingredients = node.properties['schema:recipeIngredient'];
    final instructions = node.properties['schema:recipeInstructions'];

    return Card(
      elevation: 4,
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
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restaurant_menu, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        node.primaryType,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                if (yieldVal.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.people, size: 14),
                    label: Text('Servings: $yieldVal'),
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
            if (prepTime.isNotEmpty || cookTime.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (prepTime.isNotEmpty) ...[
                    const Icon(Icons.timer, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text('Prep: $prepTime'),
                    const SizedBox(width: 16),
                  ],
                  if (cookTime.isNotEmpty) ...[
                    const Icon(Icons.microwave, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text('Cook: $cookTime'),
                  ],
                ],
              ),
            ],
            const Divider(height: 24),
            if (ingredients != null) ...[
              Text('Ingredients:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              JsonLdPropertyRenderer(
                propertyName: 'schema:recipeIngredient',
                propertyValue: ingredients,
                isEditable: isEditable,
                activeLanguage: activeLanguage,
                onNodeTap: onNodeTap,
                onChanged: (updated) => _updateProperty('schema:recipeIngredient', updated),
              ),
            ],
            if (instructions != null) ...[
              const SizedBox(height: 12),
              Text('Instructions:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              JsonLdPropertyRenderer(
                propertyName: 'schema:recipeInstructions',
                propertyValue: instructions,
                isEditable: isEditable,
                activeLanguage: activeLanguage,
                onNodeTap: onNodeTap,
                onChanged: (updated) => _updateProperty('schema:recipeInstructions', updated),
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
        decoration: InputDecoration(
          labelText: 'Recipe Name (${nameVal.language ?? activeLanguage})',
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
          labelText: 'Recipe Description (${descVal.language ?? activeLanguage})',
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
