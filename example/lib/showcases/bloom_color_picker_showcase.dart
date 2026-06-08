import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class BloomColorPickerShowcase extends StatefulWidget {
  const BloomColorPickerShowcase({super.key});

  @override
  State<BloomColorPickerShowcase> createState() => _BloomColorPickerShowcaseState();
}

class _BloomColorPickerShowcaseState extends State<BloomColorPickerShowcase> {
  Color _color = const Color(0xFFF7C13F);

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Bloom Color Picker',
      description: 'A premium color picker with a "Bloom" expansion effect, overlapping circular color wheel, and dynamic lightness slider.',
      codeSnippet: '''
BloomColorPicker(
  initialColor: const Color(0xFFF7C13F),
  onColorChanged: (color) {
    setState(() => _color = color);
  },
  style: BloomColorPickerStyle(
    closedRadius: 24.0,
    bloomRadius: 120.0,
  ),
)
''',
      child: Container(
        height: 400,
        alignment: Alignment.center,
        child: BloomColorPicker(
          initialColor: _color,
          onColorChanged: (c) {
            setState(() {
              _color = c;
            });
          },
        ),
      ),
    );
  }
}
