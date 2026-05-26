# Split Button Interaction

![Split Button Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/nested_pill_menu.gif)

A high-fidelity, zero-dependency action menu that seamlessly morphs from a
primary button into a horizontal navigation pill with synchronized
micro-animations.

#### Key Features

- **Dynamic Morphing Transition**: High-performance transformation from a
  primary action label into a back-navigation icon with a fluid, symmetric
  expansion.
- **Synchronized Action Slide**: Supplemental action items slide out from behind
  the main button with coordinated opacity, blur, and width interpolation.
- **Elastic Pop Bounce**: Symmetrical bidirectional "pop" effect upon menu
  closure, providing a tactile, hardware-inspired physical interaction.
- **Sophisticated Text Emergence**: High-end motion blur and clarify effect as
  the main label reappears during the closing transition, preventing visual
  artifacts.
- **Managed Controller API**: Built-in `SplitButtonController` for programmatic
  expansion, collapse, and toggle events.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SplitButtonInteraction(
  initialLabel: 'New Project',
  onBack: () => print('Menu collapsed'),
  actions: [
    SplitAction(
      label: 'iOS',
      icon: Icons.apple_rounded,
      onTap: () => print('Creating iOS project'),
      closeOnTap: true,
    ),
    SplitAction(
      label: 'Web',
      icon: Icons.language_rounded,
      onTap: () => print('Creating Web project'),
    ),
  ],
)
```
