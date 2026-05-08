import 'package:flutter/material.dart';

/// Defines the visual aesthetic for the [QuickSwitcher].
class QuickSwitcherStyle {

  /// Creates a [QuickSwitcherStyle].
  const QuickSwitcherStyle({
    this.backgroundColor = const Color(0xFFF5F5F7),
    this.switchButtonColor = Colors.white,
    this.foregroundColor = const Color(0xFF1D1D1F),
    this.borderRadius = 32.0,
    this.padding = const EdgeInsets.all(4.0),
    this.pulseColor = const Color(0xFFE8E8ED),
    this.enableHaptics = true,
  });
  /// The background color of the main container.
  final Color backgroundColor;

  /// The color of the switch button when inactive.
  final Color switchButtonColor;

  /// The color of the text and icons.
  final Color foregroundColor;

  /// The radius of the main container.
  final double borderRadius;

  /// The padding inside the container.
  final EdgeInsetsGeometry padding;

  /// The color of the pulse animation.
  final Color pulseColor;

  /// Whether to enable haptic feedback.
  final bool enableHaptics;
}
