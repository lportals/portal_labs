# Media Collapsible View

![Media Collapsible View Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/media_collapsible_view.gif)

A high-fidelity, Reels-inspired interaction component that transitions between a
full-screen media view and a detailed, gesture-driven interactive comment sheet.

#### Key Features

- **Fluid Coordinate Scaling**: Mathematical transition between full-frame and
  scaled-down media layouts using a shared stack architecture.
- **Dual-Phase Gesture Handling**: Integrated gesture handover between
  bottom-sheet dragging and internal list scrolling for a seamless "hand-off"
  feel.
- **Dynamic Blur Layering**: High-performance background blur layering that
  simulates real-time color bleeding without GPU overhead.
- **Zero-Dependency Media Builder**: Decoupled architecture using `mediaBuilder`
  to inject any video or interaction engine without adding external library
  debt.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

MediaCollapsibleView(
  mediaUrl: 'https://luisportal.com/assets/thumbnail.jpg', // Used for background blur
  userAvatarUrl: 'https://luisportal.com/assets/user_avatar.jpg',
  comments: [
    MediaComment(
      id: '1', 
      userName: 'portal_dev', 
      text: 'This UI interaction is absolutely stunning!', 
      avatarUrl: 'https://luisportal.com/assets/avatar.jpg', 
      createdAt: DateTime.now()
    ),
  ],
  style: MediaViewStyle(
    accentColor: Colors.blueAccent,
    sheetBackgroundColor: Color(0xFF141416),
  ),
  onSendComment: (text) => print('Comment: $text'),
)
```
