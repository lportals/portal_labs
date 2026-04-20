import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class SlotPickerShowcase extends StatefulWidget {
  const SlotPickerShowcase({super.key});

  @override
  State<SlotPickerShowcase> createState() => _SlotPickerShowcaseState();
}

class _SlotPickerShowcaseState extends State<SlotPickerShowcase> {
  List<SlotPickerItem> _items = [
    const SlotPickerItem(title: 'Monday'),
    const SlotPickerItem(title: 'Tuesday'),
    const SlotPickerItem(title: 'Wednesday'),
    const SlotPickerItem(title: 'Thursday'),
    const SlotPickerItem(title: 'Friday'),
    const SlotPickerItem(title: 'Saturday'),
    const SlotPickerItem(title: 'Sunday'),
  ];

  void _handleToggle(int index, bool isEnabled) {
    setState(() {
      _items[index] = _items[index].copyWith(isEnabled: isEnabled);
    });
  }

  void _handleAddSlot(int index) {
    setState(() {
      final newSlots = List<SlotRange>.from(_items[index].slots);
      
      // Determine default times
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Slot Picker Interaction'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
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
