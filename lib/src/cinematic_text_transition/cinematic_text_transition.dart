import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/cinematic_text_transition_style.dart';

/// A premium text animation widget that performs a sequential "fall and fade" exit
/// for characters before revealing the next string with a rise-in animation.
class CinematicTextTransition extends StatefulWidget {
  /// Creates a [CinematicTextTransition].
  const CinematicTextTransition({
    super.key,
    required this.text,
    this.style = const CinematicTextTransitionStyle(),
  });

  /// The text string to display and animate.
  final String text;

  /// The style configuration for the animation and text.
  final CinematicTextTransitionStyle style;

  @override
  State<CinematicTextTransition> createState() =>
      _CinematicTextTransitionState();
}

class _CinematicTextTransitionState extends State<CinematicTextTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  String? _exitingText;
  late String _currentText;

  @override
  void initState() {
    super.initState();
    _currentText = widget.text;
    _controller = AnimationController(
      vsync: this,
      duration: widget.style.duration,
      value: 1.0, // Ensure text is visible initially
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _exitingText = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(CinematicTextTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (widget.style.enableHaptics) HapticFeedback.lightImpact();

      setState(() {
        _exitingText = oldWidget.text;
        _currentText = widget.text;
      });

      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double t = _controller.value;

        return Semantics(
          label: _currentText,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Exiting Layer (Sequential Fall Out)
              if (_exitingText != null)
                _buildCharLayer(_exitingText!, isExiting: true, progress: t),

              // 2. Entering Layer (Sequential Rise In)
              _buildCharLayer(_currentText, isExiting: false, progress: t),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCharLayer(
    String text, {
    required bool isExiting,
    required double progress,
  }) {
    final chars = text.split('');
    final int count = chars.length;

    const double charWindow = 0.4;
    final double layerStart = isExiting ? 0.0 : 0.4;
    final double layerEnd = isExiting ? 0.6 : 1.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final double staggerStep = count > 1
            ? (layerEnd - layerStart - charWindow) / (count - 1)
            : 0;
        final double start = (layerStart + i * staggerStep).clamp(0.0, 1.0);
        final double end = (start + charWindow).clamp(0.0, 1.0);

        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            end,
            curve: isExiting
                ? Curves.easeIn
                : (widget.style.enableElasticity
                      ? Curves.easeOutBack
                      : Curves.easeOutCubic),
          ),
        );

        double opacity = 1.0;
        double yOffset = 0.0;
        double scale = 1.0;

        if (isExiting) {
          // Softened quadratic fade-out
          opacity = 1.0 - (animation.value * animation.value);
          // If bounce is off, no fall motion
          yOffset = widget.style.enableElasticity
              ? animation.value * 14.0
              : 0.0;
          scale = widget.style.enableElasticity
              ? 1.0 - (animation.value * 0.1)
              : 1.0;
        } else {
          if (progress < start) {
            opacity = 0.0;
            yOffset = widget.style.enableElasticity ? 24.0 : 0.0;
          } else {
            opacity = animation.value;
            // If bounce is off, no rise motion
            yOffset = widget.style.enableElasticity
                ? (1.0 - animation.value) * 24.0
                : 0.0;
          }
        }

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, yOffset),
            child: Transform.scale(
              scale: scale,
              child: Text(chars[i], style: widget.style.textStyle),
            ),
          ),
        );
      }),
    );
  }
}
