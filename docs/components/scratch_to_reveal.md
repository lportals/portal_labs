# Scratch to Reveal

![Scratch to Reveal Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/scratch_to_reveal.gif)

A high-fidelity interaction that simulates the physical act of scratching a
surface to reveal hidden content, optimized for rewards programs and
"surprise-and-delight" features.

#### Key Features

- **Layered Blend Modes**: Uses advanced mathematical clearing of a
  custom-painted layer to reveal content in high-performance stacks.
- **Tactile Textures**: Features a procedurally generated diagonal grid pattern
  on the surface to mimic the appearance of physical scratch cards.
- **Intelligent Auto-Reveal**: Tracks scratch coverage and automatically fades
  out the remaining surface once a configurable success threshold is reached.
- **Integrated Action Header**: Includes a premium card layout with a brandable
  header and a smooth "Start again" reset mechanism.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

ScratchToReveal(
  title: 'Apple Credits',
  icon: Icons.apple_rounded,
  child: Center(
    child: Text(
      'You won \$24',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    ),
  ),
  onCompleted: () => print('Reward revealed!'),
)
```
