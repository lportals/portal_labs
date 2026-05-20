import 'package:flutter/material.dart';

/// Represents a single tab item for the [PortalDiscreteTabs] widget.
class DiscreteTab {
  /// Creates a [DiscreteTab] with the required visual and semantic properties.
  const DiscreteTab({
    required this.label,
    required this.icon,
    required this.activeColor,
    this.activeBackgroundColor,
  });

  /// The text label shown when the tab is active.
  final String label;

  /// The icon displayed in both active and inactive states.
  final IconData icon;

  /// The primary color used for the icon and text when the tab is selected.
  final Color activeColor;

  /// Optional background color overrides for the selected tab.
  /// If null, [activeColor] with low opacity will be used.
  final Color? activeBackgroundColor;
}
