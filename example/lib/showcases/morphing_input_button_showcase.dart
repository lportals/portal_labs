import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class MorphingInputButtonShowcase extends StatelessWidget {
  const MorphingInputButtonShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Morphing Input Button',
      description:
          'Call-to-action button that morphs into a text input with a '
          'soft-focus blur reveal. Peak 1.5 sigma blur during transition '
          'creates a dreamy high-end feel. Fully theme-aware with granular style overrides.',
      codeSnippet: '''MorphingInputButton(
  buttonText: 'Notify Me',
  placeholder: 'Enter your email...',
  icon: Icons.notifications_rounded,
  initialWidth: 140.0,
  expandedWidth: 320.0,
  onSubmitted: (email) => print('Subscribed: \$email'),
)''',
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: MorphingInputButton(
                buttonText: 'Notify Me',
                placeholder: 'Enter your email...',
                icon: Icons.notifications_rounded,
                onSubmitted: (email) => _showSuccess(context, email),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Received: $value'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
