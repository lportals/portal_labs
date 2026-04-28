import 'package:flutter/widgets.dart';

/// Represents an option in the [QuickSwitcher].
class QuickSwitcherOption {

  /// Creates a [QuickSwitcherOption].
  const QuickSwitcherOption({
    required this.label,
    required this.icon,
    required this.placeholder,
  });
  /// The label to display in the input field.
  final String label;

  /// The icon to display in the switch button.
  final IconData icon;

  /// The placeholder text for the input field.
  final String placeholder;
}
