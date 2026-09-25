import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import 'datatype_renderers.dart';

class KeywordInfo {
  final String keyword;
  final String title;
  final String category;
  final String explanation;
  final Map<String, dynamic> examplePayload;

  const KeywordInfo({
    required this.keyword,
    required this.title,
    required this.category,
    required this.explanation,
    required this.examplePayload,
  });
}

/// Interactive Widget Matrix providing an exhaustive guide and live demo
/// for EVERY JSON-LD keyword and its behavior in Flutter UI rendering.
class KeywordMatrixWidget extends StatefulWidget {
  final void Function(Map<String, dynamic> payload)? onLoadPayload;

  const KeywordMatrixWidget({
    super.key,
    this.onLoadPayload,
  });

  @override
  State<KeywordMatrixWidget> createState() => _KeywordMatrixWidgetState();
}

class _KeywordMatrixWidgetState extends State<KeywordMatrixWidget> {
  late KeywordInfo _selectedKeyword;

  static const List<KeywordInfo> keywordSpecs = [
    KeywordInfo(
      keyword: '@context',
      title: '@context (Term & IRI Mapping)',
      category: 'Context & Vocabularies',
      explanation:
          'Defines shorthand term mappings to full IRIs (e.g., "name" -> "https://schema.org/name") or references external schema context URLs.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Event',
        'name': 'Context Mapped Event'
      },
    ),
    KeywordInfo(
      keyword: '@id',
      title: '@id (Identity & Link Reference)',
      category: 'Identity & Graphing',
      explanation:
          'Specifies the node\'s unique IRI identity or relationship link target. Tapping @id links triggers stack navigation in JsonLdStore.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@id': 'https://example.com/item/101',
        '@type': 'Product',
        'name': 'Identified Product'
      },
    ),
    KeywordInfo(
      keyword: '@type',
      title: '@type (Schema Type Assignment)',
      category: 'Context & Vocabularies',
      explanation:
          'Assigns one or more schema types (IRI or term) to a node, which determines which custom widget builder in JsonLdWidgetRegistry is used.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': ['Recipe', 'Thing'],
        'name': 'Pasta Recipe'
      },
    ),
    KeywordInfo(
      keyword: '@value',
      title: '@value (Typed Literal & Plain Value)',
      category: 'Literals & Localization',
      explanation:
          'Represents a scalar value or typed literal inside a value object wrapper.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Product',
        'name': {'@value': 'Explicit Value Object'}
      },
    ),
    KeywordInfo(
      keyword: '@language',
      title: '@language (BCP-47 Language Tag)',
      category: 'Literals & Localization',
      explanation:
          'Specifies the natural language (e.g. "en", "es", "ar") for a localized string. JsonLdLocalizedSet matches and displays the best translation.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Event',
        'name': [
          {'@value': 'Hello World', '@language': 'en'},
          {'@value': 'Hola Mundo', '@language': 'es'}
        ]
      },
    ),
    KeywordInfo(
      keyword: '@direction',
      title: '@direction (Text Directionality: ltr/rtl)',
      category: 'Literals & Localization',
      explanation:
          'Specifies base text directionality ("ltr" or "rtl") for localized text, wrapping rendered text in Directionality widgets.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Event',
        'name': {'@value': 'مرحبا بالعالم', '@language': 'ar', '@direction': 'rtl'}
      },
    ),
    KeywordInfo(
      keyword: '@graph',
      title: '@graph (Multi-Node Container)',
      category: 'Identity & Graphing',
      explanation:
          'Contains an array of top-level or related nodes without forcing a single root node wrapper.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@graph': [
          {'@id': 'https://example.com/p/1', '@type': 'Person', 'name': 'Alice'},
          {'@id': 'https://example.com/p/2', '@type': 'Person', 'name': 'Bob'}
        ]
      },
    ),
    KeywordInfo(
      keyword: '@list',
      title: '@list (Ordered List Container)',
      category: 'Collections & Scoping',
      explanation:
          'Explicitly orders array items so order is strictly preserved during RDF conversion.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Recipe',
        'recipeIngredient': {
          '@list': ['Flour', 'Eggs', 'Milk', 'Sugar']
        }
      },
    ),
    KeywordInfo(
      keyword: '@set',
      title: '@set (Unordered Set Container)',
      category: 'Collections & Scoping',
      explanation:
          'Renders array items as an unordered collection set without enforcing duplicate removal constraints.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Place',
        'keywords': {
          '@set': ['Park', 'Nature', 'Outdoor']
        }
      },
    ),
    KeywordInfo(
      keyword: '@reverse',
      title: '@reverse (Inverse Relationship)',
      category: 'Identity & Graphing',
      explanation:
          'Defines incoming link relationships where another node points to this subject node.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@id': 'https://example.com/book/1',
        '@type': 'Book',
        'name': 'Flutter Deep Dive',
        '@reverse': {
          'author': {'@id': 'https://example.com/person/jules'}
        }
      },
    ),
    KeywordInfo(
      keyword: '@index',
      title: '@index (Scoped Map Indexing)',
      category: 'Collections & Scoping',
      explanation:
          'Associates a string index or tag with a value object for keyed array lookups.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Product',
        'name': {'@value': 'Indexed Laptop', '@index': 'sku-item-01'}
      },
    ),
    KeywordInfo(
      keyword: '@nest',
      title: '@nest (Nested Property Block)',
      category: 'Collections & Scoping',
      explanation:
          'Allows grouping properties under transparent organizational JSON keys while flattening them into the target schema.',
      examplePayload: {
        '@context': 'https://schema.org',
        '@type': 'Product',
        '@nest': {
          'name': 'Nested Product Name',
          'description': 'Flat schema property inside @nest block'
        }
      },
    ),
    KeywordInfo(
      keyword: '@base',
      title: '@base (Base IRI Resolution)',
      category: 'Context & Vocabularies',
      explanation:
          'Defines the base IRI used to resolve relative IRIs throughout the document.',
      examplePayload: {
        '@context': {'@base': 'https://api.example.com/v1/'},
        '@id': 'users/42',
        '@type': 'Person',
        'name': 'User 42'
      },
    ),
    KeywordInfo(
      keyword: '@vocab',
      title: '@vocab (Default Vocabulary Prefix)',
      category: 'Context & Vocabularies',
      explanation:
          'Sets the default vocabulary IRI prefix for all unmapped property terms.',
      examplePayload: {
        '@context': {'@vocab': 'https://schema.org/'},
        '@type': 'Person',
        'name': 'Default Vocab Person'
      },
    ),
    KeywordInfo(
      keyword: '@import',
      title: '@import (Context Import)',
      category: 'Context & Vocabularies',
      explanation:
          'Imports external context maps for Modular context composition.',
      examplePayload: {
        '@context': {'@import': 'https://schema.org'},
        '@type': 'Thing',
        'name': 'Imported Context Item'
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedKeyword = keywordSpecs.first;
  }

  @override
  Widget build(BuildContext context) {
    final parsedNode = JsonLdNode.fromJson(_selectedKeyword.examplePayload);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Keyword Selector List
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  color: Colors.indigo.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.key, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(
                        'JSON-LD Keywords (${keywordSpecs.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: keywordSpecs.length,
                    itemBuilder: (context, index) {
                      final item = keywordSpecs[index];
                      final isSelected = _selectedKeyword.keyword == item.keyword;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.indigo.shade100,
                        title: Text(
                          item.keyword,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.indigo.shade900 : Colors.black87,
                          ),
                        ),
                        subtitle: Text(item.title, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, size: 16),
                        onTap: () {
                          setState(() {
                            _selectedKeyword = item;
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

        // Right Column: Keyword Semantics Explanation & Live UI Output
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedKeyword.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                            ),
                            Chip(
                              avatar: const Icon(Icons.category, size: 14),
                              label: Text(_selectedKeyword.category),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedKeyword.explanation,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (widget.onLoadPayload != null) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow),
                            label: Text('Load ${_selectedKeyword.keyword} Payload into Main Renderer'),
                            onPressed: () {
                              widget.onLoadPayload!(_selectedKeyword.examplePayload);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Source JSON-LD Payload:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            const JsonEncoder.withIndent('  ')
                                .convert(_selectedKeyword.examplePayload),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.lightGreenAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Live Framework UI Output:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Divider(),
                        if (parsedNode.isGraph)
                          ...parsedNode.graphNodes.map((childNode) => Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Node: ${childNode.primaryType} (${childNode.id ?? "No ID"})'),
                                      ...childNode.properties.entries.map((e) => JsonLdPropertyRenderer(
                                            propertyName: e.key,
                                            propertyValue: e.value,
                                          )),
                                    ],
                                  ),
                                ),
                              ))
                        else
                          ...parsedNode.properties.entries.map((entry) {
                            return JsonLdPropertyRenderer(
                              propertyName: entry.key,
                              propertyValue: entry.value,
                            );
                          }),
                        if (parsedNode.reverseProperties.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text('Inverse Relations (@reverse):',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...parsedNode.reverseProperties.entries.map((e) => JsonLdPropertyRenderer(
                                propertyName: '@reverse:${e.key}',
                                propertyValue: e.value,
                              )),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
