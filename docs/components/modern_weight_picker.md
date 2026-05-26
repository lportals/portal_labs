# Modern Weight Picker

![Weight Picker Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/weight_picker.gif)

A precision-engineered ruler interface for numeric input, optimized for tactile
feedback and high-accuracy selection.

#### Key Features

- **Custom-Painted Ruler**: High-resolution track with distinct major/minor
  increments.
- **Magnetic Snapping**: Centered alignment logic that snaps to the nearest
  precision point.
- **Low-Latency Feedback**: Real-time value synchronization optimized for 60fps
  interaction.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

ModernWeightPicker(
  initialValue: 75.0,
  onValueChanged: (weight) => print('Selection: $weight'),
)
```
