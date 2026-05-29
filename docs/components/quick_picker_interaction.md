# Quick Picker Interaction

A premium option selector dropdown. Features smooth horizontal sliding segmented controls inside a floating bubble popover, character-by-character cinematic text sweep (without bounce), seamless icon blur-fades, instant pulse gestures, and a rotating arrow transition.

![Quick Picker Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/quick_picker_interaction.gif)

#### Key Features

- **Horizontal Segmented Capsule**: Expands options into a sleek horizontal segmented control above the trigger button, featuring a custom-painted anchor pointer triangle.
- **Cinematic Text Transition**: Character-by-character text sweep driven by clean linear ease-out curves (with elasticity disabled) for high-performance label shifts.
- **Icon Blur Transition**: An `AnimatedSwitcher` leveraging real-time Gaussian blurs (`ImageFilter.blur`) and spring-scale dynamics (`Curves.easeOutBack`) to organically swap icons.
- **Animated Chevron Rotation**: Smooth 180-degree rotation of the dropdown arrow chevron synchronized with the active menu state.
- **Instant Pulse Gestures**: Utilizes raw pointer event listener (`Listener`) targeting to bypass gesture arena scrolling delays, ensuring the tactile shrink scale pulse triggers immediately even inside scrollable widgets.
- **Snappy Dismiss & Close**: Designed with a responsive `80ms` selection delay and a `150ms` slide+fade exit curve for an instantaneous, hardware-like interaction response.
- **Highly Customisable Style**: Completely customizable layout padding, border radii, text styles, colors, transitions, and segment sizing via `QuickPickerStyle`.

#### Integration

```dart
import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

QuickPickerInteraction(
  options: const [
    QuickPickerOption(
      value: 'private',
      label: 'Private',
      icon: Icons.lock_rounded,
    ),
    QuickPickerOption(
      value: 'public',
      label: 'Public',
      icon: Icons.public_rounded,
    ),
  ],
  initialIndex: 0,
  onChanged: (index) {
    print('Selected index: $index');
  },
  style: const QuickPickerStyle(),
)
```
