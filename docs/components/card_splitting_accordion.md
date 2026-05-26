# Card Splitting Accordion

![Card Splitting Accordion Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/card_splitting_accordion.gif)

A sophisticated layout component where cards dynamically merge and separate
based on their expansion state.

#### Key Features

- **Physical Splitting Logic**: Cards appear to physically separate from a
  cohesive block into standalone units.
- **Phase-Shifted Rounding**: Independent interpolation of corner radii and
  displacement for a natural feel.
- **Adaptive Theme System**: Comprehensive style injection via the
  `AccordionStyle` configuration.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

CardSplittingAccordion(
  items: [
    AccordionItem(
      title: 'UX Strategy',
      content: 'Finalizing the vision for user-centered design systems.',
      icon: Icons.mouse_rounded,
    ),
  ],
)
```
