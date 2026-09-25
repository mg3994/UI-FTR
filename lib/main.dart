import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'json_ld_framework.dart';

void main() {
  // Initialize standard Schema.org widgets via modular plugin
  SchemaOrgCorePlugin().register(
    JsonLdWidgetRegistry(),
    JsonLdPropertyRegistry(),
  );

  runApp(
    JsonLdApp(
      initialDocument: JsonLdPresets.presets['Complex Event (Localized)'],
      theme: JsonLdTheme.light,
      initialLanguage: 'en',
      child: const JsonLdArchitectureApp(),
    ),
  );
}

class JsonLdArchitectureApp extends StatelessWidget {
  const JsonLdArchitectureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JSON-LD Architecture Framework',
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
    _tabController = TabController(length: 6, vsync: this);
    _indexVocabularySchema(_sampleSchemaOrgVocabPayload);
  }

  void _loadPreset(BuildContext context, String presetKey) {
    if (JsonLdPresets.presets.containsKey(presetKey)) {
      final payload = JsonLdPresets.presets[presetKey]!;
      _loadSamplePayload(context, payload);
    }
  }

  void _loadSamplePayload(BuildContext context, Map<String, dynamic> payload) {
    final scope = JsonLdScope.of(context);
    scope?.store.loadDocument(payload);
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
    _tabController.dispose();
    _rawJsonTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = JsonLdScope.of(context);
    final store = scope?.store;

    if (store == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ValueListenableBuilder<JsonLdState>(
      valueListenable: store,
      builder: (context, state, child) {
        final currentNode = state.currentNode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter JSON-LD Architecture Framework'),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Instance Renderer'),
                Tab(icon: Icon(Icons.schema), text: 'Schema.org Explorer'),
                Tab(icon: Icon(Icons.code), text: 'Raw JSON Source'),
                Tab(icon: Icon(Icons.data_object), text: 'Dart Code Generator'),
                Tab(icon: Icon(Icons.hub), text: 'Graph & RDF Triples'),
                Tab(icon: Icon(Icons.key), text: 'JSON-LD Keywords & Semantics'),
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
                    _loadPreset(context, preset);
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
              _buildInstanceRendererTab(store, state, currentNode),
              VocabularyExplorerWidget(
                classes: _indexedClasses,
                properties: _indexedProperties,
                onInstantiateClass: (template) {
                  _loadSamplePayload(context, template);
                  _tabController.animateTo(0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Generated editable UI instance for ${template['@type']}'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
              _buildRawJsonTab(context, store),
              _buildCodeGeneratorTab(currentNode),
              currentNode != null
                  ? GraphInspectorWidget(node: currentNode)
                  : const Center(child: Text('No active graph node loaded.')),
              KeywordMatrixWidget(
                onLoadPayload: (payload) {
                  _loadSamplePayload(context, payload);
                  _tabController.animateTo(0);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loaded keyword demo payload into Main Renderer!')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstanceRendererTab(JsonLdStore store, JsonLdState state, JsonLdNode? currentNode) {
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
                onPressed: () => store.popNavigation(),
              ),
            ),
          if (currentNode != null)
            _renderNode(context, store, currentNode)
          else
            const Text('No content available.'),
        ],
      ),
    );
  }

  Widget _renderNode(BuildContext context, JsonLdStore store, JsonLdNode node) {
    if (node.isGraph) {
      return Column(
        children: node.graphNodes.map((childNode) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _renderSingleNode(context, store, childNode),
          );
        }).toList(),
      );
    }
    return _renderSingleNode(context, store, node);
  }

  Widget _renderSingleNode(BuildContext context, JsonLdStore store, JsonLdNode node) {
    final builder = JsonLdWidgetRegistry().lookup(node.types);
    if (builder != null) {
      return builder(
        context,
        node,
        isEditable: _isEditable,
        activeLanguage: _activeLanguage,
        onChanged: (updated) => store.updateNode(updated),
        onNodeTap: (id) => store.navigateToId(id),
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
                onNodeTap: (id) => store.navigateToId(id),
                onChanged: (updatedVal) {
                  final updatedNode = node.copyWithProperty(entry.key, updatedVal);
                  store.updateNode(updatedNode);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRawJsonTab(BuildContext context, JsonLdStore store) {
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
                      store.loadDocument(decoded);
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
