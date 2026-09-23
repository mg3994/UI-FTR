import 'package:flutter/foundation.dart';
import '../models/json_ld_node.dart';

/// State representation for JSON-LD store operations.
@immutable
class JsonLdState {
  final JsonLdNode? rootNode;
  final Map<String, JsonLdNode> nodeCache;
  final List<String> navigationStack;
  final bool isLoading;
  final String? error;

  const JsonLdState({
    this.rootNode,
    this.nodeCache = const {},
    this.navigationStack = const [],
    this.isLoading = false,
    this.error,
  });

  /// Get currently active displayed node from navigation stack.
  JsonLdNode? get currentNode {
    if (navigationStack.isNotEmpty) {
      final currentId = navigationStack.last;
      if (nodeCache.containsKey(currentId)) {
        return nodeCache[currentId];
      }
    }
    return rootNode;
  }

  JsonLdState copyWith({
    JsonLdNode? rootNode,
    Map<String, JsonLdNode>? nodeCache,
    List<String>? navigationStack,
    bool? isLoading,
    String? error,
  }) {
    return JsonLdState(
      rootNode: rootNode ?? this.rootNode,
      nodeCache: nodeCache ?? this.nodeCache,
      navigationStack: navigationStack ?? this.navigationStack,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// State Controller / Store managing state, loading, caching, and lazy-resolving
/// linked (@id-referenced) nodes in JSON-LD documents.
class JsonLdStore extends ValueNotifier<JsonLdState> {
  JsonLdStore([JsonLdState? initialState])
      : super(initialState ?? const JsonLdState());

  /// Loads document into store and indexes all nodes with @id into cache.
  void loadDocument(dynamic jsonLdPayload) {
    value = value.copyWith(isLoading: true, error: null);
    try {
      final parsed = JsonLdNode.fromJson(jsonLdPayload);
      final cache = <String, JsonLdNode>{};

      _indexNodes(parsed, cache);

      value = value.copyWith(
        rootNode: parsed,
        nodeCache: cache,
        navigationStack: [],
        isLoading: false,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        error: 'Failed to load JSON-LD payload: $e',
      );
    }
  }

  /// Indexes nodes recursively into cache map by @id.
  void _indexNodes(JsonLdNode node, Map<String, JsonLdNode> cache) {
    if (node.id != null) {
      cache[node.id!] = node;
    }

    if (node.isGraph) {
      for (final child in node.graphNodes) {
        _indexNodes(child, cache);
      }
    }

    node.properties.forEach((key, val) {
      if (val is JsonLdNode) {
        _indexNodes(val, cache);
      } else if (val is List) {
        for (final item in val) {
          if (item is JsonLdNode) {
            _indexNodes(item, cache);
          }
        }
      }
    });
  }

  /// Navigates to target node by @id reference.
  void navigateToId(String id) {
    if (value.nodeCache.containsKey(id)) {
      final updatedStack = List<String>.from(value.navigationStack)..add(id);
      value = value.copyWith(navigationStack: updatedStack);
    } else {
      // Lazy-load placeholder if @id node not in local cache
      final placeholder = JsonLdNode(
        id: id,
        types: const ['schema:Thing'],
        properties: {'schema:name': 'External Link: $id'},
      );
      final updatedCache = Map<String, JsonLdNode>.from(value.nodeCache)..[id] = placeholder;
      final updatedStack = List<String>.from(value.navigationStack)..add(id);
      value = value.copyWith(
        nodeCache: updatedCache,
        navigationStack: updatedStack,
      );
    }
  }

  /// Pops the top node from navigation stack (Back navigation).
  bool popNavigation() {
    if (value.navigationStack.isNotEmpty) {
      final updatedStack = List<String>.from(value.navigationStack)..removeLast();
      value = value.copyWith(navigationStack: updatedStack);
      return true;
    }
    return false;
  }

  /// Updates node state (e.g. after editing property values).
  void updateNode(JsonLdNode updatedNode) {
    final cache = Map<String, JsonLdNode>.from(value.nodeCache);
    if (updatedNode.id != null) {
      cache[updatedNode.id!] = updatedNode;
    }

    if (value.rootNode?.id == updatedNode.id) {
      value = value.copyWith(rootNode: updatedNode, nodeCache: cache);
    } else {
      value = value.copyWith(nodeCache: cache);
    }
  }
}
