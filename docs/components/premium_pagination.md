# Premium Pagination

![Premium Pagination Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/pagination_interaction.gif)

A premium, highly customizable navigation component with mechanical flip
animations and automatic layout stability.

#### Key Features

- **Mechanical Flip Counter**: Integrated `PremiumFlipCounter` for fluid,
  odometer-style page transitions.
- **Automatic Layout Stability**: Intelligent column width calculation based on
  total pages to prevent jumping.
- **Tactile Feedback**: Interactive buttons with `0.95x` scale feedback and
  integrated light-impact haptics.
- **Total Design Freedom**: Fully customizable style including
  `buttonBorderRadius`, `padding`, `borderWidth`, and arbitrary icons.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumPagination(
  currentPage: _currentPage,
  totalPages: 10,
  onPageChanged: (page) => setState(() => _currentPage = page),
)
```
