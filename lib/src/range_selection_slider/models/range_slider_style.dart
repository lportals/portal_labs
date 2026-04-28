import 'package:flutter/material.dart';

/// Style configuration for the [RangeSelectionSlider].
///
/// Allows customizing colors, typography, borders, and animations for
/// the premium price range selector.
class RangeSliderStyle {

  /// Creates a [RangeSliderStyle] with the given appearance properties.
  const RangeSliderStyle({
    this.backgroundColor = Colors.white,
    this.borderRadius = 32.0,
    this.title = 'Price Range',
    this.titleStyle = const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      letterSpacing: -0.4,
    ),
    this.fromLabel = 'From',
    this.toLabel = 'To',
    this.fieldLabelStyle = const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFFACACAC),
      letterSpacing: 0.1,
    ),
    this.fieldValueStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      letterSpacing: 0.0,
      fontFeatures: [FontFeature('tnum')],
    ),
    this.fieldBackgroundColor = const Color(0xFFF9FAFD),
    this.currencySymbol = '\$',
    this.activeTrackColor = Colors.black,
    this.inactiveTrackColor = const Color(0xFFF0F1F7),
    this.thumbColor = Colors.white,
    this.thumbBorderColor = Colors.black,
    this.applyLabel = 'Apply',
    this.cancelLabel = 'Cancel',
    this.primaryButtonColor = Colors.black,
    this.primaryButtonTextColor = Colors.white,
    this.secondaryButtonBorderColor = const Color(0xFFF0F1F7),
    this.secondaryButtonTextColor = const Color(0xFF8E8E93),
    this.buttonHeight = 44.0,
  });

  /// The default visual theme for Portal Labs components.
  factory RangeSliderStyle.portalLabs() => const RangeSliderStyle();
  /// The background color of the entire component.
  final Color backgroundColor;

  /// Corner radius for the main container.
  final double borderRadius;

  /// The title of the component (e.g., "Price Range").
  final String title;

  /// Text style for the main title.
  final TextStyle titleStyle;

  /// Label for the minimum value field (e.g., "From").
  final String fromLabel;

  /// Label for the maximum value field (e.g., "To").
  final String toLabel;

  /// Text style for the "From" and "To" labels.
  final TextStyle fieldLabelStyle;

  /// Text style for the displayed currency values.
  final TextStyle fieldValueStyle;

  /// Background color for the value fields.
  final Color fieldBackgroundColor;

  /// Symbol prefix for currency (e.g., "$").
  final String currencySymbol;

  /// Color for the active (selected) track of the slider.
  final Color activeTrackColor;

  /// Color for the inactive (unselected) track of the slider.
  final Color inactiveTrackColor;

  /// Color of the slider's circular handles.
  final Color thumbColor;

  /// Color of the border for the slider's handles.
  final Color thumbBorderColor;

  /// Label for the primary action button (e.g., "Apply").
  final String applyLabel;

  /// Label for the secondary action button (e.g., "Cancel").
  final String cancelLabel;

  /// Background color for the primary (Apply) button.
  final Color primaryButtonColor;

  /// Text color for the primary button.
  final Color primaryButtonTextColor;

  /// Border color for the secondary (Cancel) button.
  final Color secondaryButtonBorderColor;

  /// Text color for the secondary button.
  final Color secondaryButtonTextColor;

  /// Height for the action buttons.
  final double buttonHeight;
}
