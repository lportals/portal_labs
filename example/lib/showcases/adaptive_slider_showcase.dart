import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class AdaptiveSliderShowcase extends StatefulWidget {
  const AdaptiveSliderShowcase({super.key});

  @override
  State<AdaptiveSliderShowcase> createState() => _AdaptiveSliderShowcaseState();
}

class _AdaptiveSliderShowcaseState extends State<AdaptiveSliderShowcase> {
  double _currentCalories = 200.0;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Adaptive Slider',
      description:
          'A value-aware slider where gradients and typography morph in real time '
          'based on configurable thresholds. Contextual indicator points '
          'recalculate their color state on every frame.',
      codeSnippet: '''AdaptiveSliderInteraction(
  value: _value,
  min: 0,
  max: 350,
  title: 'Calories',
  unit: 'kCal',
  step: 50,
  onChanged: (val) => setState(() => _value = val),
)''',
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDemoCard(
                  child: AdaptiveSliderInteraction(
                    value: _currentCalories,
                    min: 0,
                    max: 350,
                    onChanged: (val) =>
                        setState(() => _currentCalories = val),
                    title: 'Calories',
                    unit: 'kCal',
                    step: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
