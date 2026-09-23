# Flutter JSON-LD Architecture & Framework Platform

A highly flexible, extensible, and reusable Flutter UI framework for rendering, editing, navigating, and exploring **ANY** JSON-LD document conforming to [Schema.org](https://schema.org) or standard W3C JSON-LD specifications.

---

## Key Features

- **Full JSON-LD Specification Support**:
  - `@context`: Inlined objects, remote IRIs, and contextual property term expansion.
  - `@graph`: Renders multi-node documents with top-level graphs.
  - `@id`: Node identity linking & interactive stack navigation to detail views.
  - `@type`: Single string or array driven widget builder lookups.
  - `@value`, `@language`, `@direction`: Complete localization support including BCP-47 language tag resolution and bidirectional text (`ltr` / `rtl`).
  * `@list` / `@set`: Ordered and unordered collection rendering.
  * `@reverse`, `@index`, `@nest`: Full handling for inverse relationships, scoped indices, and nested property blocks.

- **Dynamic Pluggable Registries**:
  - `JsonLdWidgetRegistry`: Map custom `@type` builders without altering core logic.
  - `JsonLdPropertyRegistry`: Property-level UI interceptors for custom widgets (e.g. Star Ratings, Price Chips, Maps).

- **State Management**:
  - `JsonLdStore`: Reactive store (`ValueNotifier<JsonLdState>`) managing node loading, caching by `@id`, editing updates, and stack navigation.

- **Schema.org Vocabulary Explorer**:
  - `VocabularyAnalyzer`: Automatically detects schema vocabulary files (`rdfs:Class`, `rdf:Property`, `schemaorg-current-https.jsonld`) vs. instance data.
  - Interactive class search and instance template generator.

- **Automated Deployment**:
  - Included GitHub Actions workflow (`.github/workflows/deploy.yml`) for Flutter Web GitHub Pages deployment.

---

## Quick Start Example

```dart
import 'package:flutter/material.dart';
import 'package:app/json_ld_framework.dart';

void main() {
  // 1. Register a custom widget builder for a schema type
  final widgetRegistry = JsonLdWidgetRegistry();
  widgetRegistry.register('schema:Event', (context, node, {
    required isEditable,
    required activeLanguage,
    onChanged,
    onNodeTap,
  }) {
    return ComplexEventWidget(
      node: node,
      isEditable: isEditable,
      activeLanguage: activeLanguage,
      onChanged: onChanged,
      onNodeTap: onNodeTap,
    );
  });

  // 2. Register custom property interceptors (e.g., star ratings)
  final propertyRegistry = JsonLdPropertyRegistry();
  propertyRegistry.register('schema:ratingValue', (context, name, value, {
    required isEditable,
    required activeLanguage,
    onChanged,
    onNodeTap,
  }) {
    return CustomPropertyWidgets.buildRatingWidget(
      context, name, value, isEditable: isEditable, onChanged: onChanged
    );
  });

  runApp(const MaterialApp(home: JsonLdHomePage()));
}
```

---

## Architecture Overview

```
lib/
├── json_ld_framework.dart        # Public Framework Package Exports
└── src/
    ├── models/                   # JSON-LD Core Data Models
    │   ├── json_ld_node.dart     # Node (@id, @type, @graph, @nest, @reverse)
    │   └── json_ld_value.dart    # Localized Value (@value, @language, @direction)
    ├── state/
    │   └── json_ld_store.dart    # Reactive Store & Navigation Controller
    ├── theme/
    │   └── json_ld_theme.dart    # Custom Framework Styling & Layout Density
    ├── utils/
    │   ├── json_ld_presets.dart  # Pre-packaged Sample JSON-LD Payloads
    │   └── vocabulary_analyzer.dart # Vocabulary Schema Inspector
    └── widgets/
        ├── widget_registry.dart  # Dynamic Type-to-Widget Registry
        ├── property_registry.dart# Dynamic Property Interceptor Registry
        ├── datatype_renderers.dart # Property & Scalar Datatype Renderers
        ├── complex_event_widget.dart # Sample schema:Event Widget
        ├── product_widget.dart   # Sample schema:Product Widget
        ├── person_widget.dart    # Sample schema:Person Widget
        └── vocabulary_explorer_widget.dart # Schema.org Explorer UI
```

---

## License

MIT License
