import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class FeedbackInteractionShowcase extends StatelessWidget {
  const FeedbackInteractionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShowcaseShell(
      title: 'Feedback Interaction',
      description:
          'Premium physics-based feedback system with asymmetric spring morphing and liquid transitions.',
      codeSnippet: '''FeedbackInteraction(
  message: 'Thanks for your feedback!',
  onPositive: () => print('Positive'),
  onNegative: () => print('Negative'),
  onUndo: () => print('Undo'),
  style: FeedbackInteractionStyle(
    springStiffness: 240.0,
    springDamping: 18.0,
    enableHaptics: true,
  ),
)''',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [FeedbackInteraction()],
        ),
      ),
    );
  }
}
