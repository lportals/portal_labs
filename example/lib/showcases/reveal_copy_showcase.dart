import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class RevealCopyShowcase extends StatelessWidget {
  const RevealCopyShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Reveal & Copy',
      description:
          'Secure data masking with a shimmer reveal and clipboard animation. '
          'Designed for sensitive data like credentials or financial accounts. '
          'Auto-reverts to masked state after a configurable timeout.',
      codeSnippet: '''RevealCopyInteraction(
  value: '4485 2291 0034 7516',
  onCopied: () => print('Copied!'),
)''',
      child: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: RevealCopyInteraction(value: '4485 2291 0034 7516'),
          ),
        ),
      ),
    );
  }
}
