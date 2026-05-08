import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// A premium spring-based animation curve that uses [SpringSimulation].
/// 
/// This provides a more natural, physics-based motion compared to standard 
/// duration-based curves like [Curves.easeOut].
class PortalSpringCurve extends Curve {
  /// Creates a [PortalSpringCurve] with customizable physical parameters.
  /// 
  /// [mass] defines the weight of the object (default: 1.0).
  /// [stiffness] defines the spring's tension (default: 180.0).
  /// [damping] defines the friction that settles the motion (default: 22.0).
  const PortalSpringCurve({
    this.mass = 1.0,
    this.stiffness = 180.0,
    this.damping = 22.0,
  });

  /// The mass of the object.
  final double mass;

  /// The stiffness of the spring.
  final double stiffness;

  /// The damping of the spring.
  final double damping;

  @override
  double transformInternal(double t) {
    final simulation = SpringSimulation(
      SpringDescription(mass: mass, stiffness: stiffness, damping: damping),
      0.0,
      1.0,
      0.0,
    );
    // We clamp the result to avoid extreme overflows during heavy bounce,
    // though the nature of springs allows for slight overshoot (up to 1.1).
    return simulation.x(t).clamp(-0.1, 1.1);
  }
}

