import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import 'package:portal_labs/src/emotion_selector/models/emotion_selector_style.dart';
import 'package:portal_labs/src/emotion_selector/emotion_selector.dart';
import '../showcase_shell.dart';

class EmotionSelectorShowcase extends StatefulWidget {
  const EmotionSelectorShowcase({super.key});

  @override
  State<EmotionSelectorShowcase> createState() => _EmotionSelectorShowcaseState();
}

class _EmotionSelectorShowcaseState extends State<EmotionSelectorShowcase> {
  EmotionStyle? _lastSelected;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Emotion Selector',
      description: 'A premium, physics-based emotion selector modeled after modern health tracking UIs. Features interruptible spring animations, layout morphing, and haptic feedback.',
      backgroundColor: const Color(0xFF111111),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            EmotionSelector(
              title: 'How are you feeling?',
              onSubmitted: (index) {
                setState(() {
                  _lastSelected = const EmotionSelectorStyle().emotionStyles[index];
                });
              },
              expandedContentBuilder: (context, index) {
                return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min, // This prevents the inner column from expanding infinitely!
                              children: [
                                const Text(
                                'Emotions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Divider(color: Colors.white.withValues(alpha: 0.3), height: 1),
                              const SizedBox(height: 6),
                              const Text(
                                'Context',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ), // closes inner Column
                        ), // closes SingleChildScrollView
                      ), // closes Container
                    ), // closes BackdropFilter
                  ); // closes ClipRRect
            },
            ),
            const SizedBox(height: 24),
            if (_lastSelected != null)
              Text(
                'Last logged: ${_lastSelected!.label}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
      codeSnippet: '''
EmotionSelector(
  onSubmitted: (index) {
    print('Selected index: \$index');
  },
  expandedContentBuilder: (context, index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Emotions', style: TextStyle(color: Colors.white)),
        Divider(),
        Text('Context', style: TextStyle(color: Colors.white70)),
      ],
    );
  },
)
''',
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}
