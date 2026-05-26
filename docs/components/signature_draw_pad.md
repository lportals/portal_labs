# Signature Draw Pad

![Signature Draw Pad Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/signature.gif)

A high-fidelity signature drawing component designed for professional applications requiring document integrity and a premium interaction feel.

#### Key Features

- **Signature Playback**: Integrated playback engine that re-draws the signature with adjustable duration and shimmer effects.
- **Off-Screen Export Engine**: Programmatic high-resolution PNG generation with automatic centering and aspect-ratio scaling via the controller.
- **Document Integrity Lock**: Automatically disables the canvas and hides editing tools once confirmed to ensure signature integrity.
- **Fluid State Transitions**: High-end state transitions for the confirmation flow using smooth blur dissolves and spring physics.
- **Customizable Color Palette**: Full control over palette colors with reactive state management that updates all existing strokes.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SignatureDrawPad(
  label: 'Authorize Transaction',
  onConfirm: () async {
    final image = await _controller.toImage(width: 800, height: 400);
    print('Signature captured as image');
  },
  style: SignatureDrawPadStyle(
    activeColor: Colors.black,
    confirmButtonText: 'HOLD TO SIGN',
  ),
)
```
