import 'package:flutter/material.dart';
import '../../common/portal_animations.dart';

/// Style configuration for the [PremiumSortableGrid].
class PremiumSortableGridStyle {
  /// Creates a [PremiumSortableGridStyle] with the given parameters.
  const PremiumSortableGridStyle({
    this.crossAxisCount = 3,
    this.spacing = 12.0,
    this.itemAspectRatio = 1.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = const PortalSpringCurve(),
    this.enableHaptics = true,
    this.dragScale = 1.1,
    this.dragOpacity = 0.8,
    this.dragShadow = const [
      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
    ],
    this.pulseDuration = const Duration(milliseconds: 400),
    this.pulseScale = 1.05,
    this.showMagneticGhost = true,
    this.flybackDuration = const Duration(milliseconds: 800),
  });

  /// The number of columns in the grid.
  final int crossAxisCount;

  /// The spacing between grid items.
  final double spacing;

  /// The aspect ratio (width / height) of each grid item.
  final double itemAspectRatio;

  /// The border radius of each grid item.
  final BorderRadius borderRadius;

  /// The duration of the reordering animation.
  final Duration animationDuration;

  /// The curve used for the reordering animation.
  final Curve animationCurve;

  /// Whether to trigger haptic feedback on interactions.
  final bool enableHaptics;

  /// The scale factor applied to an item when it is being dragged.
  final double dragScale;

  /// The opacity of an item when it is being dragged.
  final double dragOpacity;

  /// The shadow applied to an item when it is being dragged.
  final List<BoxShadow> dragShadow;

  /// The duration of the pulse animation when an item is held.
  final Duration pulseDuration;

  /// The scale factor applied during the pulse animation.
  final double pulseScale;

  /// Whether to show a semi-transparent ghost of the item in its target position during drag.
  final bool showMagneticGhost;

  /// The duration of the magnetic flyback animation when the item is dropped.
  final Duration flybackDuration;

  /// Creates a copy of this style with the given fields replaced.
  PremiumSortableGridStyle copyWith({
    int? crossAxisCount,
    double? spacing,
    double? itemAspectRatio,
    BorderRadius? borderRadius,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? enableHaptics,
    double? dragScale,
    double? dragOpacity,
    List<BoxShadow>? dragShadow,
    Duration? pulseDuration,
    double? pulseScale,
    bool? showMagneticGhost,
    Duration? flybackDuration,
  }) {
    return PremiumSortableGridStyle(
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      spacing: spacing ?? this.spacing,
      itemAspectRatio: itemAspectRatio ?? this.itemAspectRatio,
      borderRadius: borderRadius ?? this.borderRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      dragScale: dragScale ?? this.dragScale,
      dragOpacity: dragOpacity ?? this.dragOpacity,
      dragShadow: dragShadow ?? this.dragShadow,
      pulseDuration: pulseDuration ?? this.pulseDuration,
      pulseScale: pulseScale ?? this.pulseScale,
      showMagneticGhost: showMagneticGhost ?? this.showMagneticGhost,
      flybackDuration: flybackDuration ?? this.flybackDuration,
    );
  }
}
