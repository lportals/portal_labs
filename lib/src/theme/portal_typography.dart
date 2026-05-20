import 'package:flutter/material.dart';

/// A collection of [TextStyle] tokens following the Portal Labs design scale.
class PortalTypography {
  /// Creates a [PortalTypography] instance with all required text style scale tokens.
  const PortalTypography({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.caption,
    required this.labelButton,
  });

  /// Default typography scale matching Apple/Premium App Design
  factory PortalTypography.regular({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return PortalTypography(
      h1: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1.0,
      ),
      h2: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      h3: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      h4: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      caption: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      labelButton: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color:
            textPrimary, // Depending on button background, this may be overridden
        letterSpacing: -0.2,
      ),
    );
  }

  /// The primary heading style for page titles.
  final TextStyle h1;

  /// The secondary heading style for main sections.
  final TextStyle h2;

  /// The tertiary heading style for subsections.
  final TextStyle h3;

  /// The small heading style for card titles and details.
  final TextStyle h4;

  /// The large body text style.
  final TextStyle bodyLarge;

  /// The standard body text style.
  final TextStyle bodyMedium;

  /// The caption or helper text style.
  final TextStyle caption;

  /// The text style used inside primary buttons.
  final TextStyle labelButton;
}
