import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';
import 'datatype_renderers.dart';
import 'responsive_layout.dart';

/// Fully worked example widget for rendering & editing a complex `schema:Event` node,
/// featuring localized strings (@value/@language/@direction), nested nodes (Location, Performer),
/// image rendering, tappable URLs, and form editing.
class ComplexEventWidget extends StatelessWidget {
  final JsonLdNode node;
  final bool isEditable;
  final String activeLanguage;
  final void Function(JsonLdNode updatedNode)? onChanged;
  final void Function(String id)? onNodeTap;

  const ComplexEventWidget({
    super.key,
    required this.node,
    this.isEditable = false,
    this.activeLanguage = 'en',
    this.onChanged,
    this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract localized title / name
    final nameVal = _extractLocalizedValue('schema:name');
    final descVal = _extractLocalizedValue('schema:description');
    final startDate = _extractStringValue('schema:startDate');
    final endDate = _extractStringValue('schema:endDate');
    final locationNode = node.properties['schema:location'];
    final performerNode = node.properties['schema:performer'];
    final imageVal = _extractStringValue('schema:image');
    final urlVal = _extractStringValue('schema:url');

    return ResponsiveLayout(
      mobile: _buildMobileLayout(
        context,
        nameVal: nameVal,
        descVal: descVal,
        startDate: startDate,
        endDate: endDate,
        locationNode: locationNode,
        performerNode: performerNode,
        imageVal: imageVal,
        urlVal: urlVal,
      ),
      desktop: _buildDesktopLayout(
        context,
        nameVal: nameVal,
        descVal: descVal,
        startDate: startDate,
        endDate: endDate,
        locationNode: locationNode,
        performerNode: performerNode,
        imageVal: imageVal,
        urlVal: urlVal,
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, {
    required JsonLdValue nameVal,
    required JsonLdValue descVal,
    required String startDate,
    required String endDate,
    required dynamic locationNode,
    required dynamic performerNode,
    required String imageVal,
    required String urlVal,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBadge(context),
            const SizedBox(height: 12),
            _buildTitleField(context, nameVal),
            const SizedBox(height: 8),
            if (imageVal.isNotEmpty)
              JsonLdPropertyRenderer(
                propertyName: 'schema:image',
                propertyValue: JsonLdValue(value: imageVal),
                isEditable: false,
              ),
            const SizedBox(height: 8),
            _buildDescriptionField(context, descVal),
            const Divider(height: 24),
            _buildDateRow(context, startDate, endDate),
            const SizedBox(height: 12),
            if (urlVal.isNotEmpty)
              JsonLdPropertyRenderer(
                propertyName: 'schema:url',
                propertyValue: JsonLdValue(value: urlVal),
                onNodeTap: onNodeTap,
              ),
            const SizedBox(height: 12),
            if (locationNode != null)
              JsonLdPropertyRenderer(
                propertyName: 'schema:location',
                propertyValue: locationNode,
                isEditable: isEditable,
                activeLanguage: activeLanguage,
                onNodeTap: onNodeTap,
                onChanged: (updated) => _updateProperty('schema:location', updated),
              ),
            if (performerNode != null)
              JsonLdPropertyRenderer(
                propertyName: 'schema:performer',
                propertyValue: performerNode,
                isEditable: isEditable,
                activeLanguage: activeLanguage,
                onNodeTap: onNodeTap,
                onChanged: (updated) => _updateProperty('schema:performer', updated),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context, {
    required JsonLdValue nameVal,
    required JsonLdValue descVal,
    required String startDate,
    required String endDate,
    required dynamic locationNode,
    required dynamic performerNode,
    required String imageVal,
    required String urlVal,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderBadge(context),
                if (node.id != null)
                  Chip(
                    avatar: const Icon(Icons.fingerprint, size: 16),
                    label: Text('ID: ${node.id}'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(context, nameVal),
                      const SizedBox(height: 12),
                      _buildDescriptionField(context, descVal),
                      const SizedBox(height: 16),
                      _buildDateRow(context, startDate, endDate),
                      if (urlVal.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        JsonLdPropertyRenderer(
                          propertyName: 'schema:url',
                          propertyValue: JsonLdValue(value: urlVal),
                          onNodeTap: onNodeTap,
                        ),
                      ],
                    ],
                  ),
                ),
                if (imageVal.isNotEmpty) const SizedBox(width: 24),
                if (imageVal.isNotEmpty)
                  Expanded(
                    flex: 1,
                    child: JsonLdPropertyRenderer(
                      propertyName: 'schema:image',
                      propertyValue: JsonLdValue(value: imageVal),
                      isEditable: false,
                    ),
                  ),
              ],
            ),
            const Divider(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (locationNode != null)
                  Expanded(
                    child: JsonLdPropertyRenderer(
                      propertyName: 'schema:location',
                      propertyValue: locationNode,
                      isEditable: isEditable,
                      activeLanguage: activeLanguage,
                      onNodeTap: onNodeTap,
                      onChanged: (updated) => _updateProperty('schema:location', updated),
                    ),
                  ),
                if (locationNode != null && performerNode != null)
                  const SizedBox(width: 16),
                if (performerNode != null)
                  Expanded(
                    child: JsonLdPropertyRenderer(
                      propertyName: 'schema:performer',
                      propertyValue: performerNode,
                      isEditable: isEditable,
                      activeLanguage: activeLanguage,
                      onNodeTap: onNodeTap,
                      onChanged: (updated) => _updateProperty('schema:performer', updated),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Text(
            node.primaryType,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(BuildContext context, JsonLdValue nameVal) {
    if (isEditable) {
      return TextFormField(
        initialValue: nameVal.displayString,
        decoration: InputDecoration(
          labelText: 'Event Name (${nameVal.language ?? activeLanguage})',
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          _updateProperty('schema:name', nameVal.copyWith(value: val));
        },
      );
    }

    return Directionality(
      textDirection: nameVal.direction == TextDirectionality.rtl
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Text(
        nameVal.displayString,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, JsonLdValue descVal) {
    if (isEditable) {
      return TextFormField(
        initialValue: descVal.displayString,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Description (${descVal.language ?? activeLanguage})',
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          _updateProperty('schema:description', descVal.copyWith(value: val));
        },
      );
    }

    return Directionality(
      textDirection: descVal.direction == TextDirectionality.rtl
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Text(
        descVal.displayString,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, String startDate, String endDate) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text(
          startDate.isNotEmpty ? startDate : 'Date TBD',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (endDate.isNotEmpty) ...[
          const Text(' - '),
          Text(
            endDate,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ],
    );
  }

  JsonLdValue _extractLocalizedValue(String propertyKey) {
    final raw = node.properties[propertyKey];
    if (raw is JsonLdValue) return raw;
    if (raw is JsonLdLocalizedSet) {
      return raw.resolve(activeLanguage) ??
          (raw.values.isNotEmpty ? raw.values.first : const JsonLdValue(value: ''));
    }
    return JsonLdValue(value: raw?.toString() ?? '');
  }

  String _extractStringValue(String propertyKey) {
    final raw = node.properties[propertyKey];
    if (raw is JsonLdValue) return raw.displayString;
    return raw?.toString() ?? '';
  }

  void _updateProperty(String propertyKey, dynamic newValue) {
    if (onChanged != null) {
      final updatedNode = node.copyWithProperty(propertyKey, newValue);
      onChanged!(updatedNode);
    }
  }
}
