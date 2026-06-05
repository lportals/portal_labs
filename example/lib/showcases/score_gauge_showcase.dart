import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// A showcase page demonstrating the [ScoreGauge] component.
class ScoreGaugeShowcase extends StatefulWidget {
  /// Creates a [ScoreGaugeShowcase].
  const ScoreGaugeShowcase({super.key});

  @override
  State<ScoreGaugeShowcase> createState() => _ScoreGaugeShowcaseState();
}

class _ScoreGaugeShowcaseState extends State<ScoreGaugeShowcase> {
  double _score = 100.0;

  @override
  void initState() {
    super.initState();
    // Simulate calculating the score on entrance by starting at 100 and animating to 849
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _score = 849.0;
          });
        }
      });
    });
  }

  String _getScoreLabel(double val) {
    if (val == 100.0) return 'CALCULATING...';
    if (val < 400) return 'POOR';
    if (val < 600) return 'FAIR';
    if (val < 750) return 'GOOD';
    if (val < 880) return 'VERY GOOD';
    return 'EXCELLENT';
  }

  void _triggerRecalculate() {
    HapticFeedback.mediumImpact();
    // Reset to 100 first to show the calculation action
    setState(() {
      _score = 100.0;
    });

    // Short delay, then animate to a new random score
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        final random = math.Random();
        // Generate a random score between 100 and 950
        final nextScore = 100.0 + random.nextInt(850);
        setState(() {
          _score = nextScore;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Score Gauge',
      description:
          'A premium status visualization gauge displaying a score value and label '
          'within a custom-painted arc. Ticks and sliding indicator pointer animate '
          'smoothly using physics-based spring curves.',
      infoItems: const [
        'ScoreGauge renders the gradient track, ticks, and indicator via CustomPainter.',
        'Uses PortalSpringCurve for smooth, interruptible animation of values and pointers.',
        'Dynamic text resizing and layout stability to prevent visual jumps.',
        'Typographic hierarchy, haptics, and shapes are fully customizable.',
      ],
      codeSnippet: '''// Semicircular Gauge
ScoreGauge(
  value: _score,
  min: 0,
  max: 1000,
  label: 'VERY GOOD',
  style: ScoreGaugeStyle(
    trackGradientColors: [
      Color(0xFFFF3B30),
      Color(0xFFFF9500),
      Color(0xFFFFCC00),
      Color(0xFF34C759),
    ],
  ),
)''',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    const activeStyle = ScoreGaugeStyle();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Simulated Mobile Screen Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Center(
              child: SizedBox(
                width: 260,
                height: 240,
                child: ScoreGauge(
                  value: _score,
                  min: 100.0,
                  max: 1000.0,
                  label: _getScoreLabel(_score),
                  style: activeStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recalculate Action Button
          _ScaleButton(
            onPressed: _triggerRecalculate,
            text: 'Recalculate Score',
            icon: Icons.refresh_rounded,
          ),
        ],
      ),
    );
  }
}

/// A premium, tactile tap feedback wrapper that shrinks slightly when pressed.
class _ScaleButton extends StatefulWidget {
  const _ScaleButton({
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
