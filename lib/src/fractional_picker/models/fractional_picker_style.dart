import 'package:flutter/material.dart';

/// Style configuration for the [ModernFractionalPicker] component.
class FractionalPickerStyle {
  /// Creates a [FractionalPickerStyle] with the given appearance properties.
  const FractionalPickerStyle({
    this.activeColor = const Color(0xFF1D1D1F),
    this.inactiveColor = const Color(0xFF8E8E93),
    this.tickColor = const Color(0xFFE5E5EA),
    this.backgroundColor = Colors.white,
    this.borderRadius = 22.0,
    this.pointerColor = const Color(0xFFD1D1D6),
    this.friction = 0.22,
    this.snapStiffness = 100.0,
  });

  /// Primary color for the active value (centered).
  final Color activeColor;

  /// Secondary color for inactive values.
  final Color inactiveColor;

  /// Color for the ruler tick marks.
  final Color tickColor;

  /// Background color of the picker container.
  final Color backgroundColor;

  /// Border radius of the picker container.
  final double borderRadius;

  /// Color of the top pointer/marker.
  final Color pointerColor;

  /// Control how far the ruler glides. Higher values = more braking force.
  final double friction;

  /// The force of the snap 'magnetism'. Higher values = faster snap.
  final double snapStiffness;

  /// Creates a copy of this style with the given fields replaced.
  FractionalPickerStyle copyWith({
    Color? activeColor,
    Color? inactiveColor,
    Color? tickColor,
    Color? backgroundColor,
    double? borderRadius,
    Color? pointerColor,
    double? friction,
    double? snapStiffness,
  }) {
    return FractionalPickerStyle(
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      tickColor: tickColor ?? this.tickColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      pointerColor: pointerColor ?? this.pointerColor,
      friction: friction ?? this.friction,
      snapStiffness: snapStiffness ?? this.snapStiffness,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FractionalPickerStyle &&
          runtimeType == other.runtimeType &&
          activeColor == other.activeColor &&
          inactiveColor == other.inactiveColor &&
          tickColor == other.tickColor &&
          backgroundColor == other.backgroundColor &&
          borderRadius == other.borderRadius &&
          pointerColor == other.pointerColor &&
          friction == other.friction &&
          snapStiffness == other.snapStiffness;

  @override
  int get hashCode =>
      activeColor.hashCode ^
      inactiveColor.hashCode ^
      tickColor.hashCode ^
      backgroundColor.hashCode ^
      borderRadius.hashCode ^
      pointerColor.hashCode ^
      friction.hashCode ^
      snapStiffness.hashCode;
}
