import 'package:flutter/material.dart';

/// Style configuration for the [DiscreteTabs] component.
/// Allows customization of backgrounds, borders, shadows, and default colors
/// to integrate seamlessly with any design system.
class DiscreteTabsStyle {
  /// Background color of the tab pill.
  final Color backgroundColor;

  /// Optional active background color (if you want the pill colour to change).
  final Color? activeBackgroundColor;

  /// Shadow color applied to the tab pill.
  final Color shadowColor;

  /// Border applied to the pill.
  final BoxBorder? border;

  /// Color of the icon when the tab is NOT selected.
  final Color inactiveIconColor;

  /// The rounding radius of the pill.
  final BorderRadiusGeometry borderRadius;

  const DiscreteTabsStyle({
    this.backgroundColor = Colors.white,
    this.activeBackgroundColor,
    this.shadowColor = const Color(0x0F000000), // black with 0.06 opacity usually
    this.border,
    this.inactiveIconColor = Colors.black,
    this.borderRadius = const BorderRadius.all(Radius.circular(100)),
  });

  /// Allows inheriting properties and overriding specific ones.
  DiscreteTabsStyle copyWith({
    Color? backgroundColor,
    Color? activeBackgroundColor,
    Color? shadowColor,
    BoxBorder? border,
    Color? inactiveIconColor,
    BorderRadiusGeometry? borderRadius,
  }) {
    return DiscreteTabsStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeBackgroundColor: activeBackgroundColor ?? this.activeBackgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      border: border ?? this.border,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
