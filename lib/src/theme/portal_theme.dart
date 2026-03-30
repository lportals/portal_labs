import 'package:flutter/material.dart';
import 'portal_colors.dart';
import 'portal_typography.dart';

/// Central theme data class for the Portal Labs UI Library.
class PortalThemeData {
  final PortalColors colors;
  final PortalTypography typography;
  final double borderRadius;
  final double cardRadius;

  const PortalThemeData({
    required this.colors,
    required this.typography,
    this.borderRadius = 25.0, // Default Button Radius
    this.cardRadius = 20.0, // Default Internal Card Radius
  });

  /// Constructs a Light Theme Data
  factory PortalThemeData.light() {
    final defaultColors = PortalColors.light();
    return PortalThemeData(
      colors: defaultColors,
      typography: PortalTypography.regular(
        textPrimary: defaultColors.textPrimary,
        textSecondary: defaultColors.textSecondary,
      ),
    );
  }

  /// Constructs a Dark Theme Data
  factory PortalThemeData.dark() {
    final defaultColors = PortalColors.dark();
    return PortalThemeData(
      colors: defaultColors,
      typography: PortalTypography.regular(
        textPrimary: defaultColors.textPrimary,
        textSecondary: defaultColors.textSecondary,
      ),
    );
  }
}

/// The InheritedWidget used to propagate [PortalThemeData] down the tree.
class PortalTheme extends InheritedWidget {
  final PortalThemeData data;

  const PortalTheme({super.key, required this.data, required super.child});

  /// Resolves the nearest [PortalThemeData] in the widget tree.
  /// If none is found, it automatically falls back to [PortalThemeData.light]
  /// or [PortalThemeData.dark] based on device settings.
  static PortalThemeData of(BuildContext context) {
    final PortalTheme? theme = context
        .dependOnInheritedWidgetOfExactType<PortalTheme>();

    if (theme != null) return theme.data;

    // Fallback if not wrapped in PortalTheme
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? PortalThemeData.dark()
        : PortalThemeData.light();
  }

  @override
  bool updateShouldNotify(PortalTheme oldWidget) => data != oldWidget.data;
}
