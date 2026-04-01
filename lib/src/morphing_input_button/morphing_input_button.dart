import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/portal_theme.dart';
import 'models/morphing_input_button_style.dart';

/// A premium, zero-dependency "Morphing Input Button" widget.
///
/// Features a fluid, soft-focus transition where a "Call to Action" button
/// morphs into a detailed text input field. Designed for waitlists, 
/// notifications, and minimal signup flows.
class MorphingInputButton extends StatefulWidget {

  /// Creates a [MorphingInputButton] with a [buttonText] and [placeholder].
  const MorphingInputButton({
    super.key,
    required this.buttonText,
    required this.placeholder,
    this.icon,
    this.onSubmitted,
    this.style = const MorphingInputButtonStyle(),
  });
  /// The text displayed on the initial button (e.g., "Notify Me").
  final String buttonText;

  /// The placeholder text for the expanded input field.
  final String placeholder;

  /// Optional icon to display alongside the button text.
  final IconData? icon;

  /// Callback triggered when the input is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Style configuration for the component.
  final MorphingInputButtonStyle style;

  @override
  State<MorphingInputButton> createState() => _MorphingInputButtonState();
}

class _MorphingInputButtonState extends State<MorphingInputButton> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    });
    
    // Aesthetic haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final portalTheme = PortalTheme.of(context);
    
    // Default palette if not provided in style
    final bgColor = widget.style.backgroundColor ?? portalTheme.colors.background;
    final btnSurfaceColor = widget.style.buttonColor ?? portalTheme.colors.surface;
    final height = widget.style.height;
    final duration = widget.style.duration;
    final curve = widget.style.curve;
    final initialWidth = widget.style.initialWidth;
    final expandedWidth = widget.style.expandedWidth;

    return Center(
      child: AnimatedContainer(
        duration: duration,
        curve: _isExpanded ? curve : Curves.easeOutCubic,
        width: _isExpanded ? expandedWidth : initialWidth,
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Input Field: Soft focus reveal during transition, razor-sharp once finished
            AnimatedPositioned(
              duration: duration,
              curve: Curves.easeOutQuart,
              left: _isExpanded ? 24 : 0,
              right: _isExpanded ? 130 : initialWidth,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0.0, 
                  end: _isExpanded ? 1.0 : 0.0,
                ),
                duration: duration,
                builder: (context, value, child) {
                  // Momentary peaking blur (0.0 -> 1.5 -> 0.0)
                  final double blur = (1.0 - (value - 0.5).abs() * 2).clamp(0.0, 1.0) * 1.5;
                  
                  // Surgical escape: physically remove ImageFiltered when blur is negligible
                  if (blur < 0.05) return child!;
                  
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: child,
                  );
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _isExpanded ? 1.0 : 0.0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    cursorColor: theme.colorScheme.primary,
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.25),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    onSubmitted: (value) {
                      widget.onSubmitted?.call(value);
                      _toggleExpanded();
                    },
                  ),
                ),
              ),
            ),

            // Morphing Button: Flat and stable
            AnimatedPositioned(
              duration: duration,
              curve: _isExpanded ? curve : Curves.easeOutCubic,
              right: _isExpanded ? 5 : 0,
              left: _isExpanded ? expandedWidth - 128 : 0,
              top: _isExpanded ? 5 : 0,
              bottom: _isExpanded ? 5 : 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _isExpanded ? () {
                    if (_controller.text.isNotEmpty) {
                      widget.onSubmitted?.call(_controller.text);
                    }
                    _toggleExpanded();
                  } : _toggleExpanded,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: _isExpanded ? btnSurfaceColor : btnSurfaceColor.withOpacity(0.0),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: _isExpanded ? 0.0 : 1.0,
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: _isExpanded ? 0.8 : 1.0,
                                  child: widget.icon != null && !_isExpanded
                                    ? Row(
                                        children: [
                                          Icon(widget.icon, color: theme.colorScheme.onSurface, size: 20),
                                          const SizedBox(width: 8),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                                ),
                              ),
                              Text(
                                widget.buttonText,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
