import 'package:flutter/material.dart';

/// Configuration class for styling the [CardSplittingAccordion].
///
/// Allows customization of colors, radii, spacing, and animation durations.
class AccordionStyle {
  /// Creating a theme for the accordion.
  const AccordionStyle({
    this.backgroundColor = Colors.white,
    this.titleColor = const Color(0xFF1A1A1A),
    this.contentColor = const Color(0x99111111),
    this.borderColor = const Color(0xFFEEEEEE),
    this.iconColor = const Color(0xFF333333),
    this.borderRadius = 22.0,
    this.spacing = 16.0,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  /// The background color of each card.
  final Color backgroundColor;

  /// The color of the header title text.
  final Color titleColor;

  /// The color of the content body text.
  final Color contentColor;

  /// The color of the borders.
  final Color borderColor;

  /// The color of the leading icon and chevron.
  final Color iconColor;

  /// The radius of the corners when items are expanded or at boundaries.
  final double borderRadius;

  /// The spacing between separated cards when an item is expanded.
  final double spacing;

  /// The duration of the expansion animation.
  final Duration animationDuration;

  /// Default clean style.
  static const defaultStyle = AccordionStyle();
}
