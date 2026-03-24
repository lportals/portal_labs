# Media Collapsible View 🎬

A high-fidelity, Reels-inspired interaction component that transitions between a full-screen media view and a detailed, gesture-driven interactive comment sheet. 

Built 100% in Flutter with **zero external dependencies**.

---

## 🚀 Key Features

*   **Fluid Coordinate Scaling**: Mathematical transition between full-frame and scaled-down media layouts using a shared stack architecture.
*   **Dual-Phase Gesture Handling**: Integrated gesture handover between bottom-sheet dragging and internal list scrolling for a seamless "hand-off" feel.
*   **Math-Driven Safe Area Scaling**: Native-safe area adaptive layouts that recalculate dimensions frame-by-frame based on the device's notch and bottom bars.
*   **Zero-Dependency Media Builder**: Decoupled architecture using `mediaBuilder` to inject any video or interaction engine without adding external library debt.

---

## 🛠 Advanced Implementation Guide

### 1. Professional Video Integration 📹
To keep the component "Zero Dependency", it uses a `mediaBuilder`. This allows you to inject any video engine (`video_player`, `chewie`, `flick_video_player`, etc.) seamlessly.

```dart
MediaCollapsibleView(
  mediaUrl: 'https://example.com/preview.jpg', // Used for background blur
  mediaBuilder: (context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  },
  // ... handle comments and interactions
)
```

### 2. Implementing the Reels Feed Logic 🎞️
To create the infinite vertical scroll typical of Reels/Shorts, wrap the component in a `PageView.builder`.

```dart
PageView.builder(
  scrollDirection: Axis.vertical, // THE SECRET: Vertical Axis
  itemCount: myReelsData.length,
  itemBuilder: (context, index) {
    final reel = myReelsData[index];
    return MediaCollapsibleView(
      mediaUrl: reel.thumbnailUrl,
      comments: reel.comments,
      mediaBuilder: (context) => MyVideoPlayer(url: reel.videoUrl),
      onSendComment: (text) => _submitComment(reel.id, text),
    );
  },
)
```

### 3. High-Performance Tips (Pro Tips) 🚀
1.  **Smart Video Preloading:** Don't initialize all videos at once. Use the `onPageChanged` callback of the `PageView` to start playing the current video and pause others.
2.  **Controller Cleanup:** Always ensure `controller.dispose()` is called to avoid memory leaks.
3.  **Blur Optimization:** The `blurAmount` in `MediaViewStyle` uses `ImageFilter.blur`. For maximum performance on older devices, keep this value below 30.

---

*This component was designed for high-performance and premium aesthetics inside Portal Labs.*
