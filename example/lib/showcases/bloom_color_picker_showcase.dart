import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// Showcase for the [BloomColorPicker] widget.
/// Demonstrates the dynamic alignment configurations, pill toggles, and premium transitions.
class BloomColorPickerShowcase extends StatefulWidget {
  const BloomColorPickerShowcase({super.key});

  @override
  State<BloomColorPickerShowcase> createState() => _BloomColorPickerShowcaseState();
}

class _BloomColorPickerShowcaseState extends State<BloomColorPickerShowcase> {
  Color _currentColor = const Color(0xFFF7C13F);
  BloomColorPickerAlignment _alignment = BloomColorPickerAlignment.circleLeft;
  bool _showHexPill = true;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Bloom Color Picker',
      description:
          'A premium color picker with a "Bloom" concentric peeling expansion effect, '
          'radial dual-ring swatches, and a dynamic arc lightness slider. Supports custom swatches, '
          'collapsible text editing, and left/right layout alignment.',
      backgroundColor: const Color(0xFFFAFAFA),
      codeSnippet: '''BloomColorPicker(
  initialColor: _currentColor,
  onColorChanged: (color) {
    setState(() {
      _currentColor = color;
    });
  },
  style: BloomColorPickerStyle(
    alignment: BloomColorPickerAlignment.${_alignment.name},
    showHexPill: $_showHexPill,
  ),
)''',
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Alignment Toggle Tabs
              DiscreteTabs(
                currentIndex: _alignment == BloomColorPickerAlignment.circleLeft ? 0 : 1,
                tabs: [
                  DiscreteTab(
                    label: 'Circle Left',
                    icon: Icons.align_horizontal_left_rounded,
                    activeColor: const Color(0xFF111111),
                  ),
                  DiscreteTab(
                    label: 'Circle Right',
                    icon: Icons.align_horizontal_right_rounded,
                    activeColor: const Color(0xFF111111),
                  ),
                ],
                onSelect: (index) {
                  setState(() {
                    _alignment = index == 0
                        ? BloomColorPickerAlignment.circleLeft
                        : BloomColorPickerAlignment.circleRight;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Hex Pill Toggle Tabs
              DiscreteTabs(
                currentIndex: _showHexPill ? 0 : 1,
                tabs: [
                  DiscreteTab(
                    label: 'Show Pill',
                    icon: Icons.visibility_rounded,
                    activeColor: const Color(0xFF111111),
                  ),
                  DiscreteTab(
                    label: 'Hide Pill',
                    icon: Icons.visibility_off_rounded,
                    activeColor: const Color(0xFF111111),
                  ),
                ],
                onSelect: (index) {
                  setState(() {
                    _showHexPill = index == 0;
                  });
                },
              ),
              const SizedBox(height: 48),
              // The Bloom Color Picker
              BloomColorPicker(
                initialColor: _currentColor,
                onColorChanged: (color) {
                  setState(() {
                    _currentColor = color;
                  });
                },
                style: BloomColorPickerStyle(
                  alignment: _alignment,
                  showHexPill: _showHexPill,
                ),
              ),
              const SizedBox(height: 64),
              // Preview Card showing the active color in full premium styling
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: 200,
                height: 80,
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _currentColor.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '#${_currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: TextStyle(
                      color: HSLColor.fromColor(_currentColor).lightness > 0.6
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFFFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
