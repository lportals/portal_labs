# Collapsible Notification Panel

![Collapsible Notification Panel Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/collapsible_notification.gif)

A premium, highly interactive notification panel that can collapse into a
summary header and expand to show a list of activities with spring-based
animations.

#### Key Features

- **Spring Physics Animation**: Natural, momentum-based expansion and collapse
  transitions.
- **Staggered Entry**: Each notification item animates in with a calculated
  delay for a high-end polished feel.
- **Header Summary**: Displays a clean "X New Activities" header with a subtitle
  when collapsed.
- **Interactive Haptics**: Responsive scale effects on all pressable elements
  (`scale(0.97)`).
- **Concentric 'Island' Design**: Premium structural layout with
  glassmorphism-inspired layering and refined typography.
- **Fully Themeable Architecture**: Complete control over colors, gradients,
  typography, and physics via the `CollapsibleNotificationPanelStyle` object.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

CollapsibleNotificationPanel(
  items: [
    NotificationItem(
      id: '1',
      title: 'Diego Sent a Message',
      description: '"Hey! Did you check the new spring animations?"',
      timestamp: 'Just Now',
      icon: Icons.chat_bubble_rounded,
    ),
    NotificationItem(
      id: '2',
      title: 'Upcoming Event',
      description: 'Daily Sync starts in 15 minutes.',
      timestamp: '15m ago',
      icon: Icons.calendar_month_rounded,
    ),
  ],
  onItemTap: (item) => print('Tapped: ${item.title}'),
)
```
