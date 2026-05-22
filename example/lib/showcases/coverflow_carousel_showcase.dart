import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// A showcase page demonstrating the [CoverflowCarousel] component.
///
/// Displays a high-fidelity 3D Coverflow carousel with colored cards,
/// an interactive slider, and programmatic navigation.
class CoverflowCarouselShowcase extends StatefulWidget {
  /// Creates a [CoverflowCarouselShowcase].
  const CoverflowCarouselShowcase({super.key});

  @override
  State<CoverflowCarouselShowcase> createState() =>
      _CoverflowCarouselShowcaseState();
}

class _CoverflowCarouselShowcaseState extends State<CoverflowCarouselShowcase> {
  late final CoverflowCarouselController _controller;
  int _currentIndex = 4; // Start at index 4 matching the screenshot
  bool _enableReflection = false;

  /// Whether the carousel scrolls vertically.
  bool _isVertical = false;

  double _spacing = -130.0; // Negative = heavy overlap (classic CoverFlow look)
  double _rotation = 70.0;  // 70° default gives iconic inward-facing side cards

  static const List<Color> _cardColors = [
    Color(0xFFFF3B30), // Red
    Color(0xFF007AFF), // Blue
    Color(0xFF34C759), // Green
    Color(0xFFFFCC00), // Yellow
    Color(0xFFAF52DE), // Purple
    Color(0xFF5856D6), // Indigo
    Color(0xFF1C1C1E), // Black
    Color(0xFFA2845E), // Brown
    Color(0xFFFF9500), // Orange
  ];

  @override
  void initState() {
    super.initState();
    _controller = CoverflowCarouselController(initialPage: 4);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine target page for the demo action button
    final targetPage = _currentIndex == 7 ? 3 : 7;

    return ShowcaseShell(
      title: 'Coverflow Carousel',
      description:
          'A high-fidelity 3D perspective card carousel inspired by the classic iPod Coverflow. '
          'Supports fluid horizontal swipe gestures, tap-to-focus on side cards, and dual-interactive slider navigation.',
      backgroundColor: Colors.white,
      codeSnippet: '''// Initialize controller
final controller = CoverflowCarouselController(initialPage: 4);

// Implement Coverflow
CoverflowCarousel(
  controller: controller,
  onIndexChanged: (index) => setState(() => _currentIndex = index),
  children: [
    Container(color: Colors.red),
    Container(color: Colors.blue),
    Container(color: Colors.green),
    // ...
  ],
)

// Navigate programmatically
controller.animateToPage(7);''',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CoverflowCarousel(
                controller: _controller,
                scrollDirection: _isVertical ? Axis.vertical : Axis.horizontal,
                onIndexChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                style: CoverflowCarouselStyle(
                  // Square card proportions — classic album art look
                  cardWidth: 220.0,
                  cardHeight: 220.0,
                  borderRadius: 20.0,
                  shadowColor: const Color(0x44000000),
                  shadowBlurRadius: 20.0,
                  shadowOffset: const Offset(0, 12),
                  spacing: _spacing,
                  enableReflection: _enableReflection,
                  maxRotationAngle: _rotation * 3.141592653589793 / 180.0,
                  scaleDelta: 0.85,
                  zOffset: 0.0,
                  perspective: 0.002,
                ),
                children: _cardColors.map((color) {
                  return Container(
                    color: color,
                    child: Center(
                      child: Text(
                        '${_cardColors.indexOf(color)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.15),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // "Go to X" programmatic button matching the design in the screenshots
            TextButton(
              onPressed: () {
                _controller.animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 650),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF007AFF),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text('Go to $targetPage'),
            ),
            const SizedBox(height: 16),
            // Customization View mimicking SwiftUI glass card
            Container(
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: const Color(0x0A000000), // Soft dark overlay
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0x1F000000), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile.adaptive(
                    title: const Text(
                      'Vertical Orientation',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    contentPadding: EdgeInsets.zero,
                    value: _isVertical,
                    onChanged: (val) => setState(() => _isVertical = val),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    title: const Text(
                      'Toggle Reflection',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    contentPadding: EdgeInsets.zero,
                    value: _enableReflection,
                    onChanged: (val) => setState(() => _enableReflection = val),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Card Spacing',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _spacing.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _spacing,
                    min: -250.0,   // Matches SwiftUI: Slider(value: $spacing, in: -250...90)
                    max: 90.0,
                    onChanged: (val) => setState(() => _spacing = val),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Card Rotation',
                        style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_rotation.toStringAsFixed(0)}°',
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _rotation,
                    min: 0.0,
                    max: 90.0,   // Matches SwiftUI: Slider(value: $rotation, in: 0...190) limited to 90
                    onChanged: (val) => setState(() => _rotation = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
