import 'package:flutter/material.dart';
import '../models/json_ld_node.dart';
import '../models/json_ld_value.dart';

/// Widget for visual node tree inspection, graph relationships, and converting JSON-LD to RDF Triples (N-Quads).
class GraphInspectorWidget extends StatelessWidget {
  final JsonLdNode node;

  const GraphInspectorWidget({
    super.key,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    final triples = _generateRdfTriples(node);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(
                        'Graph Node Inspector',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Primary Node ID: ${node.id ?? "Blank Node (_:b0)"}'),
                  Text('Assigned Types: ${node.types.join(", ")}'),
                  Text('Is @graph Container: ${node.isGraph}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Generated RDF Triples / N-Quads (${triples.length}):',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Chip(label: Text('${triples.length} Statements')),
                    ],
                  ),
                  const Divider(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      triples.isNotEmpty ? triples.join('\n') : '# No RDF Triples generated.',
                      style: const TextStyle(fontFamily: 'monospace', color: Colors.lightGreenAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateRdfTriples(JsonLdNode root) {
    final triples = <String>[];

    void processNode(JsonLdNode n, String subjectIri) {
      for (final type in n.types) {
        triples.add('<$subjectIri> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <$type> .');
      }

      n.properties.forEach((key, val) {
        final predIri = key.startsWith('http') ? key : 'https://schema.org/${key.split(':').last}';

        if (val is JsonLdValue) {
          final lit = val.displayString.replaceAll('"', '\\"');
          final langSuffix = val.language != null ? '@${val.language}' : '';
          triples.add('<$subjectIri> <$predIri> "$lit"$langSuffix .');
        } else if (val is JsonLdNode) {
          final objIri = val.id ?? '_:b${triples.length}';
          triples.add('<$subjectIri> <$predIri> <$objIri> .');
          processNode(val, objIri);
        } else if (val is List) {
          for (final item in val) {
            if (item is JsonLdValue) {
              final lit = item.displayString.replaceAll('"', '\\"');
              final langSuffix = item.language != null ? '@${item.language}' : '';
              triples.add('<$subjectIri> <$predIri> "$lit"$langSuffix .');
            } else if (item is JsonLdNode) {
              final objIri = item.id ?? '_:b${triples.length}';
              triples.add('<$subjectIri> <$predIri> <$objIri> .');
              processNode(item, objIri);
            }
          }
        }
      });
    }

    final nodesToProcess = root.isGraph ? root.graphNodes : [root];
    for (int i = 0; i < nodesToProcess.length; i++) {
      final child = nodesToProcess[i];
      final subj = child.id ?? '_:b$i';
      processNode(child, subj);
    }

    return triples;
  }
}
