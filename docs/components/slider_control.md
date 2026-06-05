# Slider Control

A premium vertical slider with a pill-shaped track, a gradient fill, and a floating value badge. Designed to feel like a tactile physical smart-home thermostat dial.

![Slider Control Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/slider_control.gif)

#### Key Features

- **Gradient Fill**: Displays a GPU-accelerated gradient fill (`CustomPainter`) morphing from low to high temperature colors.
- **Floating Value Badge**: A circular badge displaying the live value floats dynamically next to the fill level, fading in on interaction and fading out after 1.5 seconds of inactivity.
- **Bi-color Outer Ring**: The value badge is surrounded by a bi-color split arc ring highlighting the temperature threshold bounds.
- **Spring snap mechanics**: Values snap to the nearest step increment using a custom overdamped spring-physics settle animation when released.
- **Emil press scale**: The entire widget pill responds elastically to touch input, scaling down to `0.97` during gestures.
- **Tactile haptics**: Fires platform selection haptics (`HapticFeedback.selectionClick`) on every step crossing.
- **Tap-to-seek Gesture**: In addition to dragging, users can tap anywhere along the vertical track to instantly snap the slider's value.
- **Proportional Scaling**: Layout dimensions, label font sizes (`topLabel`/`bottomLabel`), and selector arrow shape dynamically scale relative to track size and tick dimensions to prevent overlapping or distortion under different scale sizes.
- **Capsule Symmetry**: Defaults to a border radius of `999.0` to preserve a perfect pill shape regardless of track width adjustments.
- **Customization Options**: Highly customizable appearance via `SliderControlStyle`, including badge positioning, custom limits text, haptic enabling, custom icon buttons, and arrow indicator selector color customization (`arrowColor`).
- **Flexible Callbacks**: Exposes both real-time drag/drag-to-seek progress updates (`onChanged`) and touch release finalization snaps (`onChangeEnd`).
- **Accessibility & Semantics**: Implements first-class VoiceOver/TalkBack support using Flutter `Semantics` for increments, decrements, and screen reader slider announcements.

#### Integration

```dart
import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

SliderControl(
  value: _temperature,
  min: 16,
  max: 30,
  step: 1,
  onChanged: (v) => setState(() => _temperature = v),
  onChangeEnd: (v) => print('User finished dragging at value: $v'),
  style: const SliderControlStyle(
    trackWidth: 68,
    lowColor: Color(0xFF5E5CE6),
    highColor: Color(0xFFFF453A),
    arrowColor: Color(0xFFFF453A), // Optional custom arrow selector color
    valueSuffix: '°',
    tickCount: 20,
    tickWidth: 12,
    ticksUseGradient: true,
    badgeAnchor: BadgeAnchor.right,
    bottomIcon: Icons.thermostat_rounded,
  ),
)
```
