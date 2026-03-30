import 'package:flutter/material.dart';

/// A central hub for internal "Zero-Dependency" utilities.
///
/// These are lightweight, functional helpers designed specifically for
/// the Portal Labs component library to avoid relying on external packages
/// like 'intl' or 'lucide'.
class PortalUtils {
  /// Simple list of abbreviated month names.
  static const List<String> shortMonths = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Simple list of full month names.
  static const List<String> fullMonths = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Simple list of weekday initials.
  static const List<String> weekdayInitials = [
    '',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  /// Formats a month number (1-12) to its short string representation.
  static String formatMonthShort(int month) {
    if (month < 1 || month > 12) return '';
    return shortMonths[month];
  }

  /// Formats a month number (1-12) to its full string representation.
  static String formatMonthFull(int month) {
    if (month < 1 || month > 12) return '';
    return fullMonths[month];
  }

  /// Pads a numeric value with a leading zero if less than 10.
  /// Useful for days, hours, or minutes.
  static String padZero(int value) {
    return value.toString().padLeft(2, '0');
  }

  /// Measures the exact size of a text string with a given style.
  /// Essential for layout-sensitive components like Flip Counters.
  static Size measureText(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }

  /// Formats a number with comma separators.
  /// Example: 1234567 -> "1,234,567"
  static String formatNumber(int value) {
    String str = value.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return str.replaceAllMapped(reg, (Match m) => '${m[1]},');
  }

  /// Formats a number as a currency string.
  /// Example: 9.99 -> "$9.99", 0.0 -> "$0.00"
  static String formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }
}
