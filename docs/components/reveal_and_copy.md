# Reveal & Copy

![Reveal & Copy Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/reveal_and_copy.gif)

A specialized interaction designed for the secure presentation and acquisition
of sensitive data (e.g., credentials, financial accounts).

#### Key Features

- **Secure Masking**: Configurable character masking with an automated shimmer
  reveal effect.
- **Timed Visibility**: Automatic reversion to masked state after a defined
  duration for enhanced security.
- **Integrated Micro-interactions**: Smooth clipboard integration with visual
  feedback.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

RevealCopyInteraction(
  value: '4485 2291 0034 7516',
  onCopied: () => print('Data copied to clipboard'),
)
```
