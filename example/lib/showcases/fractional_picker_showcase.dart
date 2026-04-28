import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class FractionalPickerShowcase extends StatelessWidget {
  const FractionalPickerShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Fractional Picker',
      description:
          'Precision horizontal ruler for numeric input with predictive magnetic '
          'snapping. Configurable friction and snap stiffness for tailored '
          'tactile response at 60/120fps via AnimatedBuilder caching.',
      codeSnippet: '''ModernFractionalPicker(
  initialValue: 18.0,
  minValue: 0.0,
  maxValue: 100.0,
  decimalPlaces: 0,
  onValueChanged: (val) => setState(() => _value = val),
  style: FractionalPickerStyle(
    activeColor: Color(0xFF1D1D1F),
  ),
)''',
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ModernFractionalPicker(
              initialValue: 18,
              minValue: 0,
              maxValue: 100,
              decimalPlaces: 0,
              onValueChanged: (val) => debugPrint('Value: $val'),
            ),
          ),
        ),
      ),
    );
  }
}
