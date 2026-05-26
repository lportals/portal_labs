# Cinematic Text Transition

![Cinematic Text Transition Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/cinematic_text.gif)

A sophisticated text transition component that performs a sequential character **fall-out** and **rise-in** for a high-fidelity cinematic feel.

#### Key Features

- **Sequential Character Physics**: Characters exit by falling and enter by rising with a synchronized, staggered timing.
- **Elastic Settle**: New characters settle into place with a premium `easeOutBack` bounce for a tactile physical feel.
- **Stable Layout Architecture**: Uses a precise character-based Row system to ensure pixel-perfect stability during transitions.
- **Toggleable Elasticity**: Support for both "Cinematic Bounce" and "Minimalist Fade" modes via the style configuration.
- **Integrated Haptics**: Light-impact feedback triggers exactly as the transition sequence begins.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

CinematicTextTransition(
  text: 'Cinematic Transition',
  style: CinematicTextTransitionStyle(
    textStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    duration: Duration(milliseconds: 1400),
    enableElasticity: true,
  ),
)
```
