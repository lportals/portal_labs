# Folder Tabs

![Folder Tabs Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/folder_tabs.gif)

A physics-driven Manila file folder tab container featuring organic S-curve geometry and implicit height resizing. It overlays static tabs in the background, simulating a physical stacked filing drawer with perfect simplicity and dynamic proximity-based tab dissolving.

#### Key Features

- **Organic S-Curve Painter**: Uses custom bezier path drawing to render clean, identical S-curves that seamlessly morph into corner roundings at the edges.
- **Physical Depth Overlay**: Simulates a physical filing drawer with background tabs that cast soft shadows onto the active folder sheet.
- **Proximity-Based Dissolve**: Background tabs dynamically fade out and blend their colors as the active tab approaches, eliminating double-tab overlap artifacts.
- **Implicit Height Scaling**: Seamlessly expands and collapses its height using animated size constraints when transitioning between folders of different content lengths.
- **Dynamic Theme Customization**: Fully customize folder colors (e.g., Manila Beige, Steel Blue, Sage Green, Dark Charcoal), tab height, margins, border radii, and monospace typewriter label styles.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

FolderTabs(
  tabs: const ['Receipts', 'Contracts', 'Ideas'],
  style: const FolderTabsStyle(
    folderColor: Color(0xFFE6D7C3), // Warm Manila Beige
    tabHeight: 38.0,
    tabProtrusionWidth: 125.0,
    activeLabelStyle: TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w800,
      color: Color(0xFF2C2216), // Dark typewriter ink
      fontFamily: 'Courier',
    ),
  ),
  children: [
    _buildFileList(['uber-trip-0512.pdf', 'starbucks-coffee.pdf']),
    _buildFileList(['freelance-agreement.md', 'office-lease-v2.pdf']),
    _buildFileList(['app-wireframes.sketch', 'marketing-strategy.md']),
  ],
)
```
