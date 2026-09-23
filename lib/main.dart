import 'package:flutter/material.dart';
import 'src/models/json_ld_node.dart';
import 'src/models/json_ld_value.dart';
import 'src/state/json_ld_store.dart';
import 'src/utils/vocabulary_analyzer.dart';
import 'src/widgets/complex_event_widget.dart';
import 'src/widgets/datatype_renderers.dart';
import 'src/widgets/widget_registry.dart';

void main() {
  // Register custom complex widget for schema:Event or Event
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

class _JsonLdHomePageState extends State<JsonLdHomePage> {
  late final JsonLdStore _store;
  bool _isEditable = false;
  String _activeLanguage = 'en';

  // Sample Complex JSON-LD document with localization, graph, and @id references
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
        "schema:telephone": "+1-408-555-0199",
        "schema:maximumAttendeeCapacity": 5000
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

  @override
  void initState() {
    super.initState();
    _store = JsonLdStore();
    _store.loadDocument(_sampleJsonLdPayload);
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JsonLdState>(
      valueListenable: _store,
      builder: (context, state, child) {
        final currentNode = state.currentNode;
        final docType = VocabularyAnalyzer.detectDocumentType(_sampleJsonLdPayload);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.navigationStack.isNotEmpty
                  ? 'Detail View'
                  : 'JSON-LD Architecture Demo',
            ),
            leading: state.navigationStack.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _store.popNavigation(),
                  )
                : null,
            actions: [
              // Language Switcher Dropdown
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
              // Edit Mode Switch
              Row(
                children: [
                  const Text('Edit'),
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
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
                  ? Center(child: Text('Error: ${state.error}'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAlignment.start,
                        children: [
                          _buildDocTypeBanner(docType),
                          const SizedBox(height: 12),
                          if (currentNode != null)
                            _renderNode(context, currentNode)
                          else
                            const Text('No content available.'),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildDocTypeBanner(JsonLdDocumentType docType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: docType == JsonLdDocumentType.vocabulary
            ? Colors.orange.shade100
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: docType == JsonLdDocumentType.vocabulary
              ? Colors.orange
              : Colors.blue,
        ),
      ),
      child: Row(
        children: [
          Icon(
            docType == JsonLdDocumentType.vocabulary
                ? Icons.schema
                : Icons.data_object,
            color: docType == JsonLdDocumentType.vocabulary
                ? Colors.orange.shade800
                : Colors.blue.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              docType == JsonLdDocumentType.vocabulary
                  ? 'Detected Schema Vocabulary Document (rdfs:Class / rdf:Property definition source)'
                  : 'Detected JSON-LD Instance Document payload',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: docType == JsonLdDocumentType.vocabulary
                    ? Colors.orange.shade900
                    : Colors.blue.shade900,
              ),
            ),
          ),
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

    // Generic fallback renderer for unknown or generic nodes
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.start,
          children: [
            Text(
              'Node Type: ${node.primaryType}',
              style: Theme.of(context).textTheme.titleMedium,
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
}
