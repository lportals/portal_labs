import 'package:flutter/material.dart';

/// Defines the visual configuration for the [PremiumStepper].
class PremiumStepperStyle {
  /// The background color of the stepper container.
  final Color backgroundColor;

  /// The border color of the stepper container.
  final Color borderColor;

  /// The color of the minus and plus buttons.
  final Color buttonColor;

  /// The color of the icons inside the buttons.
  final Color iconColor;

  /// The text style for the value display.
  final TextStyle textStyle;

  /// The border radius of the stepper container.
  final double borderRadius;

  /// The spacing between elements.
  final double spacing;

  /// The size of the buttons.
  final double buttonSize;

  /// The size of the icons inside the buttons.
  /// If null, defaults to [buttonSize] * 0.5.
  final double? iconSize;

  /// The width allocated for the numeric value display.
  final double valueWidth;

  /// The maximum number of digits supported by the layout.
  final int maxDigits;

  /// The shadow applied to the stepper container.
  final List<BoxShadow>? shadows;

  const PremiumStepperStyle({
    this.backgroundColor = const Color(0xFFF9F9F9),
    this.borderColor = const Color(0xFFEEEEEE),
    this.buttonColor = const Color(0xFFE5E5EA),
    this.iconColor = Colors.black,
    this.textStyle = const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    this.borderRadius = 100,
    this.spacing = 16,
    this.buttonSize = 48,
    this.iconSize,
    this.valueWidth = 80,
    this.maxDigits = 3,
    this.shadows,
  });
}
