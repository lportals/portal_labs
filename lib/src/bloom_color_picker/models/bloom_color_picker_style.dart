import 'package:flutter/material.dart';

/// Layout alignment options for the `BloomColorPicker`.
enum BloomColorPickerAlignment {
  /// The color circle indicator is on the left, and the hex pill is on the right.
  circleLeft,

  /// The color circle indicator is on the right, and the hex pill is on the left.
  circleRight,
}

/// Defines the visual styling and layout properties for the `BloomColorPicker`.
class BloomColorPickerStyle {
  /// Creates a new `BloomColorPickerStyle`.
  const BloomColorPickerStyle({
    this.closedRadius = 24.0,
    double? bloomRadius,
    this.sliderWidth = 24.0,
    this.pillBackgroundColor = const Color(0xFFFFFFFF),
    this.pillTextColor = const Color(0xFF1A1A1A),
    this.iconColor = const Color(0xFF8A8A8A),
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeOutCubic, // Smooth ease-out feel
    this.hapticFeedback = true,
    this.showHexPill = true,
    this.alignment = BloomColorPickerAlignment.circleLeft,
  }) : bloomRadius = bloomRadius ?? closedRadius * 5.0;


  /// The radius of the color indicator in the closed state.
  final double closedRadius;

  /// The maximum radius of the blurred bloom effect in the open state.
  final double bloomRadius;

  /// Whether to show the hex code pill in the closed state.
  final bool showHexPill;

  /// The width of the lightness/opacity slider.
  final double sliderWidth;

  /// The background color of the hex code pill in the closed state.
  final Color pillBackgroundColor;

  /// The color of the hex code text in the pill.
  final Color pillTextColor;

  /// The color of the edit icon in the pill.
  final Color iconColor;

  /// Custom text style for the hex code pill. If null, a default style is used.
  final TextStyle? textStyle;

  /// The duration of the state transition animations.
  final Duration animationDuration;

  /// The easing curve for the state transition animations.
  final Curve animationCurve;

   /// Whether to trigger haptic feedback on interactions.
  final bool hapticFeedback;

  /// The alignment of the closed picker components.
  final BloomColorPickerAlignment alignment;

  /// Creates a copy of this style with given fields replaced by new values.
  BloomColorPickerStyle copyWith({
    double? closedRadius,
    double? bloomRadius,
    double? sliderWidth,
    Color? pillBackgroundColor,
    Color? pillTextColor,
    Color? iconColor,
    TextStyle? textStyle,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? hapticFeedback,
    bool? showHexPill,
    BloomColorPickerAlignment? alignment,
  }) {
    return BloomColorPickerStyle(
      closedRadius: closedRadius ?? this.closedRadius,
      bloomRadius: bloomRadius ?? this.bloomRadius,
      sliderWidth: sliderWidth ?? this.sliderWidth,
      pillBackgroundColor: pillBackgroundColor ?? this.pillBackgroundColor,
      pillTextColor: pillTextColor ?? this.pillTextColor,
      iconColor: iconColor ?? this.iconColor,
      textStyle: textStyle ?? this.textStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showHexPill: showHexPill ?? this.showHexPill,
      alignment: alignment ?? this.alignment,
    );
  }
}
