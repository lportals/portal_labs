# Swipeable Action Tile

![Swipeable Action Tile Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/swipeable_action_tile.gif)

A premium physics-based swipeable list tile that reveals custom actions with momentum and spring snapping.

#### Key Features

- **Bidirectional Swiping**: Supports dragging left-to-right to reveal start actions and right-to-left to reveal end actions.
- **Momentum & Friction**: Implements custom friction when dragging past limits or when no actions exist.
- **Spring Physics Engine**: Uses `SpringSimulation` for a natural, momentum-based expansion and collapse feel that matches premium OS interactions.
- **Micro-animations & Stretch**: Circle action buttons dynamically scale, fade, and stretch depending on the drag offset.
- **Total Reusability**: Fully decoupled widget/style architecture exposing `SwipeableActionTileStyle` to customize spring description, haptics, and sizes.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SwipeableActionTile(
  onTap: () {
    print("Tile tapped!");
  },
  startActions: [
    SwipeAction(
      icon: const Icon(Icons.check, color: Colors.white),
      backgroundColor: Colors.blue,
      onTap: () => print("Marked as read"),
    ),
  ],
  endActions: [
    SwipeAction(
      icon: const Icon(Icons.delete, color: Colors.white),
      backgroundColor: Colors.red,
      onTap: () => print("Deleted"),
    ),
  ],
  child: const MessageCard(),
)
```
