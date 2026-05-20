import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A model representing a currency for the [CurrencySwapInteraction].
class Currency {
  /// Creates a [Currency] instance.
  const Currency({required this.code, required this.flag, required this.name});

  /// The currency code (e.g., "USD").
  final String code;

  /// The flag emoji or icon representing the currency.
  final String flag;

  /// The full name of the currency.
  final String name;
}

/// Style configuration for the [CurrencySwapInteraction].
class CurrencySwapStyle {
  /// Creates a [CurrencySwapStyle] instance with robust defaults.
  const CurrencySwapStyle({
    this.backgroundColor = Colors.white,
    this.inputBackgroundColor = const Color(0xFFF5F7FA),
    this.buttonColor = const Color(0xFF1A1A1A),
    this.buttonTextColor = Colors.white,
    this.inputBorderColor = const Color(0xFFE2E8F0),
    this.titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF718096), // Balanced gray, not too light, not too dark
      letterSpacing: -0.5,
    ),
    this.amountStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF1A202C),
      height: 1.0,
      letterSpacing: -0.5,
      fontFeatures: [ui.FontFeature.tabularFigures()],
    ),
    this.currencyTextStyle = const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF4A5568),
    ),
    this.rateTextStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFF718096),
      fontWeight: FontWeight.w500,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.inputBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.buttonBorderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = const EdgeInsets.all(24),
    this.spacing = 16,
    this.enableHaptics = true,
    this.swapButtonBackgroundColor = Colors.white,
    this.swapButtonIconColor = const Color(0xFF4A5568),
    this.swapButtonBorderColor = const Color(0xFFE2E8F0),
    this.mainShadowColor = const Color(0x0D000000),
    this.dropdownBackgroundColor = Colors.white,
    this.dropdownShadowColor = const Color(0x1F000000),
    this.cursorColor = Colors.black87,
    this.buttonTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  });

  /// The background color of the main container.
  final Color backgroundColor;

  /// The color of the input fields background.
  final Color inputBackgroundColor;

  /// The background color of the proceed button.
  final Color buttonColor;

  /// The text color of the proceed button.
  final Color buttonTextColor;

  /// The border color of the input fields.
  final Color inputBorderColor;

  /// The text style for the "Swap Currency" title.
  final TextStyle titleStyle;

  /// The text style for the amount input.
  final TextStyle amountStyle;

  /// The text style for the currency code.
  final TextStyle currencyTextStyle;

  /// The text style for the exchange rate info.
  final TextStyle rateTextStyle;

  /// The text style for the proceed button.
  final TextStyle buttonTextStyle;

  /// The border radius of the main container.
  final BorderRadius borderRadius;

  /// The border radius of the input fields.
  final BorderRadius inputBorderRadius;

  /// The border radius of the proceed button.
  final BorderRadius buttonBorderRadius;

  /// The padding of the main container.
  final EdgeInsets padding;

  /// The spacing between internal elements.
  final double spacing;

  /// Whether to enable haptic feedback on interactions.
  final bool enableHaptics;

  /// The background color of the central swap button.
  final Color swapButtonBackgroundColor;

  /// The icon color of the central swap button.
  final Color swapButtonIconColor;

  /// The border color of the central swap button.
  final Color swapButtonBorderColor;

  /// The color of the main container shadow.
  final Color mainShadowColor;

  /// The background color of the currency selection dropdown.
  final Color dropdownBackgroundColor;

  /// The shadow color of the currency selection dropdown.
  final Color dropdownShadowColor;

  /// The color of the input cursor.
  final Color cursorColor;
}
