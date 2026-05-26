# Discovery Bar

![Discovery Bar Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/discovery_bar.gif)

A premium morphing search and discovery component that transitions between
discovery categories and a search input with fluid, elastic containers.

#### Key Features

- **Morphing Containers**: Dual containers that physically expand and shrink in
  place for a seamless transition.
- **Micro-Bounce Physics**: Custom-tuned cubic curves with 10% overshoot for a
  premium tactile feel.
- **Micro-Scale Interactions**: High-performance tap feedback on all text and
  icons for a "bouncy" experience.
- **Zero-Dependency Semantic Support**: Intelligent focus management and
  Material semantics without third-party debt.

#### Integration

```dart
DiscoveryBar(
  options: const [
    DiscoveryOption(label: 'Popular', icon: Icons.local_fire_department_rounded),
    DiscoveryOption(label: 'Favorites', icon: Icons.favorite_rounded),
  ],
  onOptionSelected: (option) => print('Selected: ${option.label}'),
  onSearchSubmitted: (query) => print('Searching for: $query'),
)
```
