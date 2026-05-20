import 'package:flutter/material.dart';

/// A collection of color tokens used throughout the Portal Labs design system.
class PortalColors {
  /// Creates a [PortalColors] instance with all required color tokens.
  const PortalColors({
    required this.primary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.warning,
  });

  /// Default High-Fidelity Light Theme Colors
  factory PortalColors.light() {
    return const PortalColors(
      primary: Color(0xFF1D1D1F),
      background: Color(0xFFFAFAFA),
      surface: Colors.white,
      textPrimary: Color(0xFF1D1D1F),
      textSecondary: Color(0xFF8E8E93),
      border: Color(0xFFE5E5EA),
      error: Color(0xFFFF3B30),
      warning: Color(0xFFFFF7C1),
    );
  }

  /// Default High-Fidelity Dark Theme Colors
  factory PortalColors.dark() {
    return const PortalColors(
      primary: Colors.white,
      background: Color(0xFF000000),
      surface: Color(0xFF1C1C1E),
      textPrimary: Colors.white,
      textSecondary: Color(0xFF8E8E93),
      border: Color(0xFF2C2C2E),
      error: Color(0xFFFF453A),
      warning: Color(0xFFD4B300),
    );
  }

  /// The primary brand or action color.
  final Color primary;

  /// The standard background color for screens and pages.
  final Color background;

  /// The surface color for cards, buttons, and elevated elements.
  final Color surface;

  /// The primary text color, typically for headings and body content.
  final Color textPrimary;

  /// The secondary text color, typically for captions and placeholders.
  final Color textSecondary;

  /// The standard border color for containers and inputs.
  final Color border;

  /// The color used to indicate error states.
  final Color error;

  /// The color used for warning states or highlight badges.
  final Color warning;
}
