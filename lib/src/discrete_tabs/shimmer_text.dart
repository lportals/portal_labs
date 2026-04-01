import 'package:flutter/material.dart';

/// A custom shimmer text widget designed for premium, zero-dependency
/// UI components.
///
/// It uses a [ShaderMask] with a moving [LinearGradient] to create a
/// subtle shimmering light effect across the text.
class ShimmerText extends StatefulWidget {

  /// Creates a [ShimmerText] with the given text, style, and shimmer colors.
  const ShimmerText({
    super.key,
    required this.text,
    required this.style,
    required this.baseColor,
    required this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });
  /// The text to render with the shimmer effect.
  final String text;

  /// The text style applied to the base text.
  final TextStyle style;

  /// The base (non-highlighted) color of the shimmer.
  final Color baseColor;

  /// The highlight color at the center of the shimmer sweep.
  final Color highlightColor;

  /// The total duration of one shimmer pass. Defaults to 1500ms.
  final Duration duration;

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
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
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlidingGradientTransform(offset: _controller.value),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {

  const _SlidingGradientTransform({required this.offset});
  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (offset * 2 - 1), 0, 0);
  }
}
