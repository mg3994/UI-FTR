import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';
import 'datatype_renderers.dart';

/// Custom widget for rendering and editing `schema:Review` nodes.
class ReviewWidget extends StatelessWidget {
  final JsonLdNode node;
  final bool isEditable;
  final String activeLanguage;
  final void Function(JsonLdNode updatedNode)? onChanged;
  final void Function(String id)? onNodeTap;

  const ReviewWidget({
    super.key,
    required this.node,
    this.isEditable = false,
    this.activeLanguage = 'en',
    this.onChanged,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final bodyVal = _extractLocalizedValue('schema:reviewBody');
    final ratingNode = node.properties['schema:reviewRating'];
    final authorNode = node.properties['schema:author'];
    final itemReviewedNode = node.properties['schema:itemReviewed'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.rate_review, size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        node.primaryType,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
                if (ratingNode != null)
                  JsonLdPropertyRenderer(
                    propertyName: 'schema:reviewRating',
                    propertyValue: ratingNode,
                    isEditable: isEditable,
                    activeLanguage: activeLanguage,
                    onNodeTap: onNodeTap,
                    onChanged: (updated) => _updateProperty('schema:reviewRating', updated),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildReviewBody(context, bodyVal),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (authorNode != null)
                  Expanded(
                    child: JsonLdPropertyRenderer(
                      propertyName: 'schema:author',
                      propertyValue: authorNode,
                      isEditable: isEditable,
                      activeLanguage: activeLanguage,
                      onNodeTap: onNodeTap,
                      onChanged: (updated) => _updateProperty('schema:author', updated),
                    ),
                  ),
                if (authorNode != null && itemReviewedNode != null)
                  const SizedBox(width: 16),
                if (itemReviewedNode != null)
                  Expanded(
                    child: JsonLdPropertyRenderer(
                      propertyName: 'schema:itemReviewed',
                      propertyValue: itemReviewedNode,
                      isEditable: isEditable,
                      activeLanguage: activeLanguage,
                      onNodeTap: onNodeTap,
                      onChanged: (updated) => _updateProperty('schema:itemReviewed', updated),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewBody(BuildContext context, JsonLdValue bodyVal) {
    if (isEditable) {
      return TextFormField(
        initialValue: bodyVal.displayString,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Review Body',
          border: OutlineInputBorder(),
        ),
        onChanged: (val) {
          _updateProperty('schema:reviewBody', bodyVal.copyWith(value: val));
        },
      );
    }

    return Text(
      '"${bodyVal.displayString}"',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
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

  void _updateProperty(String key, dynamic val) {
    if (onChanged != null) {
      onChanged!(node.copyWithProperty(key, val));
    }
  }
}
