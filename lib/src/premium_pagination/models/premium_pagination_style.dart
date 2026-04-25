import 'package:flutter/material.dart';

/// Defines the visual configuration for the [PremiumPagination].
class PremiumPaginationStyle {
  /// Creates a [PremiumPaginationStyle] configuration.
  const PremiumPaginationStyle({
    this.backgroundColor = const Color(0xFFF2F2F7),
    this.borderColor = const Color(0xFFE5E5EA),
    this.buttonColor = Colors.white,
    this.iconColor = Colors.black,
    this.textStyle = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      letterSpacing: -0.5,
    ),
    this.labelStyle,
    this.padWithZero = false,
    this.maxDigits,
    this.borderRadius = 100,
    this.buttonBorderRadius,
    this.borderWidth = 1.5,
    this.padding = const EdgeInsets.all(8),
    this.spacing = 16,
    this.buttonSize = 48,
    this.iconSize,
    this.shadows,
  });

  /// The background color of the pagination container.
  final Color backgroundColor;

  /// The border color of the pagination container.
  final Color borderColor;

  /// The color of the navigation buttons.
  final Color buttonColor;

  /// The color of the icons inside the buttons.
  final Color iconColor;

  /// The text style for the page numbers and labels.
  final TextStyle textStyle;

  /// The text style for the "of" label. If null, uses [textStyle] with reduced opacity.
  final TextStyle? labelStyle;

  /// Whether to pad the current page number with a leading zero.
  final bool padWithZero;

  /// The maximum number of digits to show. If set, the current page column 
  /// will have a fixed width based on this number of digits.
  final int? maxDigits;

  /// The border radius of the pagination container.
  final double borderRadius;

  /// The border radius of the navigation buttons. If null, buttons will be circular.
  final double? buttonBorderRadius;

  /// The width of the border around the pagination container.
  final double borderWidth;

  /// The internal padding of the pagination container.
  final EdgeInsetsGeometry padding;

  /// The spacing between elements.
  final double spacing;

  /// The size of the buttons.
  final double buttonSize;

  /// The size of the icons inside the buttons.
  /// If null, defaults to [buttonSize] * 0.5.
  final double? iconSize;

  /// The shadow applied to the pagination container.
  final List<BoxShadow>? shadows;
}
