import 'package:flutter/material.dart';

/// Configuration for the visual style of the CollapsibleNotificationPanel.
class CollapsibleNotificationPanelStyle {
  /// Creates a [CollapsibleNotificationPanelStyle] with default values.
  const CollapsibleNotificationPanelStyle({
    this.backgroundColor = Colors.white,
    this.borderRadius = 20,
    this.boxShadow,
    this.iconGradientColors = const [Color(0xFF8E8E93), Color(0xFF48484A)],
    this.dividerColor = const Color(0xFFF2F2F7),
    this.headerPadding = const EdgeInsets.all(16),
    this.tilePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.titleColor = const Color(0xFF1C1C1E),
    this.subtitleColor = const Color(0xFF3A3A3C),
    this.descriptionColor = const Color(0xFF3A3A3C),
    this.enableHaptics = true,
  });

  /// The background color of the panel.
  final Color backgroundColor;

  /// The border radius of the panel corners.
  final double borderRadius;

  /// The shadow applied to the panel.
  final List<BoxShadow>? boxShadow;

  /// The colors used for the icon's background gradient.
  final List<Color> iconGradientColors;

  /// The color of the dividers between notifications.
  final Color dividerColor;

  /// Padding applied to the header section.
  final EdgeInsets headerPadding;

  /// Padding applied to each notification tile.
  final EdgeInsets tilePadding;

  /// Color for the title text.
  final Color titleColor;

  /// Color for the subtitle text.
  final Color subtitleColor;

  /// Color for the description text.
  final Color descriptionColor;

  /// Whether to enable haptic feedback on interactions.
  final bool enableHaptics;
}
