# Discrete Tabs

![Discrete Tabs Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/discrete_tabs.gif)

A premium, zero-dependency minimalist navigation widget that expands like a pill
and features a subtle shimmer and slide effect on selection.

#### Key Features

- **Aesthetic Expansion**: High-fidelity bounce expansion curves transitioning
  seamlessly from a compact circle into a detailed pill.
- **Slide & Fade Shimmer**: Smooth linear gradient shimmer and sub-pixel slide
  interpolation that triggers elegantly across the label upon tab selection.
- **Controlled State**: Built with robust architecture offering both internal
  state for quick implementation and an external `currentIndex` for complete
  synchronization with other views.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

DiscreteTabs(
  currentIndex: _selectedPage, // Optional: for external control
  tabs: [
    DiscreteTab(
      label: 'Inbox',
      icon: Icons.mark_email_unread_rounded,
      activeColor: Color(0xFF007AFF),
    ),
    DiscreteTab(
      label: 'Planner',
      icon: Icons.grid_view_rounded,
      activeColor: Color(0xFFFF2D55),
    ),
  ],
  onSelect: (index) => setState(() => _selectedPage = index),
)
```
