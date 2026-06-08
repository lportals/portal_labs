import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// Showcase for the [BloomColorPicker] widget.
/// Displays a single centered instance with the default configuration.
class BloomColorPickerShowcase extends StatefulWidget {
  const BloomColorPickerShowcase({super.key});

  @override
  State<BloomColorPickerShowcase> createState() => _BloomColorPickerShowcaseState();
}

class _BloomColorPickerShowcaseState extends State<BloomColorPickerShowcase> {
  Color _currentColor = const Color(0xFFF7C13F);

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Bloom Color Picker',
      description:
          'A premium color picker with a "Bloom" expansion effect, radial color wheel, and dynamic lightness slider.',
      codeSnippet: '''
BloomColorPicker(
  initialColor: _currentColor,
  onColorChanged: (color) => setState(() => _currentColor = color),
)
''',
      child: Center(
        child: BloomColorPicker(
          initialColor: _currentColor,
          onColorChanged: (color) {
            setState(() {
              _currentColor = color;
            });
          },
        ),
      ),
    );
  }
}
