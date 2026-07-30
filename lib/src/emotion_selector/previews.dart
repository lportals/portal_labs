import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'emotion_selector.dart';

/// Preview for the idle state of the EmotionSelector.
@Preview(name: 'Idle State', group: 'Emotion Selector', size: Size(400, 400))
Widget emotionSelectorIdlePreview() {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: EmotionSelector(
        title: 'How are you feeling?',
        onSubmitted: (index) {},
        expandedContentBuilder: (context, index) {
          return const Text(
            'Expanded Content',
            style: TextStyle(color: Colors.white, fontSize: 16),
          );
        },
      ),
    ),
  );
}
