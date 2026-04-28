import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class SplitButtonInteractionShowcase extends StatefulWidget {
  const SplitButtonInteractionShowcase({super.key});

  @override
  State<SplitButtonInteractionShowcase> createState() =>
      _SplitButtonInteractionShowcaseState();
}

class _SplitButtonInteractionShowcaseState
    extends State<SplitButtonInteractionShowcase> {
  void _onAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: $action'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Split Button',
      backgroundColor: const Color(0xFFF2F2F7),
      description:
          'Morphing action menu where a primary button becomes a horizontal '
          'navigation pill. Synchronized slide with opacity and blur. '
          'Elastic pop bounce and motion blur text emergence on close.',
      codeSnippet: '''SplitButtonInteraction(
  initialLabel: 'New Project',
  onBack: () => print('Collapsed'),
  actions: [
    SplitAction(
      label: 'iOS',
      icon: Icons.apple_rounded,
      onTap: () => print('iOS'),
    ),
    SplitAction(
      label: 'Web',
      icon: Icons.language_rounded,
      onTap: () => print('Web'),
    ),
  ],
)''',
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SplitButtonInteraction(
                initialLabel: 'New Project',
                actions: [
                  SplitAction(
                    label: 'iOS',
                    onTap: () => _onAction('iOS'),
                    icon: Icons.apple_rounded,
                  ),
                  SplitAction(
                    label: 'macOS',
                    onTap: () => _onAction('macOS'),
                    icon: Icons.laptop_mac_rounded,
                  ),
                  SplitAction(
                    label: 'tvOS',
                    onTap: () => _onAction('tvOS'),
                    icon: Icons.tv_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
