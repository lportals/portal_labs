# Coverflow Carousel

A premium 3D Coverflow carousel widget inspired by the classic iPod interface. It displays a list of children in 3D perspective, rotated around the Y-axis (in horizontal mode) or X-axis (in vertical mode), overlapping toward the center. It supports horizontal/vertical swipe gestures, tapping on side cards to bring them to the center, and dual-interactive scrolling via a custom slider track.

![Coverflow Carousel Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/coverflow_carousel.gif)

#### Key Features

- **Dual-Orientation Support**: Seamlessly switch between horizontal and vertical layouts using the `scrollDirection` parameter.
- **3D Perspective Projection**: Implements realistic 3D transformation matrices with configurable perspective depth, scale variance, and axis rotation angles (rotated around the Y-axis for horizontal flow and the X-axis for vertical flow).
- **Left-Side Vertical Reflections**: Includes automatic layout adaptations for reflections. In vertical mode, card reflections are placed on the left side to prevent overlapping with controls and the slider track.
- **Symmetric Depth Sorting (Z-Ordering)**: Automatically calculates active center distances and paints background cards in reverse order, avoiding visual clipping issues.
- **Tactile Dragging & Sliders**: Includes horizontal/vertical gestures directly on cards and a synced, animated slider track (placed below in horizontal mode, or on the right side in vertical mode) that behaves as a unified scroll controller.
- **Clipping & Bounds Protection**: Automatically configures strict layout clipping (`Clip.hardEdge`) and optimized card fade-outs when in vertical mode to ensure it fits perfectly within bounds.
- **Programmatic Controller API**: Exposes `CoverflowCarouselController` to easily trigger smooth springs or jump directly to specific cards from outside.
- **Haptic Boundary Crossings**: Integrated high-fidelity haptic feedback triggers light impacts as cards cross visual thresholds.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

final controller = CoverflowCarouselController(initialPage: 2);

CoverflowCarousel(
  controller: controller,
  scrollDirection: Axis.vertical, // Supports Axis.horizontal and Axis.vertical
  onIndexChanged: (index) => print('Active card index: $index'),
  style: const CoverflowCarouselStyle(
    cardWidth: 200.0,
    cardHeight: 260.0,
    borderRadius: 16.0,
    showSlider: true,
    showIndexIndicator: true,
  ),
  children: [
    Container(color: Colors.red, child: const Center(child: Text('Card 0'))),
    Container(color: Colors.blue, child: const Center(child: Text('Card 1'))),
    Container(color: Colors.green, child: const Center(child: Text('Card 2'))),
  ],
)
```
