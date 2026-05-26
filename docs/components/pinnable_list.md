# Pinnable List

![Pinnable List Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/pinnable_list.gif)

A high-fidelity, zero-dependency list component that manages "Pinned" and "All"
sections with a seamless Apple-style displacement animation.

#### Key Features

- **Self-Measuring Architecture**: Automatically measures item heights for
  pixel-perfect coordinates without hardcoded constants.
- **Spring Flight Physics**: Items physically slide ("fly") across the whole
  list with authentic inertia and a subtle elevation scale effect.
- **Smart Section Hand-off**: Integrated logic that transitions items between
  sections while maintaining a persistent Z-index for the "traveling" card.
- **Customizable Style**: Granular control over section headers, count badges,
  spacing, and sorting criteria via `PinnableListStyle` and `itemComparator`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PinnableList(
  items: [
    PinnableItem(id: '1', title: 'Work', icon: Icons.work_rounded),
    PinnableItem(id: '2', title: 'Personal', icon: Icons.person_rounded),
  ],
  onPinChanged: (id, isPinned) => print('Item $id pin state: $isPinned'),
)
```
