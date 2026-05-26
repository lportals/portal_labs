# Inline Delete Interaction

![Inline Delete Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/inline_delete.gif)

A premium interaction component featuring a high-fidelity inline destructive confirmation flow that transitions vertically while maintaining structural stability.

#### Key Features

- **Inline Confirmation Flow**: A specialized interaction where a destructive action transforms vertically into a confirmation state using physics-based transitions.
- **Physics-Based Transitions**: Uses `SpringSimulation` to achieve a tactile, elastic "bounce" during confirmation flows.
- **Staggered Entry**: Built-in support for orchestrated item reveal animations via external controllers.
- **Geometric Harmony**: Automatically calculates concentric corner radii based on container padding for a premium, hardware-inspired aesthetic.
- **Flexible & Context-Agnostic**: Pure widget architecture that can be embedded in any container (modals, sheets, or inline lists) without managing complex overlays internally.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

InlineDeleteInteraction(
  title: 'More Options',
  onCloseRequested: () => Navigator.pop(context),
  items: [
    InlineAction(
      title: 'Edit',
      icon: Icons.edit_outlined,
      onTap: () => print('Edit action'),
    ),
    InlineAction(
      title: 'Delete',
      icon: Icons.delete_outline,
      isDestructive: true,
      confirmLabel: 'Delete Now',
      onTap: () => print('Delete confirmed'),
    ),
  ],
  style: InlineDeleteStyle(
    rowHeight: 52,
    enableHaptics: true,
  ),
)
```
