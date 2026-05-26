# Labeled Progress Indicator

![Labeled Progress Indicator Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/labeled_progress_indicator.gif)

A production-ready, high-fidelity progress indicator designed for sequential
loading flows (onboarding, processing) with a focus on tranquil label
transitions.

#### Key Features

- **Dynamic Stage Management**: Support for `ProgressStage` objects allowing for
  non-uniform loading thresholds and custom labels.
- **Tranquil Transitions**: Labels enter/exit using a sophisticated combination
  of **Skew-X**, **Motion Blur**, and **Elastic Bounce** for a premium
  "air-focus" feel.
- **Size-Independent Shimmer**: A global-coordinate shimmer system that remains
  consistent in speed and scale regardless of the progress bar width.
- **Robust State Handling**: Integrated support for `onComplete` callbacks and
  customizable `isError` states with fallback labels.
- **Deep Customization**: Fully configurable typography, shimmer colors, height,
  and optional percentage display via `LabeledProgressIndicatorStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

LabeledProgressIndicator(
  progress: _currentProgress,
  stages: [
    ProgressStage(label: 'Consulting', endProgress: 0.1),
    ProgressStage(label: 'Processing', endProgress: 0.8),
    ProgressStage(label: 'Completed', endProgress: 1.0),
  ],
  onComplete: () => print('Done!'),
  isError: _hasFailed,
  errorLabel: 'Connection timed out',
  style: LabeledProgressIndicatorStyle(
    progressColor: Color(0xFF007AFF),
    shimmerColor: Color(0xFF00FBFF),
  ),
)
```
