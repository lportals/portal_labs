import 'package:flutter/material.dart';

/// Style configuration class for `PhysicsCollisionCard`.
///
/// Defines the visual customization and physical simulation properties
/// of the interactive card container and its bodies.
class PhysicsCollisionCardStyle {
  /// Creates a [PhysicsCollisionCardStyle] with customizable visual and physical parameters.
  const PhysicsCollisionCardStyle({
    this.backgroundColor = const Color(0xFFFAFAFA),
    this.cardDecoration = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(24.0)),
      boxShadow: [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    ),
    this.itemDecoration = const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    this.gravity = const Offset(0.0, 900.0),
    this.restitution = 0.7,
    this.damping = 0.2,
    this.enableHaptics = true,
    this.hapticThreshold = 80.0,
    this.showGrid = true,
    this.gridColor = const Color(0xFFE2E2E9),
    this.gridBackgroundColor = const Color(0xFFFAFAFC),
    this.gridPadding = const EdgeInsets.all(16.0),
    this.gridDecoration,
    this.showStars = false,
  });

  /// Outer container background color.
  final Color backgroundColor;

  /// Outer container decoration.
  final BoxDecoration cardDecoration;

  /// Default decoration applied to item children if shape is circular.
  final BoxDecoration itemDecoration;

  /// Gravity vector in pixels/second². Default is downwards acceleration.
  final Offset gravity;

  /// Restitution (bounciness) coefficient between `0.0` (inelastic) and `1.0` (perfectly elastic).
  final double restitution;

  /// Air resistance / velocity damping coefficient (between `0.0` and `1.0`).
  final double damping;

  /// Toggle to enable or disable haptic feedback on collisions.
  final bool enableHaptics;

  /// Impact speed / impulse threshold below which haptics are skipped to prevent micro-vibrations.
  final double hapticThreshold;

  /// Toggle to display a subtle designer line grid inside the card container.
  final bool showGrid;

  /// The color of the lines in the background grid.
  final Color gridColor;

  /// The background color of the grid sheet area.
  final Color gridBackgroundColor;

  /// The padding around the grid sheet inside the card container.
  final EdgeInsets gridPadding;

  /// Custom decoration for the grid area (e.g. border, border radius).
  /// If null, a clean card design is automatically applied.
  final BoxDecoration? gridDecoration;

  /// Toggle to draw a beautiful subtle background starfield behind the items.
  final bool showStars;
}
