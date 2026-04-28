import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class DisclosureSwitchShowcase extends StatefulWidget {
  const DisclosureSwitchShowcase({super.key});

  @override
  State<DisclosureSwitchShowcase> createState() =>
      _DisclosureSwitchShowcaseState();
}

class _DisclosureSwitchShowcaseState extends State<DisclosureSwitchShowcase> {
  bool _advancedEnabled = false;
  bool _inlineSuggestions = true;
  bool _autoCorrect = false;
  bool _smartReplies = true;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Disclosure Switch',
      backgroundColor: Colors.white,
      description:
          'Premium switch that reveals nested content with a gradient track '
          'and smooth size animations. Island inset header with concentric '
          'rounded corners and spring-based elastic bounce opening animation.',
      codeSnippet: '''DisclosureSwitch(
  title: 'Advanced Suggestions',
  value: _enabled,
  onChanged: (val) => setState(() => _enabled = val),
  icon: Icon(Icons.tune_rounded, color: Color(0xFF8E8E93)),
  revealedChild: Column(
    children: [
      // your nested settings rows
    ],
  ),
)''',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DisclosureSwitch(
                  title: 'Advanced Suggestions',
                  value: _advancedEnabled,
                  onChanged: (val) =>
                      setState(() => _advancedEnabled = val),
                  icon: const Icon(Icons.tune_rounded,
                      size: 24, color: Color(0xFF8E8E93)),
                  revealedChild: Column(
                    children: [
                      _buildOptionRow('Inline Suggestions', _inlineSuggestions,
                          (val) => setState(() => _inlineSuggestions = val)),
                      _buildOptionRow('Auto-correct words', _autoCorrect,
                          (val) => setState(() => _autoCorrect = val)),
                      _buildOptionRow('Smart Replies', _smartReplies,
                          (val) => setState(() => _smartReplies = val)),
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

  Widget _buildOptionRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _PremiumCheckbox(value: value, onChanged: onChanged),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// A custom high-fidelity checkbox with a subtle dark gradient.
class _PremiumCheckbox extends StatelessWidget {
  const _PremiumCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                value ? Colors.transparent : const Color(0xFF8E8E93),
            width: 1.5,
          ),
          gradient: value
              ? const LinearGradient(
                  colors: [Color(0xFF000000), Color(0xFF3A3A3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: value ? null : Colors.transparent,
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
