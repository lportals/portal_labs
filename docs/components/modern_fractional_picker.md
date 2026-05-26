# Modern Fractional Picker

![Fractional Picker Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/fractional_picker.gif)

A high-fidelity horizontal ruler for precise numeric selection. Features
predictive magnetic snapping, customizable physics, and high-performance
rendering.

#### Key Features

- **Predictive Snap Landing**: Calculates the natural landing spot based on
  velocity and snaps to the nearest integer/decimal.
- **Customizable Physics**: Exposes `friction` and `snapStiffness` for a
  tailored tactile feel.
- **Performance Optimized**: Uses `AnimatedBuilder` and local painting cache for
  constant 60/120 FPS.
- **Haptic Precision**: Integrated selection haptics that fire exactly as the
  ruler crosses threshold points.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

ModernFractionalPicker(
  initialValue: 18.0,
  minValue: 0.0,
  maxValue: 100.0,
  decimalPlaces: 0,
  onValueChanged: (val) => print('Selected: $val'),
  style: FractionalPickerStyle(
    activeColor: Color(0xFF1D1D1F),
    friction: 0.22,
    snapStiffness: 100.0,
  ),
)
```
