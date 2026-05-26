# Premium Progress Stepper

![Premium Progress Stepper Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/progress_step.gif)

A high-fidelity progress stepper designed for multi-step flows, featuring
physics-driven indicator animations and tactile button feedback.

#### Key Features

- **Spring-Driven Indicator**: A stretching pill animation that connects steps
  using real-world physics for a natural, "alive" feel.
- **Dynamic Navigation**: Automatically handles "Back" button visibility with a
  bounce entry after the first step.
- **Tactile Feedback**: Integrated button scale feedback and multi-level haptics
  for a premium mechanical sensation.
- **Dynamic Text States**: Smooth cross-fading of button labels (e.g.,
  "Continue" to "Finish") with synchronized icon transitions.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumProgressStepper(
  totalSteps: 3,
  currentStep: _currentStep,
  onStepChanged: (step) => setState(() => _currentStep = step),
  onFinish: () => print('Flow Completed!'),
  style: PremiumProgressStepperStyle(
    activeColor: Color(0xFF22C55E),
    primaryButtonColor: Color(0xFF007AFF),
  ),
)
```
