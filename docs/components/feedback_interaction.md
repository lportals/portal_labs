# Feedback Interaction

![Feedback Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/feedback_interaction.gif)

A premium, high-fidelity feedback component that uses asymmetric spring physics to transition between selection states. Designed for high-fidelity tactile response and zero-latency interaction.

#### Key Features

- **Elastic Spring Physics**: Powered by a custom `SpringSimulation` engine that supports natural overshoots and interruptible motion.
- **Asymmetric Transitions**: Distinct physical parameters for opening and closing (Undo) states to provide a "magnetic" and stable return.
- **Geometric Harmony**: A specialized morphing architecture where buttons perfectly track the container's expansion, eliminating jitter and alignment drift.
- **Zero-Latency Reset**: Smart early-interactivity logic restores touch responsiveness before the physics fully settle.
- **Total Customization**: 15+ customizable properties via `FeedbackInteractionStyle`, including stiffness, damping, and blur intensity.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

FeedbackInteraction(
  message: 'Thanks for your feedback!',
  onPositive: () => print('Positive feedback'),
  onNegative: () => print('Negative feedback'),
  onUndo: () => print('Action undone'),
  style: FeedbackInteractionStyle(
    springStiffness: 240.0,
    springDamping: 18.0,
    enableHaptics: true,
  ),
)
```
