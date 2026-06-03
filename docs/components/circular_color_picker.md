# Circular Color Picker

An interactive color selector arranged in a ring layout. Selecting a color slides it to the center using a spring physics animation, while the previously selected color slides back to its position in the outer ring.

![Circular Color Picker Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/circular_color_picker.gif)

#### Key Features

- **Polar Coordinate Layout**: Automatically positions items evenly around a circle using mathematical coordinates in the stack.
- **Center-bound Spring Physics**: Selected colors slide to the center using a spring physics simulation (`PortalSpringCurve`) and expand in size and border width.
- **Circle-bound Smooth Slide**: Deselected colors slide back to their outer ring positions using a smooth cubic easing transition (`Curves.easeInOutCubic`).
- **Style Flexibility**: Supports both hollow colored rings (with custom background fill) and solid colored circles using the `useSolidFill` configuration.
- **Dynamic Render Z-Ordering**: Active selecting items are sorted dynamically in the Stack to always render on top of the returning and static items.
- **Tactile Haptic Feedback**: Integrates platform haptic clicks (`HapticFeedback.lightImpact`) on selection changes.

#### Integration

```dart
import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

CircularColorPicker(
  colors: const [
    Color(0xFFFF5252),
    Color(0xFFFF7043),
    Color(0xFFFFCA28),
    Color(0xFFD4E157),
    Color(0xFF66BB6A),
    Color(0xFF26A69A),
    Color(0xFF26C6DA),
    Color(0xFF29B6F6),
    Color(0xFF42A5F5),
    Color(0xFF5C6BC0),
    Color(0xFFAB47BC),
    Color(0xFFEC407A),
    Color(0xFFFF8A80),
  ],
  selectedIndex: _selectedIndex,
  onChanged: (index) {
    setState(() {
      _selectedIndex = index;
    });
  },
  style: const CircularColorPickerStyle(
    fillColor: Color(0xFFFAFAFA),
    useSolidFill: false,
  ),
)
```
