import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// A showcase page demonstrating the [CircularColorPicker] component.
class CircularColorPickerShowcase extends StatefulWidget {
  /// Creates a [CircularColorPickerShowcase].
  const CircularColorPickerShowcase({super.key});

  @override
  State<CircularColorPickerShowcase> createState() => _CircularColorPickerShowcaseState();
}

class _CircularColorPickerShowcaseState extends State<CircularColorPickerShowcase> {
  int _selectedIndex = 3; // Start with Lime selected
  bool _useSolidFill = false; // Toggle between hollow rings and solid circles

  final List<Color> _colors = const [
    Color(0xFFFF5252), // Red
    Color(0xFFFF7043), // Coral / Orange
    Color(0xFFFFCA28), // Amber / Yellow
    Color(0xFFD4E157), // Lime / Yellow-Green
    Color(0xFF66BB6A), // Green
    Color(0xFF26A69A), // Mint / Teal
    Color(0xFF26C6DA), // Cyan / Sky Blue
    Color(0xFF29B6F6), // Light Blue
    Color(0xFF42A5F5), // Blue
    Color(0xFF5C6BC0), // Indigo / Violet
    Color(0xFFAB47BC), // Purple
    Color(0xFFEC407A), // Pink
    Color(0xFFFF8A80), // Peach / Salmon
  ];

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = _colors[_selectedIndex];

    return ShowcaseShell(
      title: 'Circular Color Picker',
      description:
          'An interactive color selector arranged in a ring layout. Selecting a color '
          'slides it to the center using a spring physics animation, while the previously '
          'selected color slides back to its position in the outer ring.',
      backgroundColor: const Color(0xFFFAFAFA),
      codeSnippet: '''CircularColorPicker(
  colors: const [
    Color(0xFFFF5252),
    Color(0xFFFF7043),
    Color(0xFFFFCA28),
    Color(0xFFD4E157),
    Color(0xFF66BB6A),
    Color(0xFF26A69A),
    Color(0xFF26C6DA),
    Color(0xFF29B6F6),
    Color(0xFF42A5F5),
    Color(0xFF5C6BC0),
    Color(0xFFAB47BC),
    Color(0xFFEC407A),
    Color(0xFFFF8A80),
  ],
  selectedIndex: _selectedIndex,
  onChanged: (index) => setState(() => _selectedIndex = index),
  style: const CircularColorPickerStyle(
    fillColor: Color(0xFFFAFAFA),
    useSolidFill: $_useSolidFill,
  ),
)''',
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Style Selector Switch
              DiscreteTabs(
                currentIndex: _useSolidFill ? 1 : 0,
                tabs: [
                  DiscreteTab(
                    label: 'Hollow Rings',
                    icon: Icons.panorama_fish_eye_rounded,
                    activeColor: const Color(0xFF111111),
                  ),
                  DiscreteTab(
                    label: 'Solid Circles',
                    icon: Icons.circle,
                    activeColor: const Color(0xFF111111),
                  ),
                ],
                onSelect: (index) {
                  setState(() {
                    _useSolidFill = index == 1;
                  });
                },
              ),
              const SizedBox(height: 32),
              // Circular Color Picker
              CircularColorPicker(
                colors: _colors,
                selectedIndex: _selectedIndex,
                style: CircularColorPickerStyle(
                  fillColor: const Color(0xFFFAFAFA),
                  useSolidFill: _useSolidFill,
                ),
                onChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const SizedBox(height: 48),
              // Dynamic button that changes color according to selected color
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Color saved successfully!',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: selectedColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      child: Text(
                        'FINISH & SAVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
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
