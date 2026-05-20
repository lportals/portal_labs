import 'package:flutter/material.dart';

/// Style configuration for the [ModernWeightPicker] component.
class WeightPickerStyle {
  /// Creates a [WeightPickerStyle] with the given appearance properties.
  const WeightPickerStyle({
    this.activeColor = const Color(0xFF1D1D1F),
    this.inactiveColor = const Color(0xFFC7C7CC),
    this.tickColor = const Color(0xFFD1D1D6),
    this.backgroundColor = Colors.white,
    this.borderRadius = 44,
  });

  /// Primary color for the active value and indicator.
  final Color activeColor;

  /// Secondary color for inactive values.
  final Color inactiveColor;

  /// Color for the ruler tick marks.
  final Color tickColor;

  /// Background color of the picker container.
  final Color backgroundColor;

  /// Border radius of the picker container.
  final double borderRadius;

  /// Creates a copy of this style with the given fields replaced.
  WeightPickerStyle copyWith({
    Color? activeColor,
    Color? inactiveColor,
    Color? tickColor,
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return WeightPickerStyle(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      tickColor: tickColor ?? this.tickColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightPickerStyle &&
          runtimeType == other.runtimeType &&
          activeColor == other.activeColor &&
          inactiveColor == other.inactiveColor &&
          tickColor == other.tickColor &&
          backgroundColor == other.backgroundColor &&
          borderRadius == other.borderRadius;

  @override
  int get hashCode =>
      activeColor.hashCode ^
      inactiveColor.hashCode ^
      tickColor.hashCode ^
      backgroundColor.hashCode ^
      borderRadius.hashCode;
}
