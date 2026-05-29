import 'package:flutter/widgets.dart';

/// Represents a single selectable option inside the [QuickPickerInteraction].
class QuickPickerOption {
  /// Creates a [QuickPickerOption].
  const QuickPickerOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  /// The unique value or identifier of this option.
  final String value;

  /// The text label to display for this option.
  final String label;

  /// The icon to display for this option.
  final IconData icon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickPickerOption &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          label == other.label &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(value, label, icon);

  @override
  String toString() =>
      'QuickPickerOption(value: $value, label: $label, icon: $icon)';
}
