# Sortable Grid

![Sortable Grid Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/sortable_grid.gif)

A premium, physics-based reorderable grid designed for high-end organization and
layout management.

#### Key Features

- **Physics-Based Reordering**: Intelligent item flow using `AnimatedPositioned` with customizable easing curves.
- **Pulse-on-Hold Interaction**: Dedicated `AnimationController` manages a "lifting" pulse effect while holding an item before drag.
- **Tactile Haptics**: Light-impact feedback on drag start and drop for a hardware-inspired feel.
- **Dynamic Layout Stability**: Automatic recalculation of item dimensions and grid height to prevent layout jumps during column changes.
- **Total Design Freedom**: Fully customizable style including `borderRadius`, `spacing`, `dragScale`, and `dragOpacity` via `PremiumSortableGridStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumSortableGrid<String>(
  items: _items,
  idBuilder: (item) => item,
  onReorder: (oldIndex, newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  },
  style: PremiumSortableGridStyle(
    crossAxisCount: 3,
    spacing: 12.0,
    borderRadius: BorderRadius.circular(16),
  ),
  itemBuilder: (context, item) => Container(
    color: Colors.blue,
    child: Center(child: Text(item)),
  ),
)
```
