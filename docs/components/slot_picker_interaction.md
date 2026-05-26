# Slot Picker Interaction

![Slot Picker Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/slot_picker_interaction.gif)

A premium, production- ready scheduling component that combines smooth spring
physics with a robust validation engine for professional availability
management.

#### Key Features

- **Collision Detection Engine**: Automatically identifies and highlights
  overlapping time slots with a subtle reddish background and border highlight,
  preventing data entry errors without breaking the flow.
- **Smart Validation**: Intelligent auto-correction that maintains logical
  ranges (e.g., automatically adjusting End Time when Start Time is moved beyond
  it) based on a configurable `validationInterval`.
- **Adaptive UI**: Context-aware time pickers that provide a native
  `CupertinoDatePicker` on iOS/macOS and a sleek Material `showTimePicker` on
  other platforms, both synchronized with the slot interval.
- **Physics-Based Motion**: High-fidelity expansion and removal animations using
  spring simulations for a tactile, "bouncy" feel that feels rooted in physical
  reality.
- **Total Customization**: 15+ style properties in `SlotPickerStyle` covering
  granular typography, specific action colors (delete button), and adjustable
  paddings for perfect layout balancing.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SlotPickerInteraction(
  items: [
    SlotPickerItem(title: 'Monday', slots: [
      SlotRange(startTime: TimeOfDay(hour: 9, 0), endTime: TimeOfDay(hour: 17, 0)),
    ]),
  ],
  validationInterval: Duration(minutes: 30),
  enableOverlapDetection: true,
  style: SlotPickerStyle(
    activeSwitchColor: Colors.deepPurple,
    borderRadius: BorderRadius.circular(18),
  ),
  onSlotChanged: (index, range) => print('Updated slot $index'),
)
```
