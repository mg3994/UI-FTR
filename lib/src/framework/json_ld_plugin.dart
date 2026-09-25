import '../widgets/complex_event_widget.dart';
import '../widgets/person_widget.dart';
import '../widgets/place_widget.dart';
import '../widgets/product_widget.dart';
import '../widgets/recipe_widget.dart';
import '../widgets/review_widget.dart';
import '../widgets/widget_registry.dart';
import '../widgets/property_registry.dart';

/// Abstract plugin contract for extending the framework with modular widget and property registries.
abstract class JsonLdFrameworkPlugin {
  String get name;
  void register(JsonLdWidgetRegistry widgetRegistry, JsonLdPropertyRegistry propertyRegistry);
}

/// Built-in plugin auto-registering standard Schema.org widgets (Event, Product, Person, Recipe, Place, Review).
class SchemaOrgCorePlugin implements JsonLdFrameworkPlugin {
  @override
  String get name => 'SchemaOrgCorePlugin';

  @override
  void register(JsonLdWidgetRegistry widgetRegistry, JsonLdPropertyRegistry propertyRegistry) {
    widgetRegistry.register('schema:Event', (context, node,
        {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
      return ComplexEventWidget(
        node: node,
        isEditable: isEditable,
        activeLanguage: activeLanguage,
        onChanged: onChanged,
        onNodeTap: onNodeTap,
      );
    });
    widgetRegistry.register('Event', widgetRegistry.lookup(['schema:Event'])!);

    widgetRegistry.register('schema:Product', (context, node,
        {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
      return ProductWidget(
        node: node,
        isEditable: isEditable,
        activeLanguage: activeLanguage,
        onChanged: onChanged,
        onNodeTap: onNodeTap,
      );
    });
    widgetRegistry.register('Product', widgetRegistry.lookup(['schema:Product'])!);

    widgetRegistry.register('schema:Person', (context, node,
        {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
      return PersonWidget(
        node: node,
        isEditable: isEditable,
        activeLanguage: activeLanguage,
        onChanged: onChanged,
        onNodeTap: onNodeTap,
      );
    });
    widgetRegistry.register('Person', widgetRegistry.lookup(['schema:Person'])!);

    widgetRegistry.register('schema:Recipe', (context, node,
        {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
      return RecipeWidget(
        node: node,
        isEditable: isEditable,
        activeLanguage: activeLanguage,
        onChanged: onChanged,
        onNodeTap: onNodeTap,
      );
    });
    widgetRegistry.register('Recipe', widgetRegistry.lookup(['schema:Recipe'])!);

    widgetRegistry.register('schema:Place', (context, node,
        {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
      return PlaceWidget(
        node: node,
        isEditable: isEditable,
        activeLanguage: activeLanguage,
        onChanged: onChanged,
        onNodeTap: onNodeTap,
      );
    });
    widgetRegistry.register('Place', widgetRegistry.lookup(['schema:Place'])!);

    widgetRegistry.register('schema:Review', (context, node,
        {required isEditable, required activeLanguage, onChanged, onNodeTap}) {
      return ReviewWidget(
        node: node,
        isEditable: isEditable,
        activeLanguage: activeLanguage,
        onChanged: onChanged,
        onNodeTap: onNodeTap,
      );
    });
    widgetRegistry.register('Review', widgetRegistry.lookup(['schema:Review'])!);
  }
}
