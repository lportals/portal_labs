import 'package:flutter/material.dart';

/// Centralized app theme and styling configurations for Portal Labs showcase.
class AppTheme {
  const AppTheme._();

  /// Dark slate color representing premium background or text.
  static const Color darkSlate = Color(0xFF1E293B);

  /// Subtle gray color for backgrounds.
  static const Color lightBackground = Color(0xFFFAFAFA);

  /// Light gray for dividers and borders.
  static const Color borderSubtle = Color(0xFFE2E8F0);

  /// Builds the default light theme for the application.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      fontFamily: 'Inter',

      // Clean, centered AppBar with minimal weight.
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black, size: 20),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),

      // Refined navigation icons.
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) =>
            const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      ),

      // Theme color scheme
      colorScheme: const ColorScheme.light(
        primary: darkSlate,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: darkSlate,
        outline: borderSubtle,
      ),

      // Zero visual noise on interactive elements.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }
}
