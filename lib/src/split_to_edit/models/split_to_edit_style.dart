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
    this.spacing = 10.0,
    this.innerSpacing = 2.0,
    this.fieldWidth = 36.0,
    this.actionWidthClosed = 40.0,
    this.actionWidthExpanded = 64.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    this.bounceCurve,
    this.closeCurve,
    this.animationDuration = const Duration(milliseconds: 700),
    this.stiffness = 210.0,
    this.damping = 20.0,
    this.mass = 1.0,
    this.enableHaptics = true,
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
  final double spacing;

  /// The tight gap between segments when closed.
  final double innerSpacing;

  /// The width of the numeric input field during editing.
  final double fieldWidth;

  /// The width of the action button segment when closed.
  final double actionWidthClosed;

  /// The width of the action button segment when expanded.
  final double actionWidthExpanded;

  /// The internal padding of the segments.
  final EdgeInsetsGeometry padding;

  /// The curve used for the expansion animation.
  /// If null, a spring is built from [stiffness], [damping], and [mass].
  final Curve? bounceCurve;

  /// The curve used for the contraction (closing) animation.
  /// If null, a spring is built from [stiffness], [damping], and [mass].
  final Curve? closeCurve;

  /// The stiffness of the spring (tension).
  final double stiffness;

  /// The damping of the spring (friction).
  final double damping;

  /// The mass of the spring (inertia).
  final double mass;

  /// The duration of the expansion/contraction animation.
  final Duration animationDuration;

  /// Whether haptic feedback is enabled.
  final bool enableHaptics;
}
