import 'package:flutter/material.dart';

/// A model representing an option in the [DiscoveryBar].
class DiscoveryOption {

  /// Creates a [DiscoveryOption].
  const DiscoveryOption({
    required this.label,
    required this.icon,
    this.activeColor = const Color(0xFFFF3B30),
  });
  /// The text label for this option.
  final String label;

  /// The icon displayed next to the label.
  final IconData icon;

  /// The color used when this option is active.
  final Color activeColor;
}

/// Style configuration for the [DiscoveryBar].
class DiscoveryBarStyle {

  /// Creates a [DiscoveryBarStyle] with default premium values.
  const DiscoveryBarStyle({
    this.backgroundColor = Colors.white,
    this.inactiveColor = const Color(0xFF1C1C1E),
    this.height = 56.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = const Cubic(0.175, 0.885, 0.420, 1.1),
  });
  /// The background color of the bar components.
  final Color backgroundColor;

  /// The color of the items when they are not selected.
  final Color inactiveColor;

  /// The height of the discovery bar.
  final double height;

  /// The duration of the expansion/contraction animation.
  final Duration duration;

  /// The curve used for the animations.
  final Curve curve;
}
