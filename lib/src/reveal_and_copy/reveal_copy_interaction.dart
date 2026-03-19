import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';


/// A customizable, premium interaction widget that allows revealing
/// and optionally copying sensitive numbers with elegant animations.
class RevealCopyInteraction extends StatefulWidget {
  /// The sensitive text to display (e.g., a credit card number).
  final String value;

  /// The character used to mask the sensitive information.
  /// Defaults to the multiplication sign '×' for better vertical centering.
  final String maskCharacter;

  /// The duration for which the text remains revealed before auto-hiding.
  /// Defaults to 4 seconds.
  final Duration revealDuration;

  /// The color used for the progress ring and success state of the icon.
  /// Defaults to an emerald green (0xFF10B981).
  final Color successColor;

  /// The background color of the widget container.
  /// Defaults to white.
  final Color backgroundColor;

  /// The color of the widget's border.
  /// Defaults to Black with 10% opacity.
  final Color borderColor;

  /// The text style for the revealed numbers and letters.
  /// Defaults to a monospace font size 20, weight 600.
  final TextStyle? textStyle;

  /// The text style specifically for the masking characters.
  /// Defaults to a monospace font size 20, weight 600.
  final TextStyle? maskedTextStyle;

  /// The border radius of the main container and the action button.
  /// Defaults to 16.0 for the container and 10.0 for the button.
  final double borderRadius;

  /// Whether the copy functionality is enabled when the text is revealed.
  /// If false, the copy icon will not appear, and tapping will not copy.
  /// Defaults to true.
  final bool enableCopy;

  /// Callback triggered immediately after the text is copied to the clipboard.
  /// Useful for showing external Snackbars or Toasts.
  final VoidCallback? onCopied;

  /// Callback triggered when the text is initially revealed.
  final VoidCallback? onRevealed;

  const RevealCopyInteraction({
    super.key,
    required this.value,
    this.maskCharacter = '×',
    this.revealDuration = const Duration(seconds: 4),
    this.successColor = const Color(0xFF10B981),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0x0F000000),
    this.textStyle,
    this.maskedTextStyle,
    this.borderRadius = 16.0,
    this.enableCopy = true,
    this.onCopied,
    this.onRevealed,
  });

  @override
  State<RevealCopyInteraction> createState() => _RevealCopyInteractionState();
}

class _RevealCopyInteractionState extends State<RevealCopyInteraction>
    with TickerProviderStateMixin {
  bool _isRevealed = false;
  bool _isCopied = false;
  
  late AnimationController _progressController;
  late AnimationController _scrambleController;
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.revealDuration,
    );

    _scrambleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _revert();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _scrambleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleInteraction() {
    if (_isRevealed) {
      if (widget.enableCopy && !_isCopied) {
        _copyToClipboard();
      }
    } else {
      _reveal();
    }
  }

  void _reveal() {
    setState(() {
      _isRevealed = true;
    });
    
    widget.onRevealed?.call();
    
    _progressController.forward(from: 0.0);
    _scrambleController.forward(from: 0.0);
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _isRevealed) {
        _shimmerController.forward(from: 0.0);
      }
    });
    
    HapticFeedback.mediumImpact();
  }

  void _revert() {
    if (!mounted) return;
    _scrambleController.reverse();
    _shimmerController.reset();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isRevealed = false;
          _isCopied = false;
        });
        _progressController.reset();
      }
    });
  }

  void _copyToClipboard() {
    if (!widget.enableCopy) return;
    
    Clipboard.setData(ClipboardData(text: widget.value));
    setState(() {
      _isCopied = true;
    });
    HapticFeedback.vibrate();
    
    widget.onCopied?.call();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAnimatedNumbers(),
          ),
          const SizedBox(width: 4),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildAnimatedNumbers() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scrambleController, _shimmerController]),
      builder: (context, child) {
        final text = _getScrambledText();
        
        final defaultTextStyle = const TextStyle(
          fontSize: 20,
          color: Color(0xFF111111),
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
          letterSpacing: 0.8,
        );

        final content = Text(
          text,
          style: widget.textStyle ?? defaultTextStyle,
        );

        if (_isRevealed && _shimmerController.isAnimating || _shimmerController.isCompleted) {
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.textStyle?.color ?? const Color(0xFF111111), 
                  Colors.white,      
                  widget.textStyle?.color ?? const Color(0xFF111111), 
                ],
                stops: const [0.35, 0.5, 0.65],
                transform: SlidingGradientTransform(
                  offset: _shimmerController.value,
                ),
              ).createShader(bounds);
            },
            child: content,
          );
        }

        return content;
      },
    );
  }

  String _getScrambledText() {
    final String fullText = widget.value;
    final String maskedText = _getMaskedString(fullText);
    
    if (!_isRevealed && _scrambleController.isDismissed) return maskedText;
    
    final double progress = _scrambleController.value;
    final int charactersToReveal = (fullText.length * progress).floor();
    
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < fullText.length; i++) {
      if (i < charactersToReveal) {
        buffer.write(fullText[i]);
      } else {
        buffer.write(maskedText[i]);
      }
    }
    return buffer.toString();
  }

  String _getMaskedString(String input) {
    final parts = input.split(' ');
    final mask = widget.maskCharacter;
    
    // Check if it looks like a credit card number (4 blocks of 4)
    if (parts.length == 4) {
      return '${parts[0]} $mask$mask$mask$mask $mask$mask$mask$mask ${parts[3]}';
    }
    
    // Generic masking for other strings
    return input.replaceAll(RegExp(r'\d'), mask);
  }

  Widget _buildActionButton() {
    return GestureDetector(
      onTap: _handleInteraction,
      child: SizedBox(
        width: 40, 
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rectangular Action Button (Base)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isRevealed ? widget.successColor.withOpacity(0.2) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(widget.borderRadius * (10/16)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInBack,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  _getIcon(),
                  key: ValueKey<int>(_isCopied ? 2 : (_isRevealed ? 1 : 0)),
                  size: 18,
                  color: _isRevealed ? widget.successColor : const Color(0xFF111111),
                ),
              ),
            ),
            // Rectangular Progress Border
            if (_isRevealed)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RectProgressPainter(
                        progress: 1.0 - _progressController.value,
                        color: widget.successColor,
                        strokeWidth: 3.0,
                        borderRadius: widget.borderRadius * (10/16),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    if (!_isRevealed) return Icons.visibility_outlined;
    if (!widget.enableCopy) return Icons.visibility_off_outlined; 
    if (_isCopied) return Icons.check_rounded;
    return Icons.content_copy_rounded;
  }
}

class SlidingGradientTransform extends GradientTransform {
  final double offset;

  const SlidingGradientTransform({required this.offset});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (offset * 3 - 1.5), 0, 0);
  }
}

class RectProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  RectProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    if (progress <= 0) return;
    final path = Path();
    final double centerX = rect.center.dx;
    path.moveTo(centerX, rect.top);
    path.lineTo(rect.right - borderRadius, rect.top);
    path.arcToPoint(Offset(rect.right, rect.top + borderRadius), radius: Radius.circular(borderRadius));
    path.lineTo(rect.right, rect.bottom - borderRadius);
    path.arcToPoint(Offset(rect.right - borderRadius, rect.bottom), radius: Radius.circular(borderRadius));
    path.lineTo(rect.left + borderRadius, rect.bottom);
    path.arcToPoint(Offset(rect.left, rect.bottom - borderRadius), radius: Radius.circular(borderRadius));
    path.lineTo(rect.left, rect.top + borderRadius);
    path.arcToPoint(Offset(rect.left + borderRadius, rect.top), radius: Radius.circular(borderRadius));
    path.lineTo(centerX, rect.top);
    final pathMetrics = path.computeMetrics();
    final activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, activePaint);
    }
  }

  @override
  bool shouldRepaint(RectProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
