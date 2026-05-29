import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// A showcase page demonstrating the [QuickPickerInteraction] component.
///
/// This showcase displays only the primary design showing the Privacy settings
/// selection, following the requested layout and strict component standards.
class QuickPickerShowcase extends StatefulWidget {
  /// Creates a [QuickPickerShowcase].
  const QuickPickerShowcase({super.key});

  @override
  State<QuickPickerShowcase> createState() => _QuickPickerShowcaseState();
}

class _QuickPickerShowcaseState extends State<QuickPickerShowcase> {
  int _selectedIndex = 0;

  final List<QuickPickerOption> _options = const [
    QuickPickerOption(
      value: 'private',
      label: 'Private',
      icon: Icons.lock_rounded,
    ),
    QuickPickerOption(
      value: 'public',
      label: 'Public',
      icon: Icons.public_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Quick Picker Interaction',
      description:
          'A premium option picker selector dropdown. Features smooth horizontal sliding segmented '
          'controls inside a floating bubble popover, character-by-character cinematic text sweep (without bounce), '
          'seamless icon blur-fades, and a rotating arrow transition.',
      backgroundColor: const Color(0xFFFAFAFA),
      codeSnippet: '''QuickPickerInteraction(
  options: const [
    QuickPickerOption(
      value: 'private',
      label: 'Private',
      icon: Icons.lock_rounded,
    ),
    QuickPickerOption(
      value: 'public',
      label: 'Public',
      icon: Icons.public_rounded,
    ),
  ],
  initialIndex: _selectedIndex,
  onChanged: (index) => setState(() => _selectedIndex = index),
  style: const QuickPickerStyle(),
)''',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QuickPickerInteraction(
                  key: const ValueKey('privacy_picker'),
                  options: _options,
                  initialIndex: _selectedIndex,
                  onChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
