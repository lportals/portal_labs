# Tag Selection Interaction

![Tag Selection Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/tag_selection.gif)

A premium, zero-dependency "Magic Move" tag selection component that uses 100%
custom, Apple-inspired spring physics to animate tags seamlessly between
available and selected states.

#### Key Features

- **Apple Spring Simulator**: Replicates native IOS bounce and flight effects
  using a heavily damped harmonic oscillator (`_AppleSpringCurve`) without any
  external dependencies.
- **Fluid Wrap Engine**: Actively self-measures tags and calculates relative
  `Wrap` coordinates on-the-fly, allowing tags to physically fly between
  structured flowing layouts.
- **True Natural Sizing**: Bypasses conventional layout constraints by measuring
  system `TextScaler` rendering metrics to ensure pixel-perfect accessibility
  support without clipping.
- **High-Contrast Theming**: Beautiful dark/light active states featuring subtle
  drop shadows and premium typography transitions.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

TagSelectionInteraction(
  allTags: [
    TagModel(id: 'react', label: 'React'),
    TagModel(id: 'flutter', label: 'Flutter'),
  ],
  initialSelectedIds: const {'flutter'},
  onChanged: (selectedIds) => print('Selection updated: $selectedIds'),
  selectedTitle: 'YOUR STACK',
)
```
