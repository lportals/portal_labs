import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// A showcase page demonstrating the [StackedCards] component.
///
/// Exposes switches to toggle the rotation/fan effect and the visibility
/// of the page indicator dot runner.
class StackedCardsShowcase extends StatefulWidget {
  /// Creates a [StackedCardsShowcase].
  const StackedCardsShowcase({super.key});

  @override
  State<StackedCardsShowcase> createState() => _StackedCardsShowcaseState();
}

class _StackedCardsShowcaseState extends State<StackedCardsShowcase> {
  bool _rotationEnabled = true;
  bool _showsScrollIndicator = false;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Stacked Cards',
      description:
          'A premium gesture-driven stacked card carousel with horizontal swiping. '
          'Features physics-based spring snapping, customizable rotation slanting, '
          'and a morphing page dot indicator.',
      backgroundColor: const Color(0xFFFAFAFA),
      codeSnippet: '''StackedCards(
  rotationEnabled: _rotationEnabled,
  showsScrollIndicator: _showsScrollIndicator,
  style: const StackedCardsStyle(
    shadows: [],
  ),
  children: [
    Container(color: const Color(0xFFFF3B30)),
    Container(color: const Color(0xFFFF9500)),
    Container(color: const Color(0xFFFFCC00)),
    Container(color: const Color(0xFF34C759)),
    Container(color: const Color(0xFF5AC8FA)),
    Container(color: const Color(0xFF007AFF)),
    Container(color: const Color(0xFF5856D6)),
    Container(color: const Color(0xFFFF2D55)),
  ],
)''',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StackedCards(
                  rotationEnabled: _rotationEnabled,
                  showsScrollIndicator: _showsScrollIndicator,
                  style: const StackedCardsStyle(
                    shadows: [],
                  ),
                  children: [
                    Container(
                      key: const ValueKey('red_card'),
                      color: const Color(0xFFFF3B30),
                    ),
                    Container(
                      key: const ValueKey('orange_card'),
                      color: const Color(0xFFFF9500),
                    ),
                    Container(
                      key: const ValueKey('yellow_card'),
                      color: const Color(0xFFFFCC00),
                    ),
                    Container(
                      key: const ValueKey('green_card'),
                      color: const Color(0xFF34C759),
                    ),
                    Container(
                      key: const ValueKey('teal_card'),
                      color: const Color(0xFF5AC8FA),
                    ),
                    Container(
                      key: const ValueKey('blue_card'),
                      color: const Color(0xFF007AFF),
                    ),
                    Container(
                      key: const ValueKey('indigo_card'),
                      color: const Color(0xFF5856D6),
                    ),
                    Container(
                      key: const ValueKey('pink_card'),
                      color: const Color(0xFFFF2D55),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _buildControlRow(
                        label: 'Rotation Enabled',
                        value: _rotationEnabled,
                        onChanged: (val) => setState(() => _rotationEnabled = val),
                      ),
                      const Divider(color: Color(0xFFF2F2F7), height: 1),
                      _buildControlRow(
                        label: 'Shows Scroll Indicator',
                        value: _showsScrollIndicator,
                        onChanged: (val) => setState(() => _showsScrollIndicator = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1D1D1F),
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF34C759),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
