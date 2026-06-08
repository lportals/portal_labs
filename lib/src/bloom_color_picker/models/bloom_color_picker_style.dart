import 'package:flutter/material.dart';

/// Defines the visual styling and layout properties for the `BloomColorPicker`.
class BloomColorPickerStyle {
  /// Creates a new `BloomColorPickerStyle`.
  const BloomColorPickerStyle({
    this.closedRadius = 24.0,
    this.bloomRadius = 120.0,
    this.innerRingRadius = 90.0,
    this.sliderWidth = 24.0,
    this.sliderHeight = 160.0,
    this.pillBackgroundColor = const Color(0xFFFFFFFF),
    this.pillTextColor = const Color(0xFF1A1A1A),
    this.iconColor = const Color(0xFF8A8A8A),
    this.textStyle,
    this.animationDuration = const Duration(milliseconds: 600),
    this.animationCurve = const ElasticOutCurve(0.9), // Spring-like feel
    this.hapticFeedback = true,
    this.showHexPill = true,
  });

  /// The radius of the color indicator in the closed state.
  final double closedRadius;

  /// The maximum radius of the blurred bloom effect in the open state.
  final double bloomRadius;

  /// Whether to show the hex code pill in the closed state.
  final bool showHexPill;

  /// The radius of the inner color wheel ring.
  final double innerRingRadius;

  /// The width of the lightness/opacity slider.
  final double sliderWidth;

  /// The height of the lightness/opacity slider.
  final double sliderHeight;

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

  /// Creates a copy of this style with given fields replaced by new values.
  BloomColorPickerStyle copyWith({
    double? closedRadius,
    double? bloomRadius,
    double? innerRingRadius,
    double? sliderWidth,
    double? sliderHeight,
    Color? pillBackgroundColor,
    Color? pillTextColor,
    Color? iconColor,
    TextStyle? textStyle,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? hapticFeedback,
    bool? showHexPill,
  }) {
    return BloomColorPickerStyle(
      closedRadius: closedRadius ?? this.closedRadius,
      bloomRadius: bloomRadius ?? this.bloomRadius,
      innerRingRadius: innerRingRadius ?? this.innerRingRadius,
      sliderWidth: sliderWidth ?? this.sliderWidth,
      sliderHeight: sliderHeight ?? this.sliderHeight,
      pillBackgroundColor: pillBackgroundColor ?? this.pillBackgroundColor,
      pillTextColor: pillTextColor ?? this.pillTextColor,
      iconColor: iconColor ?? this.iconColor,
      textStyle: textStyle ?? this.textStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      showHexPill: showHexPill ?? this.showHexPill,
    );
  }
}
