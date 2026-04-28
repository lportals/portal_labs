import 'package:flutter/material.dart';

/// Represents a single time range slot.
class SlotRange {

  /// Creates a [SlotRange].
  const SlotRange({
    required this.startTime,
    required this.endTime,
  });
  /// The start time of the slot.
  final TimeOfDay startTime;
  /// The end time of the slot.
  final TimeOfDay endTime;

  /// Creates a copy of this [SlotRange] with the given fields replaced.
  SlotRange copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return SlotRange(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

/// Category/Day item for the [SlotPickerInteraction].
class SlotPickerItem {
  /// Creates a [SlotPickerItem].
  const SlotPickerItem({
    required this.title,
    this.isEnabled = false,
    this.slots = const [],
  });
  /// The display title (e.g., "Monday").
  final String title;
  /// Whether this item is currently active/enabled.
  final bool isEnabled;
  /// The list of time slots assigned to this item.
  final List<SlotRange> slots;

  /// Creates a copy of this [SlotPickerItem] with the given fields replaced.
  SlotPickerItem copyWith({
    String? title,
    bool? isEnabled,
    List<SlotRange>? slots,
  }) {
    return SlotPickerItem(
      title: title ?? this.title,
      isEnabled: isEnabled ?? this.isEnabled,
      slots: slots ?? this.slots,
    );
  }
}
