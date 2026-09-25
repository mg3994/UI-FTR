import 'package:flutter/material.dart';
import '../state/json_ld_store.dart';
import '../theme/json_ld_theme.dart';
import '../widgets/widget_registry.dart';
import '../widgets/property_registry.dart';

/// InheritedWidget making JsonLdStore and JsonLdTheme accessible anywhere in the tree.
class JsonLdScope extends InheritedWidget {
  final JsonLdStore store;
  final JsonLdTheme theme;
  final String activeLanguage;

  const JsonLdScope({
    super.key,
    required this.store,
    required this.theme,
    required this.activeLanguage,
    required super.child,
  });

  static JsonLdScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JsonLdScope>();
  }

  @override
  bool updateShouldNotify(JsonLdScope oldWidget) {
    return store != oldWidget.store ||
        theme != oldWidget.theme ||
        activeLanguage != oldWidget.activeLanguage;
  }
}

/// Declarative top-level framework widget for building JSON-LD powered Flutter apps.
class JsonLdApp extends StatefulWidget {
  final dynamic initialDocument;
  final JsonLdTheme theme;
  final String initialLanguage;
  final Widget child;

  const JsonLdApp({
    super.key,
    this.initialDocument,
    this.theme = JsonLdTheme.light,
    this.initialLanguage = 'en',
    required this.child,
  });

  @override
  State<JsonLdApp> createState() => _JsonLdAppState();
}

class _JsonLdAppState extends State<JsonLdApp> {
  late final JsonLdStore _store;
  late String _activeLanguage;

  @override
  void initState() {
    super.initState();
    _store = JsonLdStore();
    _activeLanguage = widget.initialLanguage;
    if (widget.initialDocument != null) {
      _store.loadDocument(widget.initialDocument);
    }
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return JsonLdScope(
      store: _store,
      theme: widget.theme,
      activeLanguage: _activeLanguage,
      child: widget.child,
    );
  }
}
