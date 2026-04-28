import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class QuickSwitcherShowcase extends StatefulWidget {
  const QuickSwitcherShowcase({super.key});

  @override
  State<QuickSwitcherShowcase> createState() => _QuickSwitcherShowcaseState();
}

class _QuickSwitcherShowcaseState extends State<QuickSwitcherShowcase> {
  final List<QuickSwitcherOption> _options = const [
    QuickSwitcherOption(
      label: 'Ask Anything',
      icon: Icons.auto_awesome_rounded,
      placeholder: 'Ask Anything',
    ),
    QuickSwitcherOption(
      label: 'Generate Image',
      icon: Icons.image_rounded,
      placeholder: 'Generate Image',
    ),
    QuickSwitcherOption(
      label: 'Analyze Files',
      icon: Icons.folder_zip_rounded,
      placeholder: 'Analyze Files',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Quick Switcher',
      backgroundColor: Colors.white,
      description:
          'Toggle component switching between input modes with a synchronized '
          'pulse animation on selection. Scale and opacity pulse provides '
          'tactile feedback. AnimatedSwitcher for sub-pixel icon interpolation.',
      codeSnippet: '''QuickSwitcher(
  options: [
    QuickSwitcherOption(
      label: 'Ask Anything',
      icon: Icons.auto_awesome_rounded,
      placeholder: 'Ask Anything',
    ),
    QuickSwitcherOption(
      label: 'Generate Image',
      icon: Icons.image_rounded,
      placeholder: 'Generate Image',
    ),
  ],
  onOptionChanged: (index) => print('Mode: \$index'),
  onSubmitted: (text) => print('Submitted: \$text'),
)''',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickSwitcher(
                options: _options,
                onOptionChanged: (index) {
                  debugPrint('Option: ${_options[index].label}');
                },
                onSubmitted: (text) => debugPrint('Submitted: $text'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
