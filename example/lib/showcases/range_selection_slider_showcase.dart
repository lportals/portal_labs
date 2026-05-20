import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class RangeSelectionSliderShowcase extends StatefulWidget {
  const RangeSelectionSliderShowcase({super.key});

  @override
  State<RangeSelectionSliderShowcase> createState() =>
      _RangeSelectionSliderShowcaseState();
}

class _RangeSelectionSliderShowcaseState
    extends State<RangeSelectionSliderShowcase> {
  RangeValues _priceRange = const RangeValues(640, 2380);

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Range Selection Slider',
      description:
          'Bi-directional range selector with mechanical 3D flip counters and '
          'manual text input. Tap either counter to switch from odometer mode '
          'to keyboard entry without losing context.',
      codeSnippet: '''RangeSelectionSlider(
  values: const RangeValues(640, 2380),
  min: 0,
  max: 5000,
  onChanged: (values) => setState(() => _range = values),
  onApply: (values) => print('Applied: \$values'),
)''',
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _demoSection(
                  child: RangeSelectionSlider(
                    values: _priceRange,
                    min: 0,
                    max: 5000,
                    onChanged: (values) => setState(() => _priceRange = values),
                    onApply: (values) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Applied range: \$${values.start.round()} - \$${values.end.round()}',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    onCancel: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoSection({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
