# Premium Choice Chips

![Premium Choice Chips Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/premium_choice_chips.gif)

An engaging multi-selection component supporting diverse media types and dynamic
animated transitions.

#### Key Features

- **Media Agnostic**: Native support for Unicode emojis, Material icons, and
  custom images.
- **Kinetic Transitions**: Selection events trigger a "landing" animation with
  flying media particles.
- **Directional Counter**: Integrated Odometer-style counter for real-time
  selection tracking.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumChoiceChips(
  items: [
    ChoiceItem(label: 'Design', icon: Icons.palette_outlined),
    ChoiceItem(label: 'Coffee', emoji: '☕'),
  ],
  onSelectionChanged: (selected) => print('Selected count: ${selected.length}'),
)
```
