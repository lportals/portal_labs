# Stacked Cards

A premium, horizontal stacked card carousel driven by user swipe gestures. The active card resides in front, while subsequent cards stack neatly behind it with customizable rightward translation offsets and rotational slanting. Swiping left pushes the front card off the screen to reveal the next item, while swiping right recovers previously swiped cards.

![Stacked Cards Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/stacked_cards.gif)

#### Key Features

- **Kinetic Drag & Snap**: Smooth horizontal drag gestures tracking relative delta movements, paired with a custom spring curve (`PortalSpringCurve`) to snap cleanly onto card boundaries.
- **Clockwise Fan Effect**: Optional rotational slanting of background cards (toggled via `rotationEnabled`) for an elegant physical deck feel.
- **Dynamic Depth Layout**: Automates Z-ordering by rendering card lists in descending order, ensuring seamless layering during left/right swipes.
- **Morphing Dot Indicator**: A custom-drawn page indicator where the active dot smoothly morphs its width and color into a capsule pill driven by the scroll offset.
- **Settle-Limit Opacity Fading**: Background cards smoothly fade out as they get pushed past the configurable maximum visible card limit.
- **Haptic Feedback**: Integrates low-latency haptic vibrations (`HapticFeedback.lightImpact()`) as cards cross snapping thresholds.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

StackedCards(
  rotationEnabled: true,
  showsScrollIndicator: true,
  onIndexChanged: (index) => print('Active card index: $index'),
  style: const StackedCardsStyle(
    cardWidth: 280.0,
    cardHeight: 380.0,
    horizontalOffset: 24.0,
    scaleDelta: 0.04,
    rotationAngle: 0.08,
  ),
  children: [
    Container(color: Colors.red),
    Container(color: Colors.blue),
    Container(color: Colors.green),
  ],
)
```
