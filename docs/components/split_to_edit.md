# Split to Edit

![Split to Edit Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/split_to_edit.gif)

A premium duration picker that "splits" from a unified view into separate
editable segments with a high-fidelity bounce transition.

#### Key Features

- **Bounce Split Transition**: Uses a specialized `ElasticOutCurve` to create a
  tactile "splitting" effect.
- **Segmented Morphing**: Backgrounds and corner radii dynamically interpolate
  between unified and standalone states.
- **Haptic Integration**: Subtle selection and impact haptics provide a premium
  "mechanical" feel.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SplitToEditDuration(
  hours: 1,
  minutes: 42,
  onChanged: (h, m) => print('New time: $h:$m'),
)
```
