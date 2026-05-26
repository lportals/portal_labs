# Card Stack Interaction

![Card Stack Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/card_stack.gif)

A premium, interactive card stack designed for chronological content, featuring
a minimal "deck" aesthetic and a high-fidelity symmetric expansion animation.

#### Key Features

- **Symmetric Center Expansion**: Cards expand outwards from the center of the
  stack with an elastic `easeOutBack` curve for a tactile "pop" effect.
- **Layered Stacking Logic**: A specialized 3-level visual hierarchy that hides
  extra items behind the stack until expanded, maintaining a clean interface.
- **Synchronized Transitions**: Integrated `AnimatedCrossFade` and
  `AnimatedRotation` for the action button, ensuring smooth layout shifts and
  icon turns.
- **Fully Themeable**: Comprehensive style injection via `CardStackStyle`
  allowing complete control over card dimensions, spacing, offsets, and colors.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

CardStackInteraction(
  items: [
    CardStackItem(
      title: 'Camping',
      subtitle: 'Yosemite Park',
      date: '5 August',
      icon: Icons.terrain_rounded,
    ),
    CardStackItem(
      title: 'Boating',
      subtitle: 'Lake Tahoe Park',
      date: '2 August',
      icon: Icons.directions_boat_rounded,
    ),
  ],
  style: CardStackStyle(
    cardHeight: 90.0,
    cardSpacing: 16.0,
    buttonBackgroundColor: Colors.white,
  ),
  onExpansionChanged: (isExpanded) => print('Stack is $isExpanded'),
)
```
