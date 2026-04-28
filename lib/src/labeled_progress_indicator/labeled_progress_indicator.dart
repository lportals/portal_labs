import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'models/labeled_progress_indicator_style.dart';
import 'models/progress_stage.dart';

/// A premium progress indicator that displays sequential loading stages
/// with a custom shimmer effect.
class LabeledProgressIndicator extends StatefulWidget {
  /// Creates a [LabeledProgressIndicator].
  const LabeledProgressIndicator({
    super.key,
    required this.progress,
    required this.stages,
    this.style = const LabeledProgressIndicatorStyle(),
    this.onComplete,
    this.isError = false,
    this.errorLabel,
  }) : assert(progress >= 0 && progress <= 1, 'Progress must be between 0 and 1');

  /// The current progress value from 0.0 to 1.0.
  final double progress;

  /// The list of sequential stages to display. 
  final List<dynamic> stages;

  /// The style configuration for the indicator.
  final LabeledProgressIndicatorStyle style;

  /// Callback triggered when progress reaches 1.0.
  final VoidCallback? onComplete;

  /// Whether the progress is in an error state.
  final bool isError;

  /// Label to show when in error state.
  final String? errorLabel;

  @override
  State<LabeledProgressIndicator> createState() => _LabeledProgressIndicatorState();
}

class _LabeledProgressIndicatorState extends State<LabeledProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  double _lastProgress = 0;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: widget.style.shimmerDuration,
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnimation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 70),
    ]).animate(_pulseController);

    _lastProgress = widget.progress;
  }

  @override
  void didUpdateWidget(LabeledProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _lastProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController.forward(from: 0);
      _lastProgress = widget.progress;

      // Pulse on completion
      if (widget.progress >= 1.0 && widget.style.showCompletionPulse) {
        _pulseController.forward(from: 0).then((_) {
          widget.onComplete?.call();
        });
      }
    }
    
    if (oldWidget.isError != widget.isError) {
      if (widget.isError) {
        _shimmerController.stop();
      } else {
        _shimmerController.repeat();
      }
    }
    
    if (oldWidget.style.shimmerDuration != widget.style.shimmerDuration) {
      _shimmerController.duration = widget.style.shimmerDuration;
      if (!widget.isError) _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String get _currentStage {
    if (widget.isError && widget.errorLabel != null) return widget.errorLabel!;
    if (widget.stages.isEmpty) return '';
    
    // Handle List<ProgressStage>
    if (widget.stages.first is ProgressStage) {
      for (final stage in widget.stages) {
        if (widget.progress <= stage.endProgress) {
          return stage.label;
        }
      }
      return (widget.stages.last as ProgressStage).label;
    }

    // Handle List<String> (Equal distribution)
    if (widget.progress >= 1.0) {
      final last = widget.stages.last;
      return (last is ProgressStage) ? last.label : last.toString();
    }
    
    final int index = (widget.progress * widget.stages.length).floor();
    final current = widget.stages[index.clamp(0, widget.stages.length - 1)];
    return (current is ProgressStage) ? current.label : current.toString();
  }

  @override
  Widget build(BuildContext context) {
    final String currentStage = _currentStage;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stages & Percentage Header
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stage Label with organic transitions
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                reverseDuration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  // Determine if this child is entering based on the current stage
                  final bool isEntering = child.key == ValueKey(currentStage);
                  
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) {
                      final double entryValue = animation.value;
                      final double exitValue = 1.0 - animation.value;

                      double scale;
                      double skew;
                      double blur;
                      double opacity;

                      if (isEntering) {
                        final bounceValue = Curves.easeOutBack.transform(entryValue);
                        scale = 0.85 + (0.15 * bounceValue);
                        skew = 0.3 * (1.0 - entryValue);
                        blur = 6.0 * (1.0 - entryValue);
                        opacity = entryValue.clamp(0.0, 1.0);
                      } else {
                        scale = 1.0 - (0.05 * exitValue);
                        skew = 0;
                        blur = 4.0 * exitValue;
                        opacity = animation.value;
                      }

                      return Opacity(
                        opacity: opacity,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..scaleByDouble(scale, scale, 1.0, 1.0)
                            ..multiply(Matrix4.skewX(skew)),
                          alignment: Alignment.center,
                          child: ImageFiltered(
                            imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                            child: child,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  currentStage,
                  key: ValueKey(currentStage),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: widget.style.textStyle.copyWith(
                    color: widget.isError ? Colors.red[400] : widget.style.textStyle.color,
                  ),
                ),
              ),
            ),
            
            // Optional Percentage (Separated to avoid triggering transitions)
            if (widget.style.showPercentage && !widget.isError) ...[
              const SizedBox(width: 8),
              Text(
                widget.style.percentageFormat.replaceAll(
                  '{val}', 
                  (widget.progress * 100).toInt().toString()
                ),
                style: widget.style.percentageTextStyle ?? widget.style.textStyle.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: widget.style.textStyle.fontSize! * 0.9,
                  color: widget.style.textStyle.color!.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Progress Bar with Shimmer & Pulse
        ScaleTransition(
          scale: _pulseAnimation,
          child: Stack(
            children: [
              // 1. Track (Background)
              Container(
                height: widget.style.height,
                decoration: BoxDecoration(
                  color: widget.style.trackColor,
                  borderRadius: widget.style.borderRadius,
                ),
              ),
              // 2. Consistent Shimmer (Clipped by progress)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_shimmerController, _progressAnimation]),
                  builder: (context, child) {
                    return _FixedShimmerEffect(
                      controller: _shimmerController,
                      style: widget.style,
                      progress: _progressAnimation.value,
                      isError: widget.isError,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FixedShimmerEffect extends StatelessWidget {
  const _FixedShimmerEffect({
    required this.controller,
    required this.style,
    required this.progress,
    required this.isError,
  });

  final AnimationController controller;
  final LabeledProgressIndicatorStyle style;
  final double progress;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0001, 1.0),
              child: ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) {
                  if (isError) {
                    return const LinearGradient(colors: [Colors.transparent, Colors.transparent])
                        .createShader(bounds);
                  }
                  
                  final shimmerBaseColor = style.shimmerColor;
                  return LinearGradient(
                    begin: const Alignment(-2.0, -0.2),
                    end: const Alignment(2.0, 0.2),
                    colors: [
                      shimmerBaseColor.withValues(alpha: 0.0),
                      shimmerBaseColor.withValues(alpha: 0.1),
                      shimmerBaseColor.withValues(alpha: 0.9),
                      shimmerBaseColor.withValues(alpha: 0.1),
                      shimmerBaseColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                    transform: _SlidingGradientTransform(
                      percent: controller.value,
                    ),
                  ).createShader(
                    Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight),
                  );
                },
                child: Container(
                  height: style.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isError ? Colors.red : style.progressColor,
                        isError ? Colors.redAccent : style.progressColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: style.borderRadius,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.percent,
  });

  final double percent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (4.0 * percent - 2.0), 0, 0);
  }
}
