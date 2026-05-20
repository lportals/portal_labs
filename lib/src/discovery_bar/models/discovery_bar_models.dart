import 'package:flutter/material.dart';
import '../../common/portal_animations.dart';

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
    this.indicatorColor = const Color(0xFFFF3B30),
    this.height = 56.0,
    this.duration = const Duration(milliseconds: 800),
    this.curve = const PortalSpringCurve(stiffness: 160, damping: 17),
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xFF1C1C1E),
    ),
    this.activeTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    this.iconSize = 20.0,
    this.searchIconSize = 24.0,
    this.borderRadius,
    this.shadows = const [
      BoxShadow(color: Color(0x0D000000), blurRadius: 15, offset: Offset(0, 4)),
    ],
    this.enableHaptics = true,
  });

  /// The background color of the bar components.
  final Color backgroundColor;

  /// The color of the items when they are not selected.
  final Color inactiveColor;

  /// The color of the active indicator card.
  final Color indicatorColor;

  /// The height of the discovery bar.
  final double height;

  /// The duration of the expansion/contraction animation.
  final Duration duration;

  /// The curve used for the animations.
  final Curve curve;

  /// The text style for inactive options.
  final TextStyle textStyle;

  /// The text style for the active option.
  final TextStyle activeTextStyle;

  /// The size of the icons in the discovery list.
  final double iconSize;

  /// The size of the search/close icon.
  final double searchIconSize;

  /// The border radius of the bar. If null, defaults to height/2.
  final BorderRadius? borderRadius;

  /// The shadows applied to the bar components.
  final List<BoxShadow> shadows;

  /// Whether haptic feedback is enabled.
  final bool enableHaptics;
}
