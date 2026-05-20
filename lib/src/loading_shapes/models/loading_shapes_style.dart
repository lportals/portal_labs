import 'package:flutter/material.dart';

/// Defines the geometric properties of a single shape state.
class PortalShapeDefinition {
  /// Creates a new [PortalShapeDefinition].
  const PortalShapeDefinition({
    required this.sides,
    this.innerRadiusRatio = 1.0,
    this.smoothness = 0.5,
  });

  /// The number of sides or peaks in the shape.
  final int sides;

  /// The ratio of the inner radius to the outer radius.
  /// 1.0 creates a regular polygon, while lower values create stars.
  final double innerRadiusRatio;

  /// How smooth the shape transitions are.
  /// 0.0 is a sharp polygon, 1.0 is a smooth organic blob.
  final double smoothness;
}

/// Style configuration for the [LoadingShapes] widget.
class LoadingShapesStyle {
  /// Creates a new [LoadingShapesStyle] instance.
  LoadingShapesStyle({
    this.color = const Color(0xFF1D1D1F),
    this.size = 120.0,
    this.transitionDuration = const Duration(milliseconds: 600),
    this.transitionCurve,
    this.baseRotationSpeed = 0.009,
    this.boostRotationSpeed = 0.025,
    this.enableHaptics = true,
    this.borderWidth = 0.0,
    this.borderColor,
    this.shadows,
    this.pauseDuration = const Duration(milliseconds: 200),
    this.shapes = const [
      PortalShapeDefinition(sides: 5, smoothness: 0.4),
      PortalShapeDefinition(sides: 2, innerRadiusRatio: 0.6, smoothness: 0.7),
      PortalShapeDefinition(sides: 10, innerRadiusRatio: 0.7),
      PortalShapeDefinition(sides: 4, innerRadiusRatio: 0.6, smoothness: 0.8),
      PortalShapeDefinition(sides: 12, innerRadiusRatio: 0.8, smoothness: 0.9),
      PortalShapeDefinition(sides: 6, innerRadiusRatio: 0.9, smoothness: 0.3),
      PortalShapeDefinition(sides: 8, innerRadiusRatio: 0.5, smoothness: 0.4),
    ],
  });

  /// The background color of the shape.
  final Color color;

  /// The size of the shape.
  final double size;

  /// The duration of the morphing transition between shapes.
  final Duration transitionDuration;

  /// The curve used for the morphing transition.
  final Curve? transitionCurve;

  /// The baseline rotation speed (radians per frame).
  final double baseRotationSpeed;

  /// The additional rotation speed boost during morphing (radians per frame).
  final double boostRotationSpeed;

  /// Whether to enable haptic feedback on shape change.
  final bool enableHaptics;

  /// The width of the border around the shape.
  final double borderWidth;

  /// The color of the border around the shape.
  final Color? borderColor;

  /// The shadow applied to the shape.
  final List<BoxShadow>? shadows;

  /// The duration to wait between shape transitions.
  final Duration pauseDuration;

  /// The list of shape definitions to morph between.
  final List<PortalShapeDefinition> shapes;

  /// Creates a copy of this style with the given fields replaced.
  LoadingShapesStyle copyWith({
    Color? color,
    double? size,
    Duration? transitionDuration,
    Curve? transitionCurve,
    double? baseRotationSpeed,
    double? boostRotationSpeed,
    bool? enableHaptics,
    double? borderWidth,
    Color? borderColor,
    List<BoxShadow>? shadows,
    Duration? pauseDuration,
    List<PortalShapeDefinition>? shapes,
  }) {
    return LoadingShapesStyle(
      color: color ?? this.color,
      size: size ?? this.size,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      transitionCurve: transitionCurve ?? this.transitionCurve,
      baseRotationSpeed: baseRotationSpeed ?? this.baseRotationSpeed,
      boostRotationSpeed: boostRotationSpeed ?? this.boostRotationSpeed,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      shadows: shadows ?? this.shadows,
      pauseDuration: pauseDuration ?? this.pauseDuration,
      shapes: shapes ?? this.shapes,
    );
  }
}
