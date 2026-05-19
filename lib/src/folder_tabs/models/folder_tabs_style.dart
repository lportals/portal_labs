import 'package:flutter/material.dart';

/// The visual and animation style configuration for [FolderTabs].
class FolderTabsStyle {
  /// Creates a [FolderTabsStyle] with sensible premium defaults.
  const FolderTabsStyle({
    this.folderColor = const Color(0xFFE6D7C3),
    this.inactiveLabelStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Color(0xFF8A7E6E),
    ),
    this.activeLabelStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Color(0xFF2C2216),
    ),
    this.borderRadius = 24.0,
    this.tabBorderRadius = 24.0,
    this.tabHeight = 36.0,
    this.tabCurveWidth = 24.0,
    this.tabProtrusionWidth = 100.0,
    this.padding = const EdgeInsets.all(24.0),
    this.shadows = const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 20.0,
        offset: Offset(0, 10),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 6.0,
        offset: Offset(0, 3),
      ),
    ],
    this.enableHaptics = true,
    this.springMass = 1.0,
    this.springStiffness = 210.0,
    this.springDamping = 22.0,
  });

  /// The primary color of the folder shape (body and active tab protrusion).
  final Color folderColor;

  /// The text style for inactive tab labels.
  final TextStyle inactiveLabelStyle;

  /// The text style for the active tab label.
  final TextStyle activeLabelStyle;

  /// The corner radius of the bottom corners and top corners of the main folder body.
  final double borderRadius;

  /// The corner radius of the active tab's top corners.
  final double tabBorderRadius;

  /// The height of the active tab protrusion above the folder body.
  final double tabHeight;

  /// The width of the transition curve (S-curve) that connects the tab
  /// protrusion to the folder's top flat edge.
  final double tabCurveWidth;

  /// The fixed width of the active tab protrusion.
  final double tabProtrusionWidth;

  /// The padding inside the folder container.
  final EdgeInsetsGeometry padding;

  /// The shadows applied below the folder container.
  final List<BoxShadow> shadows;

  /// Whether to trigger lightweight haptic feedback on tab selection.
  final bool enableHaptics;

  /// Mass of the spring physics for tab movement.
  final double springMass;

  /// Stiffness of the spring physics for tab movement.
  final double springStiffness;

  /// Damping of the spring physics for tab movement.
  final double springDamping;

  /// Creates a copy of this style with the given fields replaced.
  FolderTabsStyle copyWith({
    Color? folderColor,
    TextStyle? inactiveLabelStyle,
    TextStyle? activeLabelStyle,
    double? borderRadius,
    double? tabBorderRadius,
    double? tabHeight,
    double? tabCurveWidth,
    double? tabProtrusionWidth,
    EdgeInsetsGeometry? padding,
    List<BoxShadow>? shadows,
    bool? enableHaptics,
    double? springMass,
    double? springStiffness,
    double? springDamping,
  }) {
    return FolderTabsStyle(
      folderColor: folderColor ?? this.folderColor,
      inactiveLabelStyle: inactiveLabelStyle ?? this.inactiveLabelStyle,
      activeLabelStyle: activeLabelStyle ?? this.activeLabelStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      tabBorderRadius: tabBorderRadius ?? this.tabBorderRadius,
      tabHeight: tabHeight ?? this.tabHeight,
      tabCurveWidth: tabCurveWidth ?? this.tabCurveWidth,
      tabProtrusionWidth: tabProtrusionWidth ?? this.tabProtrusionWidth,
      padding: padding ?? this.padding,
      shadows: shadows ?? this.shadows,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      springMass: springMass ?? this.springMass,
      springStiffness: springStiffness ?? this.springStiffness,
      springDamping: springDamping ?? this.springDamping,
    );
  }
}
