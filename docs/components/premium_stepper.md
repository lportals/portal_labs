# Premium Stepper

![Premium Stepper Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/stepper_interaction.gif)

A minimalist tactile stepper component utilizing mechanical flip animations and
haptic feedback.

#### Key Features

- **Mechanical Odometer Counter**: Integrated `PremiumFlipCounter` for fluid
  numerical transitions.
- **Tactile Buttons**: Circular action buttons with scale-down feedback.
- **Haptic Integration**: Light-impact haptic feedback on value changes.
- **Minimalist Design**: Pill-shaped container with clean typography.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumStepper(
  value: _count,
  onChanged: (val) => setState(() => _count = val),
)
```
