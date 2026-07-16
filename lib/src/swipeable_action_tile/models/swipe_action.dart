import 'package:flutter/material.dart';

/// A configuration for an action button behind the swipeable tile.
class SwipeAction {
  /// Creates a configuration for a swipe action button.
  const SwipeAction({
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
    this.label,
  });

  /// The icon or widget to display.
  final Widget icon;

  /// The background color of the action area.
  final Color backgroundColor;

  /// The callback when the action is tapped.
  final VoidCallback onTap;

  /// A semantic label for accessibility screen readers.
  final String? label;
}
