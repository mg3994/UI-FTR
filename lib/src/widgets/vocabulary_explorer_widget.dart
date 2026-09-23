import 'package:flutter/material.dart';
import '../utils/vocabulary_analyzer.dart';

/// Explorer widget allowing users to search, browse, inspect, and generate editable
/// JSON-LD instance payloads from full vocabulary files (like schemaorg-current-https.jsonld).
class VocabularyExplorerWidget extends StatefulWidget {
  final Map<String, SchemaClassTerm> classes;
  final Map<String, SchemaPropertyTerm> properties;
  final void Function(Map<String, dynamic> generatedTemplate) onInstantiateClass;

  const VocabularyExplorerWidget({
    super.key,
    required this.classes,
    required this.properties,
    required this.onInstantiateClass,
  });

  @override
  State<VocabularyExplorerWidget> createState() => _VocabularyExplorerWidgetState();
}

class _VocabularyExplorerWidgetState extends State<VocabularyExplorerWidget> {
  String _searchQuery = '';
  SchemaClassTerm? _selectedClass;

  @override
  Widget build(BuildContext context) {
    final filteredClasses = widget.classes.values.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return c.label.toLowerCase().contains(q) || c.id.toLowerCase().contains(q);
    }).toList();

    return Row(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        // Class Search & Selector List
        Expanded(
          flex: 1,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Schema.org Classes',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Found Classes (${filteredClasses.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Chip(label: Text('Props: ${widget.properties.length}')),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredClasses.length,
                    itemBuilder: (context, index) {
                      final item = filteredClasses[index];
                      final isSelected = _selectedClass?.id == item.id;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.indigo.shade50,
                        title: Text(
                          item.label.isNotEmpty ? item.label : item.id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          item.comment,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 16),
                        onTap: () {
                          setState(() {
                            _selectedClass = item;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected Class Detail View & Instance Generator
        Expanded(
          flex: 2,
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.all(8.0),
            child: _selectedClass == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schema_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Select a Schema.org class on the left to inspect properties and generate instance UI.'),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedClass!.label.isNotEmpty
                                    ? _selectedClass!.label
                                    : _selectedClass!.id,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_box),
                              label: const Text('Instantiate & Edit Widget'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                final template = VocabularyAnalyzer.generateInstanceTemplate(
                                  _selectedClass!.id,
                                  widget.properties,
                                );
                                widget.onInstantiateClass(template);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SelectableText('IRI: ${_selectedClass!.id}'),
                        if (_selectedClass!.subClassOf.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: _selectedClass!.subClassOf.map((parent) {
                              return Chip(
                                avatar: const Icon(Icons.subdirectory_arrow_right, size: 14),
                                label: Text('subClassOf: ${parent.split('/').last}'),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          _selectedClass!.comment.isNotEmpty
                              ? _selectedClass!.comment
                              : 'No description provided.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Associated Properties for Class:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _buildAssociatedPropertiesList(_selectedClass!),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssociatedPropertiesList(SchemaClassTerm classTerm) {
    final matchingProps = widget.properties.values.where((p) {
      return p.domainIncludes.any((d) => d == classTerm.id || d.endsWith(classTerm.label));
    }).toList();

    if (matchingProps.isEmpty) {
      return const Center(child: Text('No direct domain properties indexed.'));
    }

    return ListView.builder(
      itemCount: matchingProps.length,
      itemBuilder: (context, index) {
        final prop = matchingProps[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            title: Text(
              prop.label.isNotEmpty ? prop.label : prop.id,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                if (prop.comment.isNotEmpty) Text(prop.comment),
                const SizedBox(height: 4),
                if (prop.rangeIncludes.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: prop.rangeIncludes.map((r) {
                      return Chip(
                        label: Text(
                          'Expected Range: ${r.split('/').last}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
