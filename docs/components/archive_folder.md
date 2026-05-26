# Archive Folder

![Archive Folder Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/archive_folder.gif)

A premium glassmorphic folder interaction that reveals its contents with staggered, physics-based animations, asymmetric reveal depths, and dual-orientation support.

#### Key Features

- **Asymmetric Reveal Physics**: Items slide out to unique depths and settle with individual tilts (±5°), creating a natural, hand-placed archival look.
- **Dynamic Z-Stacking**: Features a "Pop-to-Front" mechanism where tapping any item brings it to the foreground with an elastic spring scale effect (`Curves.elasticOut`).
- **Dual-Orientation Architecture**: Optimized for both vertical (upright) and horizontal (flat) layouts with intelligent hit-testing and coordinate-space adaptation.
- **Generic Item Architecture**: Supports any custom widget or use the included `ArchiveItem` for a classic archival frame with labels.
- **Total Sizing Control**: Fully dynamic dimensions—customize `folderWidth`, `folderHeight`, and `tabProtrusion` via the style model.
- **Premium Haptics**: Integrated selection haptics for item focus and light impact feedback for folder transitions.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

ArchiveFolder(
  title: 'Memories',
  subtitle: 'Collection 2026',
  style: ArchiveFolderStyle(
    folderColor: Color(0xFF30BB53),
    folderWidth: 175.0,
    folderHeight: 240.0,
  ),
  items: [
    ArchiveItem(
      label: 'TROUPIAL STAMP',
      child: Image.network('https://...'),
    ),
    // Or any other widget!
  ],
  onToggle: (isOpen) => print('Folder is $isOpen'),
  onItemTap: (index) => print('Tapped item $index'),
)
```
