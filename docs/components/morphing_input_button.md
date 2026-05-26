# Morphing Input Button

![Morphing Input Button Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/morphing_input_button.gif)

A high-fidelity interaction where a call-to-action button (e.g., "Notify Me")
seamlessly morphs into a text input field, featuring a premium soft-focus reveal
effect.

#### Key Features

- **Soft-Focus Reveal**: During the transition, the input text and placeholder
  gently blur (peak 1.5 sigma) and then come into perfect focus for a dreamy,
  high-end feel.
- **Aesthetic Expansion Curve**: Uses a specialized `easeOutBack` spring
  animation for the button-to-input morph.
- **Premium Flat Design**: Minimalist and shadow-free architecture (flat UI)
  that fits perfectly into modern high-end applications and design systems.
- **Fully Theme-Aware**: Automatically inherits colors and text styles from your
  `ThemeData`, with granular overrides for background and button colors.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

MorphingInputButton(
  buttonText: 'Notify Me',
  placeholder: 'Enter your email...',
  icon: Icons.notifications_rounded,
  onSubmitted: (email) => print('Subscribed: $email'),
  initialWidth: 140.0,
  expandedWidth: 320.0,
)
```
