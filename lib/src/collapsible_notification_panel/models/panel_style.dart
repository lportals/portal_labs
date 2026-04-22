import 'package:flutter/material.dart';

/// Configuration for the visual style of the CollapsibleNotificationPanel.
class CollapsibleNotificationPanelStyle {
  final Color backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final List<Color> iconGradientColors;
  final Color dividerColor;
  final EdgeInsets headerPadding;
  final EdgeInsets tilePadding;
  final Color titleColor;
  final Color subtitleColor;
  final Color descriptionColor;

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
  });
}
