# Range Selection Slider

![Range Selection Slider Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/range_slider.gif)

A high-end range selection component featuring a stylized slider and mechanical
3D counters with manual input support.

#### Key Features

- **Mechanical 3D Flip Counters**: Independent digit animations responding to
  range adjustments.
- **Manual Input Support**: Seamlessly transition from flip counters to manual
  text entry on tap.
- **Adaptive Formatting**: Built-in support for localized numeric formatting and
  currency symbols.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

RangeSelectionSlider(
  values: const RangeValues(640, 2380),
  onChanged: (values) => print("Range adjusted"),
)
```
