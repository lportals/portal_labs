# Stacked Toast Interaction

![Stacked Toast Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/interaction_toast.gif)

Individual toasts that arrive from the top and stack behind each other when
multiple notifications are active, featuring high-fidelity transitions and
professional aesthetics.

#### Key Features

- **Professional Top Arrival**: Toasts slide down from the top edge using a
  refined `easeOutCubic` curve for a native system-like feel.
- **Intelligent 3D Stacking**: Previous toasts are pushed back into a
  multi-layered stack with symmetric scaling and opacity to focus on the active
  alert.
- **Action Callbacks & Labels**: Support for interactive buttons with custom
  labels (`actionLabel`) and logic (`onAction`), supporting flows like "Retry"
  or "Undo".
- **Total UI Builder**: A `builder` property allows for 100% custom toast
  layouts while inheriting the physics and stacking logic.
- **Granular Customization**: Full control over icons, typography (`TextStyle`),
  colors, and shapes at both a global and individual level.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

// 1. Initialize the controller
final _toastController = StackedToastController();

// 2. Place the interaction widget (usually at the root Stack or Scaffold)
StackedToastInteraction(
  controller: _toastController,
  style: StackedToastStyle(
    topMargin: 10.0, // Precise alignment relative to the notch
  ),
)

// 3. Trigger a high-fidelity toast
_toastController.show(
  StackedToastItem(
    id: DateTime.now().toString(),
    title: 'New Suggestion',
    message: 'Optimization tips are available.',
    type: StackedToastType.info,
    actionLabel: 'View',
    onAction: () => print('Opening tips...'),
  ),
);
```
