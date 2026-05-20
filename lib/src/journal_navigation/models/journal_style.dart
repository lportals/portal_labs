import 'package:flutter/material.dart';

/// Style configuration for the [JournalNavigation] component.
///
///
/// Allows customizing colors, dimensions, and text styles to match
/// your application's design system.
class JournalStyle {
  /// Creates a [JournalStyle] with the given visual properties.
  const JournalStyle({
    this.backgroundColor = const Color(0xFFF2EFE8),
    this.borderRadius = 32.0,
    this.sliderWidth = 44.0,
    this.sliderColor = Colors.white,
    this.selectedDayColor = const Color(0xFFF2EFE8),
    this.unselectedDayColor = const Color(0xFFBCBCBC),
    this.navArrowBackgroundColor = Colors.white,
    this.navArrowColor = const Color(0xFF8E8E8E),
    this.navArrowDisabledColor = const Color(0xFFDCDCDC),
    this.headerMonthStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF8E8E8E),
    ),
    this.headerDayStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF8E8E8E),
    ),
    this.titleStyle = const TextStyle(
      fontSize: 20,
      height: 1.5,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
    ),
    this.contentStyle = const TextStyle(
      fontSize: 20,
      height: 1.5,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
    ),
    this.shadows,
  });

  /// Factory for the default premium Portal Labs theme.
  factory JournalStyle.portalLabs() => const JournalStyle();

  /// Background color of the main container.
  final Color backgroundColor;

  /// Border radius of the main container.
  final double borderRadius;

  /// Width of the left date slider.
  final double sliderWidth;

  /// Color of the white pill slider background.
  final Color sliderColor;

  /// Color of the selected day indicator.
  final Color selectedDayColor;

  /// Text style for the month abbreviation in the header.
  final TextStyle headerMonthStyle;

  /// Text style for the day number in the header (FlipCounter style).
  final TextStyle headerDayStyle;

  /// Text style for the title of the selected item.
  final TextStyle titleStyle;

  /// Text style for the content of the selected item.
  final TextStyle contentStyle;

  /// Color of the navigation arrow icons.
  final Color navArrowColor;

  /// Color of the navigation arrow icons when disabled.
  final Color navArrowDisabledColor;

  /// Color of unselected days in the slider.
  final Color unselectedDayColor;

  /// Color of the navigation arrow background.
  final Color navArrowBackgroundColor;

  /// Shadow color and properties for the main container.
  final List<BoxShadow>? shadows;
}
