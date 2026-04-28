import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class WeightPickerShowcase extends StatefulWidget {
  const WeightPickerShowcase({super.key});

  @override
  State<WeightPickerShowcase> createState() => _WeightPickerShowcaseState();
}

class _WeightPickerShowcaseState extends State<WeightPickerShowcase> {
  double _weight = 24.0;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Modern Weight Picker',
      description:
          'Precision scrollable ruler with magnetic snapping and haptic feedback. '
          'Custom-painted high-resolution track with major and minor increments '
          'and low-latency 60fps value synchronization.',
      codeSnippet: '''ModernWeightPicker(
  initialValue: 75.0,
  onValueChanged: (weight) => print('Selected: \$weight'),
)''',
      child: SafeArea(
        bottom: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                ModernWeightPicker(
                  initialValue: _weight,
                  onValueChanged: (value) => setState(() => _weight = value),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
