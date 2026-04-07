import 'package:flutter/material.dart';

/// Style configuration for the [SplitToEditDuration] component.
class SplitToEditStyle {
  /// Creates a [SplitToEditStyle] with customized values.
  const SplitToEditStyle({
    this.backgroundColor,
    this.activeColor,
    this.textStyle,
    this.unitStyle,
    this.borderRadius,
    this.spacing,
    this.padding,
    this.bounceCurve = const ElasticOutCurve(0.8),
    this.animationDuration = const Duration(milliseconds: 600),
  });

  /// The background color of the segments.
  final Color? backgroundColor;

  /// The color of the icons and highlighting text.
  final Color? activeColor;

  /// The text style for the values.
  final TextStyle? textStyle;

  /// The text style for the units (Hr, Min).
  final TextStyle? unitStyle;

  /// The border radius of the segments.
  final double? borderRadius;

  /// The spacing between segments when expanded.
  final double? spacing;

  /// The internal padding of the segments.
  final EdgeInsetsGeometry? padding;

  /// The curve used for the expansion/contraction animation.
  final Curve bounceCurve;

  /// The duration of the expansion/contraction animation.
  final Duration animationDuration;
}
