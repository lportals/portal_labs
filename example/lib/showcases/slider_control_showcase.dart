import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// A showcase page demonstrating the [SliderControl] component.
class SliderControlShowcase extends StatefulWidget {
  /// Creates a [SliderControlShowcase].
  const SliderControlShowcase({super.key});

  @override
  State<SliderControlShowcase> createState() => _SliderControlShowcaseState();
}

class _SliderControlShowcaseState extends State<SliderControlShowcase> {
  double _temperature = 20.0;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Slider Control',
      description:
          'A premium vertical slider with a pill-shaped track and a gradient '
          'fill that blends from a cool colour at the minimum to a warm colour '
          'at the maximum. A floating circular badge shows the live value and '
          'fades out after interaction. Designed to feel like a physical '
          'smart-home thermostat dial.',
      infoItems: const [
        'Gradient fill uses CustomPainter for GPU-accelerated rendering.',
        'Badge fades in on drag start, fades out after 1.5 s of inactivity.',
        'Spring physics settle the fill to the nearest step after release.',
        'Haptic feedback fires on every step crossing.',
        'Configurable suffix (°, %, kg, …) and badge anchor side.',
      ],
      codeSnippet: '''SliderControl(
  value: _value,
  min: 16,
  max: 30,
  step: 1,
  onChanged: (v) => setState(() => _value = v),
  style: SliderControlStyle(
    lowColor: Color(0xFF5E5CE6),
    highColor: Color(0xFFFF453A),
    valueSuffix: '°',
    tickCount: 20,
    bottomIcon: Icons.thermostat_rounded,
  ),
)''',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: _buildTempSlider(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTempSlider() {
    return SizedBox(
      key: const ValueKey('temp'),
      height: 300,
      child: SliderControl(
        value: _temperature,
        min: 16,
        max: 30,
        step: 1,
        onChanged: (v) => setState(() => _temperature = v),
        style: const SliderControlStyle(
          trackWidth: 68,
          lowColor: Color(0xFF5E5CE6),
          highColor: Color(0xFFFF453A),
          valueSuffix: '°',
          tickCount: 20,
          tickWidth: 12,
          ticksUseGradient: true,
          badgeAnchor: BadgeAnchor.right,
          bottomIcon: Icons.thermostat_rounded,
        ),
      ),
    );
  }
}
