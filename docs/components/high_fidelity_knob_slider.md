# High-Fidelity Knob Slider

![Knob Slider Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/knob_slider.gif)

A production-ready, interactive dial with a hardware-inspired aesthetic and a
mechanical odometer-style numeric display.

#### Key Features

- **Mechanical Reel Animated Counter**: Odometer-style vertical scrolling for
  numbers with dynamic motion blur that scales with rotation velocity.
- **Delta-Based Rotation Logic**: High-fidelity gesture tracking that calculates
  relative angular changes, eliminating the "dead-zone" jump common in standard
  circular sliders.
- **3D Depth Perception**: Digits fade and tilt as they "rotate" through the 3D
  window, creating a tactile depth effect without external assets.
- **Fully Customizable Style**: Every aspect of the knob—from tick frequency and
  thickness to shadow depth and ring colors—is configurable via
  `KnobSliderStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

KnobSlider(
  value: _currentValue,
  min: 0,
  max: 100,
  step: 1,
  onChanged: (val) => setState(() => _currentValue = val),
  style: KnobSliderStyle(
    activeTickColor: Colors.blueAccent,
    knobScale: 0.6,
    totalTicks: 60,
  ),
)
```
