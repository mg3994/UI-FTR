import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/models/json_ld_node.dart';
import 'src/models/json_ld_value.dart';
import 'src/state/json_ld_store.dart';
import 'src/utils/json_ld_presets.dart';
import 'src/utils/schema_code_generator.dart';
import 'src/utils/vocabulary_analyzer.dart';
import 'src/widgets/complex_event_widget.dart';
import 'src/widgets/datatype_renderers.dart';
import 'src/widgets/person_widget.dart';
import 'src/widgets/place_widget.dart';
import 'src/widgets/product_widget.dart';
import 'src/widgets/recipe_widget.dart';
import 'src/widgets/review_widget.dart';
import 'src/widgets/vocabulary_explorer_widget.dart';
import 'src/widgets/widget_registry.dart';

void main() {
  final registry = JsonLdWidgetRegistry();

  registry.register('schema:Event', (context, node,
      {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
    return ComplexEventWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });
  registry.register('Event', registry.lookup(['schema:Event'])!);

  registry.register('schema:Product', (context, node,
      {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
    return ProductWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });
  registry.register('Product', registry.lookup(['schema:Product'])!);

  registry.register('schema:Person', (context, node,
      {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
    return PersonWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });
  registry.register('Person', registry.lookup(['schema:Person'])!);

  registry.register('schema:Recipe', (context, node,
      {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
    return RecipeWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });
  registry.register('Recipe', registry.lookup(['schema:Recipe'])!);

  registry.register('schema:Place', (context, node,
      {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
    return PlaceWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });
  registry.register('Place', registry.lookup(['schema:Place'])!);

  registry.register('schema:Review', (context, node,
      {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
    return ReviewWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });
  registry.register('Review', registry.lookup(['schema:Review'])!);

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
  String _selectedPreset = 'Complex Event (Localized)';

  Map<String, SchemaClassTerm> _indexedClasses = {};
  Map<String, SchemaPropertyTerm> _indexedProperties = {};

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
        "@id": "https://schema.org/Recipe",
        "@type": "rdfs:Class",
        "rdfs:label": "Recipe",
        "rdfs:comment": "A recipe for food/drink."
      },
      {
        "@id": "https://schema.org/name",
        "@type": "rdf:Property",
        "rdfs:label": "name",
        "rdfs:comment": "The name of the item.",
        "schema:domainIncludes": [{"@id": "https://schema.org/Event"}, {"@id": "https://schema.org/Person"}, {"@id": "https://schema.org/Product"}]
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _store = JsonLdStore();
    _tabController = TabController(length: 4, vsync: this);
    _loadPreset(_selectedPreset);
    _indexVocabularySchema(_sampleSchemaOrgVocabPayload);
  }

  void _loadPreset(String presetKey) {
    if (JsonLdPresets.presets.containsKey(presetKey)) {
      final payload = JsonLdPresets.presets[presetKey]!;
      _loadSamplePayload(payload);
    }
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
                Tab(icon: Icon(Icons.dashboard), text: 'Instance Renderer'),
                Tab(icon: Icon(Icons.schema), text: 'Schema.org Explorer'),
                Tab(icon: Icon(Icons.code), text: 'Raw JSON Source'),
                Tab(icon: Icon(Icons.data_object), text: 'Dart Code Generator'),
              ],
            ),
            actions: [
              DropdownButton<String>(
                value: _selectedPreset,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.collections, color: Colors.indigo),
                items: JsonLdPresets.presets.keys.map((key) {
                  return DropdownMenuItem(value: key, child: Text(key));
                }).toList(),
                onChanged: (preset) {
                  if (preset != null) {
                    setState(() {
                      _selectedPreset = preset;
                    });
                    _loadPreset(preset);
                  }
                },
              ),
              const SizedBox(width: 8),
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
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy Rendered Node JSON',
                onPressed: () {
                  if (currentNode != null) {
                    final jsonStr = const JsonEncoder.withIndent('  ').convert(currentNode.toJson());
                    Clipboard.setData(ClipboardData(text: jsonStr));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied active JSON-LD node to clipboard!')),
                    );
                  }
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildInstanceRendererTab(state, currentNode),
              VocabularyExplorerWidget(
                classes: _indexedClasses,
                properties: _indexedProperties,
                onInstantiateClass: (template) {
                  _loadSamplePayload(template);
                  _tabController.animateTo(0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generated editable UI instance for ${template['@type']}'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
              _buildRawJsonTab(),
              _buildCodeGeneratorTab(currentNode),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.navigationStack.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Parent Node'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      _tabController.animateTo(1);
                    } else {
                      _store.loadDocument(decoded);
                      _tabController.animateTo(0);
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

  Widget _buildCodeGeneratorTab(JsonLdNode? currentNode) {
    if (currentNode == null) {
      return const Center(child: Text('No active node loaded to generate code for.'));
    }

    final dartCode = JsonLdSchemaCodeGenerator.generateDartClass(
      currentNode.primaryType,
      currentNode.properties,
    );

    final widgetCode = JsonLdSchemaCodeGenerator.generateWidgetRegistrationCode(
      currentNode.primaryType,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auto-Generated Dart Code for ${currentNode.primaryType}:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy Generated Code'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '$dartCode\n\n$widgetCode'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied Dart code to clipboard!')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                '$dartCode\n\n$widgetCode',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
