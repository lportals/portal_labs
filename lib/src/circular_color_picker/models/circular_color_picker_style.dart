import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A custom spring curve that scales the simulation time to ensure it settles
/// perfectly by the end of the animation, preventing abrupt jumps/vibrations.
class _SpringCurve extends Curve {
  const _SpringCurve({
    required this.stiffness,
    required this.damping,
    this.settlingTime = 4.5,
  });

  final double stiffness;
  final double damping;
  final double settlingTime;

  @override
  double transformInternal(double t) {
    final simulation = SpringSimulation(
      SpringDescription(mass: 1.0, stiffness: stiffness, damping: damping),
      0.0,
      1.0,
      0.0,
    );
    return simulation.x(t * settlingTime).clamp(-0.1, 1.1);
  }
}

/// Configuration style class for [CircularColorPicker].
///
/// Houses all visual configuration parameters, durations, and curves.
class CircularColorPickerStyle {
  /// Creates a [CircularColorPickerStyle].
  const CircularColorPickerStyle({
    this.outerRadius = 120.0,
    this.itemSize = 36.0,
    this.itemBorderWidth = 4.0,
    this.centerSize = 100.0,
    this.centerBorderWidth = 12.0,
    this.fillColor = Colors.transparent,
    this.useSolidFill = false,
    this.enableHaptics = true,
    this.toCenterDuration = const Duration(milliseconds: 1100),
    this.toCircleDuration = const Duration(milliseconds: 900),
    this.toCenterCurve = const _SpringCurve(
      stiffness: 80,
      damping: 12,
      settlingTime: 1.1,
    ),
    this.toCircleCurve = Curves.easeInOutCubic,
  });

  /// The fill/background color inside the rings when [useSolidFill] is false.
  final Color fillColor;

  /// Whether the circles should be rendered as solid filled dots instead of outline rings.
  final bool useSolidFill;

  /// The radius of the circle on which outer items are positioned.
  final double outerRadius;

  /// The diameter of the outer color rings.
  final double itemSize;

  /// The stroke/border width of the outer color rings.
  final double itemBorderWidth;

  /// The diameter of the selected center color ring.
  final double centerSize;

  /// The stroke/border width of the selected center color ring.
  final double centerBorderWidth;

  /// Whether to fire lightweight haptic feedback on interaction.
  final bool enableHaptics;

  /// The duration of the slide animation when an item moves to the center.
  final Duration toCenterDuration;

  /// The duration of the slide animation when an item returns to the outer circle.
  final Duration toCircleDuration;

  /// The animation curve used when an item slides to the center (spring curve recommended).
  final Curve toCenterCurve;

  /// The animation curve used when an item returns to its position on the circle (smooth curve recommended).
  final Curve toCircleCurve;

  /// Creates a copy of this style with the given fields replaced.
  CircularColorPickerStyle copyWith({
    double? outerRadius,
    double? itemSize,
    double? itemBorderWidth,
    double? centerSize,
    double? centerBorderWidth,
    Color? fillColor,
    bool? useSolidFill,
    bool? enableHaptics,
    Duration? toCenterDuration,
    Duration? toCircleDuration,
    Curve? toCenterCurve,
    Curve? toCircleCurve,
  }) {
    return CircularColorPickerStyle(
      outerRadius: outerRadius ?? this.outerRadius,
      itemSize: itemSize ?? this.itemSize,
      itemBorderWidth: itemBorderWidth ?? this.itemBorderWidth,
      centerSize: centerSize ?? this.centerSize,
      centerBorderWidth: centerBorderWidth ?? this.centerBorderWidth,
      fillColor: fillColor ?? this.fillColor,
      useSolidFill: useSolidFill ?? this.useSolidFill,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      toCenterDuration: toCenterDuration ?? this.toCenterDuration,
      toCircleDuration: toCircleDuration ?? this.toCircleDuration,
      toCenterCurve: toCenterCurve ?? this.toCenterCurve,
      toCircleCurve: toCircleCurve ?? this.toCircleCurve,
    );
  }
}
