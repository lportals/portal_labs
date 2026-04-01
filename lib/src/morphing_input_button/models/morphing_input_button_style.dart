import 'package:flutter/material.dart';

/// Style configuration for the [MorphingInputButton] component.
class MorphingInputButtonStyle {

  /// Creates a [MorphingInputButtonStyle] with the given animation and appearance properties.
  const MorphingInputButtonStyle({
    this.backgroundColor,
    this.buttonColor,
    this.initialWidth = 140.0,
    this.expandedWidth = 320.0,
    this.height = 56.0,
    this.curve = Curves.easeOutBack,
    this.duration = const Duration(milliseconds: 500),
  });
  /// The background color of the outer container.
  final Color? backgroundColor;

  /// The color of the button/input surface. 
  final Color? buttonColor;

  /// The width of the button in its initial state.
  final double initialWidth;

  /// The width of the input field when expanded.
  final double expandedWidth;

  /// The height of the entire component.
  final double height;

  /// The curve used for the morphing animation.
  final Curve curve;

  /// The duration of the entire morphing transition.
  final Duration duration;

  /// Creates a copy of this style with the given fields replaced.
  MorphingInputButtonStyle copyWith({
    Color? backgroundColor,
    Color? buttonColor,
    double? initialWidth,
    double? expandedWidth,
    double? height,
    Curve? curve,
    Duration? duration,
  }) {
    return MorphingInputButtonStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      buttonColor: buttonColor ?? this.buttonColor,
      initialWidth: initialWidth ?? this.initialWidth,
      expandedWidth: expandedWidth ?? this.expandedWidth,
      height: height ?? this.height,
      curve: curve ?? this.curve,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MorphingInputButtonStyle &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          buttonColor == other.buttonColor &&
          initialWidth == other.initialWidth &&
          expandedWidth == other.expandedWidth &&
          height == other.height &&
          curve == other.curve &&
          duration == other.duration;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      buttonColor.hashCode ^
      initialWidth.hashCode ^
      expandedWidth.hashCode ^
      height.hashCode ^
      curve.hashCode ^
      duration.hashCode;
}
