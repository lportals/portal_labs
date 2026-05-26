# Quick Switcher

![Quick Switcher Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/quick_switcher.gif)

A premium, high-fidelity switch component that toggles between different input
modes with a pulse animation and smooth decorative transitions.

#### Key Features

- **Pulse Animation Engine**: Generates a synchronized scale and opacity pulse
  on the switch trigger for tactical feedback.
- **Smooth Morph Transitions**: Uses high-performance `AnimatedSwitcher` for
  sub-pixel interpolation of icons and hint text.
- **Adaptive Theme System**: Supports both light and dark aesthetics via the
  `QuickSwitcherStyle` configuration.
- **Haptic Integration**: Built-in specialized haptics for a "mechanical" click
  feel.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

QuickSwitcher(
  options: [
    QuickSwitcherOption(
      label: 'Ask Anything',
      icon: Icons.auto_awesome_rounded,
      placeholder: 'Ask Anything',
    ),
    QuickSwitcherOption(
      label: 'Generate Image',
      icon: Icons.image_rounded,
      placeholder: 'Generate Image',
    ),
  ],
  onOptionChanged: (index) => print('Switched to: $index'),
  onSubmitted: (feedback) => print('Feedback: $feedback'),
)
```
