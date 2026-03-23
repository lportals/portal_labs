import 'package:flutter/material.dart';

class PortalColors {
  // Brand / Action
  final Color primary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color warning;

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
}
