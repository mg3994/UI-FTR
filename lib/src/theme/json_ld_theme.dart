import 'package:flutter/material.dart';

enum JsonLdDensity { compact, comfortable, expanded }

/// Configurable styling framework for customizing JSON-LD UI rendering.
@immutable
class JsonLdTheme {
  final Color primaryColor;
  final Color cardBackgroundColor;
  final double cardElevation;
  final double borderRadius;
  final JsonLdDensity density;
  final TextStyle? titleTextStyle;
  final TextStyle? bodyTextStyle;

  const JsonLdTheme({
    this.primaryColor = Colors.indigo,
    this.cardBackgroundColor = Colors.white,
    this.cardElevation = 2.0,
    this.borderRadius = 12.0,
    this.density = JsonLdDensity.comfortable,
    this.titleTextStyle,
    this.bodyTextStyle,
  });

  /// Default light theme.
  static const JsonLdTheme light = JsonLdTheme();

  /// Dark mode theme preset.
  static final JsonLdTheme dark = JsonLdTheme(
    primaryColor: Colors.indigoAccent,
    cardBackgroundColor: Colors.grey.shade900,
    cardElevation: 4.0,
    borderRadius: 12.0,
  );

  /// Vertical padding helper based on density.
  EdgeInsets get contentPadding {
    switch (density) {
      case JsonLdDensity.compact:
        return const EdgeInsets.all(8.0);
      case JsonLdDensity.comfortable:
        return const EdgeInsets.all(16.0);
      case JsonLdDensity.expanded:
        return const EdgeInsets.all(24.0);
    }
  }

  JsonLdTheme copyWith({
    Color? primaryColor,
    Color? cardBackgroundColor,
    double? cardElevation,
    double? borderRadius,
    JsonLdDensity? density,
    TextStyle? titleTextStyle,
    TextStyle? bodyTextStyle,
  }) {
    return JsonLdTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      cardElevation: cardElevation ?? this.cardElevation,
      borderRadius: borderRadius ?? this.borderRadius,
      density: density ?? this.density,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
    );
  }
}
