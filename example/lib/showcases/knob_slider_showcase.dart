import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class KnobSliderShowcase extends StatefulWidget {
  const KnobSliderShowcase({super.key});

  @override
  State<KnobSliderShowcase> createState() => _KnobSliderShowcaseState();
}

class _KnobSliderShowcaseState extends State<KnobSliderShowcase> {
  double _value = 73.0;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Knob Slider',
      description:
          'A production-ready hardware-inspired dial with delta-based rotation '
          'tracking and a mechanical odometer-style numeric display. Eliminates '
          'the dead-zone jump common in standard circular sliders.',
      codeSnippet: '''KnobSlider(
  value: _value,
  min: 0,
  max: 100,
  step: 1,
  onChanged: (val) => setState(() => _value = val),
  style: KnobSliderStyle(
    activeTickColor: Colors.black,
    knobScale: 0.6,
    totalTicks: 60,
  ),
)''',
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: KnobSlider(
                      value: _value,
                      min: 0,
                      max: 100,
                      step: 1,
                      onChanged: (val) => setState(() => _value = val),
                      style: KnobSliderStyle(
                        activeTickColor: Colors.black,
                        knobScale: 0.6,
                        totalTicks: 60,
                        valueTextStyle: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF8E8E93),
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
