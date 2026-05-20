import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class SlotPickerShowcase extends StatefulWidget {
  const SlotPickerShowcase({super.key});

  @override
  State<SlotPickerShowcase> createState() => _SlotPickerShowcaseState();
}

class _SlotPickerShowcaseState extends State<SlotPickerShowcase> {
  late final List<SlotPickerItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      SlotPickerItem(title: 'Monday'),
      SlotPickerItem(title: 'Tuesday'),
      SlotPickerItem(title: 'Wednesday'),
      SlotPickerItem(title: 'Thursday'),
      SlotPickerItem(title: 'Friday'),
      SlotPickerItem(title: 'Saturday'),
      SlotPickerItem(title: 'Sunday'),
    ];
  }

  void _handleToggle(int index, bool isEnabled) {
    setState(() {
      _items[index] = _items[index].copyWith(isEnabled: isEnabled);
    });
  }

  void _handleAddSlot(int index) {
    setState(() {
      final newSlots = List<SlotRange>.from(_items[index].slots);
      TimeOfDay start = const TimeOfDay(hour: 9, minute: 0);
      TimeOfDay end = const TimeOfDay(hour: 17, minute: 0);
      if (newSlots.isNotEmpty) {
        final last = newSlots.last;
        start = TimeOfDay(hour: (last.endTime.hour + 1) % 24, minute: 0);
        end = TimeOfDay(hour: (start.hour + 1) % 24, minute: 0);
      }
      newSlots.add(SlotRange(startTime: start, endTime: end));
      _items[index] = _items[index].copyWith(slots: newSlots);
    });
  }

  void _handleRemoveSlot(int itemIndex, int slotIndex) {
    setState(() {
      final newSlots = List<SlotRange>.from(_items[itemIndex].slots);
      newSlots.removeAt(slotIndex);
      _items[itemIndex] = _items[itemIndex].copyWith(slots: newSlots);
    });
  }

  void _handleSlotChanged(int itemIndex, int slotIndex, SlotRange newRange) {
    setState(() {
      final newSlots = List<SlotRange>.from(_items[itemIndex].slots);
      newSlots[slotIndex] = newRange;
      _items[itemIndex] = _items[itemIndex].copyWith(slots: newSlots);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Slot Picker',
      backgroundColor: Colors.white,
      description:
          'Availability picker with spring physics and real-time collision '
          'detection. Smart validation system with configurable validationInterval '
          'and auto-correcting logic. Native Cupertino/Material time pickers.',
      codeSnippet: '''SlotPickerInteraction(
  items: [
    SlotPickerItem(title: 'Monday'),
    SlotPickerItem(title: 'Tuesday'),
  ],
  onItemToggle: (index, enabled) => _toggle(index, enabled),
  onAddSlot: (index) => _addSlot(index),
  onRemoveSlot: (itemIdx, slotIdx) => _removeSlot(itemIdx, slotIdx),
  onSlotChanged: (itemIdx, slotIdx, range) => _update(itemIdx, slotIdx, range),
)''',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SlotPickerInteraction(
          items: _items,
          onItemToggle: _handleToggle,
          onAddSlot: _handleAddSlot,
          onRemoveSlot: _handleRemoveSlot,
          onSlotChanged: _handleSlotChanged,
        ),
      ),
    );
  }
}
