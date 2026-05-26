# Journal Navigation

![Journal Navigation Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/journal_navigation.gif)

An aesthetic vertical navigation system designed for chronological content
exploration and high-end journal applications.

#### Key Features

- **Infinite Vertical Scroll**: Efficient scrolling logic supporting seamless
  date transitions.
- **Direction-Aware Flips**: 3D flip animations that indicate the scroll
  direction (past/future).
- **Modular Content Display**: Decoupled navigation logic allowing for any
  custom widget as the journal entry.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

JournalNavigation(
  items: [
    JournalItem(
      date: DateTime.now(),
      title: 'Project Inception',
      content: 'Core architecture finalized.',
    ),
  ],
  onDateChanged: (item) => print("Current view: ${item.title}"),
)
```
