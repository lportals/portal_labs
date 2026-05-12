import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class CinematicTextTransitionShowcase extends StatefulWidget {
  const CinematicTextTransitionShowcase({super.key});

  @override
  State<CinematicTextTransitionShowcase> createState() => _CinematicTextTransitionShowcaseState();
}

class _CinematicTextTransitionShowcaseState extends State<CinematicTextTransitionShowcase> {
  final List<String> _texts = [
    "Build Premium UI",
    "Craft Smart Apps",
    "Create Smooth UI",
    "Design High Flow",
  ];
  
  int _currentIndex = 0;
  bool _useElasticity = true;

  void _next() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _texts.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Cinematic Text Transition',
      description: 'A cinematic text transition that performs a sequential character '
          'fall-out and rise-in. Supports physics-based elastic settles and '
          'staggered timing for a premium feel.',
      codeSnippet: '''CinematicTextTransition(
  text: "Hello World",
  style: CinematicTextTransitionStyle(
    enableElasticity: true,
    duration: Duration(milliseconds: 1400),
  ),
)''',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 100, 
                    alignment: Alignment.center,
                    child: CinematicTextTransition(
                      text: _texts[_currentIndex],
                      style: CinematicTextTransitionStyle(
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1D1F),
                          letterSpacing: -0.5,
                        ),
                        duration: const Duration(milliseconds: 1400),
                        enableElasticity: _useElasticity,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _ResponsiveButton(onTap: _next),
                  
                  const SizedBox(height: 20),
                  
                  GestureDetector(
                    onTap: () => setState(() => _useElasticity = !_useElasticity),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _useElasticity,
                            activeColor: const Color(0xFF1D1D1F),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _useElasticity = val ?? true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Enable Bounce",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1D1D1F).withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _ResponsiveButton({required this.onTap});

  @override
  State<_ResponsiveButton> createState() => _ResponsiveButtonState();
}

class _ResponsiveButtonState extends State<_ResponsiveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF1D1D1F),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: const Text(
            "Trigger Transition",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
