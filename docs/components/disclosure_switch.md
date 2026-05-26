# Disclosure Switch

![Disclosure Switch Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/switch_disclosure.gif)

A premium, high-fidelity switch component that "discloses" or reveals additional
content when toggled on, featuring a unique "Island" design and an
elastic-bounce interaction pattern.

#### Key Features

- **Island Header Design**: The primary control is wrapped in a concentric grey
  inset card, separated by 2px from the main border for a high-end "layered"
  look.
- **Elastic Bounce Animation**: Uses `Curves.easeOutBack` to create a physical
  inertia effect where inner items slide and bounce into place independently of
  the container.
- **Context-Aware Geometry**: The main border and shadows are dynamic—appearing
  only when the section is active to maintain a clean, minimal UI in the idle
  state.
- **Pixel-Perfect Alignment**: Internal offsets are meticulously calculated to
  ensure sub-options (like checkboxes) align perfectly with the header icon's
  axis.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

DisclosureSwitch(
  title: 'Advanced Suggestions',
  value: _isAdvancedEnabled,
  onChanged: (val) => setState(() => _isAdvancedEnabled = val),
  icon: Icon(Icons.tune_rounded, color: Color(0xFF8E8E93)),
  revealedChild: Column(
    children: [
      _buildSubOption('Inline Suggestions', true),
      _buildSubOption('Auto-correct words', false),
      _buildSubOption('Smart Replies', true),
    ],
  ),
)
```
