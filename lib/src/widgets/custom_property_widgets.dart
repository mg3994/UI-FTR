import 'package:flutter/material.dart';

/// Pre-built property UI widgets (Ratings, Price Badges, Geo Chips)
class CustomPropertyWidgets {
  /// Star rating widget renderer for `schema:ratingValue` or `schema:reviewRating`.
  static Widget buildRatingWidget(
    BuildContext context,
    String propertyName,
    dynamic value, {
    required bool isEditable,
    void Function(dynamic val)? onChanged,
  }) {
    final double rating = double.tryParse(value?.toString() ?? '') ?? 4.5;

    if (isEditable) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: rating.clamp(0.0, 5.0),
              min: 0.0,
              max: 5.0,
              divisions: 10,
              label: rating.toStringAsFixed(1),
              onChanged: (val) {
                if (onChanged != null) onChanged(val);
              },
            ),
            Text(rating.toStringAsFixed(1)),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold)),
          ...List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Icon(Icons.star, color: Colors.amber, size: 18);
            } else if (index < rating) {
              return const Icon(Icons.star_half, color: Colors.amber, size: 18);
            }
            return const Icon(Icons.star_border, color: Colors.amber, size: 18);
          }),
          const SizedBox(width: 6),
          Text('($rating)'),
        ],
      ),
    );
  }

  /// Price tag chip widget for `schema:price` or `schema:offers`.
  static Widget buildPriceWidget(
    BuildContext context,
    String propertyName,
    dynamic value, {
    required bool isEditable,
    void Function(dynamic val)? onChanged,
  }) {
    final strVal = value?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.attach_money, color: Colors.green, size: 18),
          Text(
            strVal,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
