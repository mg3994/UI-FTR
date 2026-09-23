import 'dart:convert';
import 'package:flutter/material.dart';
import 'src/models/json_ld_node.dart';
import 'src/models/json_ld_value.dart';
import 'src/state/json_ld_store.dart';
import 'src/utils/vocabulary_analyzer.dart';
import 'src/widgets/complex_event_widget.dart';
import 'src/widgets/datatype_renderers.dart';
import 'src/widgets/vocabulary_explorer_widget.dart';
import 'src/widgets/widget_registry.dart';

void main() {
  final registry = JsonLdWidgetRegistry();
  registry.register('schema:Event', (context, node,
      {required isEditable,
      required activeLanguage,
      onChanged,
      onNodeTap}) {
    return ComplexEventWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });
  registry.register('Event', registry.lookup(['schema:Event'])!);

  runApp(const JsonLdArchitectureApp());
}

class JsonLdArchitectureApp extends StatelessWidget {
  const JsonLdArchitectureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JSON-LD Architecture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const JsonLdHomePage(),
    );
  }
}

class JsonLdHomePage extends StatefulWidget {
  const JsonLdHomePage({super.key});

  @override
  State<JsonLdHomePage> createState() => _JsonLdHomePageState();
}

class _JsonLdHomePageState extends State<JsonLdHomePage> with SingleTickerProviderStateMixin {
  late final JsonLdStore _store;
  late final TabController _tabController;
  final TextEditingController _rawJsonTextController = TextEditingController();

  bool _isEditable = false;
  String _activeLanguage = 'en';

  Map<String, SchemaClassTerm> _indexedClasses = {};
  Map<String, SchemaPropertyTerm> _indexedProperties = {};

  static const Map<String, dynamic> _sampleJsonLdPayload = {
    "@context": {
      "schema": "https://schema.org/",
      "name": "schema:name",
      "description": "schema:description",
      "startDate": "schema:startDate",
      "location": "schema:location",
      "performer": "schema:performer"
    },
    "@graph": [
      {
        "@id": "https://example.com/events/flutter-con-2026",
        "@type": "schema:Event",
        "schema:name": [
          {"@value": "Flutter Global Conference 2026", "@language": "en"},
          {"@value": "Conferencia Global de Flutter 2026", "@language": "es"},
          {"@value": "مؤتمر فلاتر العالمي 2026", "@language": "ar", "@direction": "rtl"}
        ],
        "schema:description": [
          {
            "@value": "Join developers worldwide for the ultimate Flutter architecture summit.",
            "@language": "en"
          },
          {
            "@value": "Únete a desarrolladores de todo el mundo para la cumbre de arquitectura Flutter.",
            "@language": "es"
          },
          {
            "@value": "انضم إلى المطورين من جميع أنحاء العالم في قمة هندسة برمجيات فلاتر.",
            "@language": "ar",
            "@direction": "rtl"
          }
        ],
        "schema:startDate": "2026-10-15T09:00:00Z",
        "schema:endDate": "2026-10-17T18:00:00Z",
        "schema:image": "https://picsum.photos/600/300",
        "schema:url": "https://flutter.dev",
        "schema:location": {
          "@id": "https://example.com/places/convention-center",
          "@type": "schema:Place",
          "schema:name": "Silicon Valley Convention Center",
          "schema:address": "San Jose, CA, USA"
        },
        "schema:performer": {
          "@id": "https://example.com/people/jules-architect",
          "@type": "schema:Person",
          "schema:name": "Jules - UI/UX Architect",
          "schema:jobTitle": "Principal Engineer"
        }
      },
      {
        "@id": "https://example.com/places/convention-center",
        "@type": "schema:Place",
        "schema:name": "Silicon Valley Convention Center (Detail Page)",
        "schema:address": "150 San Carlos St, San Jose, CA 95113",
        "schema:telephone": "+1-408-555-0199"
      },
      {
        "@id": "https://example.com/people/jules-architect",
        "@type": "schema:Person",
        "schema:name": "Jules - UI/UX Architect (Detail Page)",
        "schema:jobTitle": "Senior Software Architect",
        "schema:worksFor": "Global Tech Corp",
        "schema:sameAs": "https://github.com"
      }
    ]
  };

  static const Map<String, dynamic> _sampleSchemaOrgVocabPayload = {
    "@context": {
      "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
      "rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "schema": "https://schema.org/"
    },
    "@graph": [
      {
        "@id": "https://schema.org/Event",
        "@type": "rdfs:Class",
        "rdfs:label": "Event",
        "rdfs:comment": "An event happening at a certain time and location, such as a concert or lecture."
      },
      {
        "@id": "https://schema.org/Person",
        "@type": "rdfs:Class",
        "rdfs:label": "Person",
        "rdfs:comment": "A person (alive, dead, undead, or fictional)."
      },
      {
        "@id": "https://schema.org/Product",
        "@type": "rdfs:Class",
        "rdfs:label": "Product",
        "rdfs:comment": "Any offered product or service."
      },
      {
        "@id": "https://schema.org/name",
        "@type": "rdf:Property",
        "rdfs:label": "name",
        "rdfs:comment": "The name of the item.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Event"}, {"@id": "https://schema.org/Person"}, {"@id": "https://schema.org/Product"}],
        "schema:rangeIncludes": [{"@id": "https://schema.org/Text"}]
      },
      {
        "@id": "https://schema.org/startDate",
        "@type": "rdf:Property",
        "rdfs:label": "startDate",
        "rdfs:comment": "The start date and time of the item.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Event"}],
        "schema:rangeIncludes": [{"@id": "https://schema.org/Date"}, {"@id": "https://schema.org/DateTime"}]
      },
      {
        "@id": "https://schema.org/performer",
        "@type": "rdf:Property",
        "rdfs:label": "performer",
        "rdfs:comment": "A performer in an event.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Event"}],
        "schema:rangeIncludes": [{"@id": "https://schema.org/Person"}]
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _store = JsonLdStore();
    _tabController = TabController(length: 3, vsync: this);
    _loadSamplePayload(_sampleJsonLdPayload);
    _indexVocabularySchema(_sampleSchemaOrgVocabPayload);
  }

  void _loadSamplePayload(Map<String, dynamic> payload) {
    _store.loadDocument(payload);
    _rawJsonTextController.text = const JsonEncoder.withIndent('  ').convert(payload);
  }

  void _indexVocabularySchema(dynamic vocabPayload) {
    final parsed = VocabularyAnalyzer.parseVocabularySchema(vocabPayload);
    setState(() {
      _indexedClasses = parsed['classes'] as Map<String, SchemaClassTerm>;
      _indexedProperties = parsed['properties'] as Map<String, SchemaPropertyTerm>;
    });
  }

  @override
  void dispose() {
    _store.dispose();
    _tabController.dispose();
    _rawJsonTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JsonLdState>(
      valueListenable: _store,
      builder: (context, state, child) {
        final currentNode = state.currentNode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter JSON-LD Architecture & Schema.org Platform'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Instance Renderer/Editor'),
                Tab(icon: Icon(Icons.schema), text: 'Schema.org Vocabulary Explorer'),
                Tab(icon: Icon(Icons.code), text: 'Raw JSON-LD / Import'),
              ],
            ),
            actions: [
              DropdownButton<String>(
                value: _activeLanguage,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.language, color: Colors.indigo),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English (en)')),
                  DropdownMenuItem(value: 'es', child: Text('Español (es)')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية (ar - RTL)')),
                ],
                onChanged: (lang) {
                  if (lang != null) {
                    setState(() {
                      _activeLanguage = lang;
                    });
                  }
                },
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  const Text('Edit Mode'),
                  Switch(
                    value: _isEditable,
                    onChanged: (val) {
                      setState(() {
                        _isEditable = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Instance Data UI Renderer / Editor
              _buildInstanceRendererTab(state, currentNode),

              // Tab 2: Schema Vocabulary Explorer
              VocabularyExplorerWidget(
                classes: _indexedClasses,
                properties: _indexedProperties,
                onInstantiateClass: (template) {
                  _loadSamplePayload(template);
                  _tabController.animateTo(0); // Switch to Instance Renderer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generated editable UI instance for ${template['@type']}'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),

              // Tab 3: Raw JSON-LD Import / Inspection
              _buildRawJsonTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstanceRendererTab(JsonLdState state, JsonLdNode? currentNode) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAlignment.start,
        children: [
          if (state.navigationStack.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Root Node'),
                onPressed: () => _store.popNavigation(),
              ),
            ),
          if (currentNode != null)
            _renderNode(context, currentNode)
          else
            const Text('No content available.'),
        ],
      ),
    );
  }

  Widget _renderNode(BuildContext context, JsonLdNode node) {
    if (node.isGraph) {
      return Column(
        children: node.graphNodes.map((childNode) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _renderSingleNode(context, childNode),
          );
        }).toList(),
      );
    }
    return _renderSingleNode(context, node);
  }

  Widget _renderSingleNode(BuildContext context, JsonLdNode node) {
    final builder = JsonLdWidgetRegistry().lookup(node.types);
    if (builder != null) {
      return builder(
        context,
        node,
        isEditable: _isEditable,
        activeLanguage: _activeLanguage,
        onChanged: (updated) => _store.updateNode(updated),
        onNodeTap: (id) => _store.navigateToId(id),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Text(
              'Node Type: ${node.primaryType}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (node.id != null) Text('ID: ${node.id}'),
            const Divider(),
            ...node.properties.entries.map((entry) {
              return JsonLdPropertyRenderer(
                propertyName: entry.key,
                propertyValue: entry.value,
                isEditable: _isEditable,
                activeLanguage: _activeLanguage,
                onNodeTap: (id) => _store.navigateToId(id),
                onChanged: (updatedVal) {
                  final updatedNode = node.copyWithProperty(entry.key, updatedVal);
                  _store.updateNode(updatedNode);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRawJsonTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAlignment: CrossAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'JSON-LD Source / Raw Editor:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Parse & Render Payload'),
                onPressed: () {
                  try {
                    final decoded = json.decode(_rawJsonTextController.text);
                    final docType = VocabularyAnalyzer.detectDocumentType(decoded);
                    if (docType == JsonLdDocumentType.vocabulary) {
                      _indexVocabularySchema(decoded);
                      _tabController.animateTo(1); // Move to Schema Explorer
                    } else {
                      _store.loadDocument(decoded);
                      _tabController.animateTo(0); // Move to Instance Renderer
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid JSON-LD Syntax: $e')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _rawJsonTextController,
              maxLines: null,
              expands: true,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste any JSON-LD document or vocabulary file here...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
