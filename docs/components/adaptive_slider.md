# Adaptive Slider

![Adaptive Slider Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/adaptive_slider.gif)

A value-aware interaction component where the visual state adaptively morphs
based on input thresholds.

#### Key Features

- **Morphing Gradients**: Linear color interpolation across the track based on
  defined thresholds.
- **Contextual Indicators**: Dynamic indicator points that recalculate their
  state on every frame.
- **Gradient Typography**: Value labels share the adaptive gradient of the
  active track.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

AdaptiveSliderInteraction(
  value: _val,
  colorSteps: [
    AdaptiveColorStep(threshold: 0.0, colors: [Colors.blue, Colors.cyan]),
    AdaptiveColorStep(threshold: 1.0, colors: [Colors.red, Colors.orange]),
  ],
  onChanged: (val) => setState(() => _val = val),
)
```
