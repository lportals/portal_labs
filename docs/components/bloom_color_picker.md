# Bloom Color Picker

A premium color picker with a "Bloom" concentric peeling expansion effect, radial dual-ring color wheel, and dynamic lightness slider.

#### Key Features

- **Concentric Peeling Ring Expansion**: Smooth opening transition powered by a custom painter that starts as a solid filled circle matching the closed button (with a white border and drop shadow) and concentrically peels open from the center outward to reveal a thin outer ring.
- **Dynamic Background Bloom**: A soft background glow and blur that scales and fades in from transparent, avoiding sudden visual pops.
- **Dual-Ring Swatch Layout**: Coordinates 12 vibrant colors on an outer ring and 6 pastel variants on an inner ring, mathematically mapped using polar coordinates.
- **Tactile Lightness Slider**: An elegant arc slider positioned outside the color wheel that lets users adjust the lightness of the selected color base with real-time feedback.
- **Seamless Staggered Entrance & Unified Exit**: Color swatches bloom outward with custom staggered ease-out timings, and collapse back to the center simultaneously in a unified motion upon closing.
- **Interactive Hex Input Pill**: A collapsible, editable hex code text field with input validation, support for checking, editing, and soft image filter transitions.
- **Flexible Layout Alignment**: Supports placing the color circle indicator on either the left or right of the hex code text pill via `BloomColorPickerAlignment`.

#### Integration

```dart
import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

// Basic Usage
BloomColorPicker(
  initialColor: _currentColor,
  onColorChanged: (color) {
    setState(() {
      _currentColor = color;
    });
  },
  style: const BloomColorPickerStyle(
    closedRadius: 24.0,
    showHexPill: true,
    alignment: BloomColorPickerAlignment.circleLeft,
  ),
)

// With Custom Base Swatch Colors
BloomColorPicker(
  initialColor: _currentColor,
  onColorChanged: (color) => setState(() => _currentColor = color),
  colors: const [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ],
)
```
