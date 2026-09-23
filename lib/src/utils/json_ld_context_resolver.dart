import '../models/json_ld_context.dart';

/// Context resolver supporting remote URL references (e.g. `https://schema.org`),
/// offline built-in vocabulary term mappings, and local term caching.
class JsonLdContextResolver {
  static final Map<String, JsonLdContext> _cachedContexts = {};

  /// Built-in fallback contexts for well-known IRIs when offline
  static final Map<String, Map<String, dynamic>> _builtInContexts = {
    'https://schema.org': {
      'name': 'https://schema.org/name',
      'description': 'https://schema.org/description',
      'url': 'https://schema.org/url',
      'image': 'https://schema.org/image',
      'startDate': 'https://schema.org/startDate',
      'endDate': 'https://schema.org/endDate',
      'location': 'https://schema.org/location',
      'performer': 'https://schema.org/performer',
      'price': 'https://schema.org/price',
      'recipeIngredient': 'https://schema.org/recipeIngredient',
      'recipeInstructions': 'https://schema.org/recipeInstructions',
    },
    'http://schema.org': {
      'name': 'http://schema.org/name',
      'description': 'http://schema.org/description',
    },
  };

  /// Resolves any inline map, URL string, or list context into a combined `JsonLdContext`.
  static Future<JsonLdContext> resolveContext(dynamic rawContext) async {
    final termsMap = <String, dynamic>{};
    final urlsList = <String>[];

    void processItem(dynamic item) {
      if (item is String) {
        urlsList.add(item);
        if (_builtInContexts.containsKey(item)) {
          termsMap.addAll(_builtInContexts[item]!);
        } else if (_cachedContexts.containsKey(item)) {
          termsMap.addAll(_cachedContexts[item]!.terms);
        }
      } else if (item is Map<String, dynamic>) {
        termsMap.addAll(item);
      } else if (item is List) {
        for (final child in item) {
          processItem(child);
        }
      }
    }

    processItem(rawContext);
    final context = JsonLdContext(terms: termsMap, remoteUrls: urlsList);

    // Cache resolved context for URL keys
    for (final url in urlsList) {
      _cachedContexts[url] = context;
    }

    return context;
  }
}
