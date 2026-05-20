import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/portal_animations.dart';
import '../common/premium_flip_counter.dart';
import 'models/premium_pagination_style.dart';

/// A premium, highly customizable pagination widget with mechanical flip animations.
///
/// Displays pagination in the format: `[Prev] [Current] of [Total] [Next]`
class PremiumPagination extends StatefulWidget {
  /// Creates a [PremiumPagination] widget.
  const PremiumPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.style = const PremiumPaginationStyle(),
    this.enableHaptics = true,
    this.previousIcon = Icons.arrow_back_rounded,
    this.nextIcon = Icons.arrow_forward_rounded,
    this.separatorText = 'of',
  }) : assert(
         currentPage >= 1 && currentPage <= totalPages,
         'currentPage must be between 1 and totalPages',
       );

  /// The current active page (1-indexed).
  final int currentPage;

  /// The total number of pages.
  final int totalPages;

  /// Callback when the page changes.
  final ValueChanged<int> onPageChanged;

  /// Visual configuration for the pagination widget.
  final PremiumPaginationStyle style;

  /// Whether to enable haptic feedback on page change.
  final bool enableHaptics;

  /// Custom icon for the previous button.
  final IconData previousIcon;

  /// Custom icon for the next button.
  final IconData nextIcon;

  /// Custom label for the "of" text. Defaults to "of".
  final String separatorText;

  @override
  State<PremiumPagination> createState() => _PremiumPaginationState();
}

class _PremiumPaginationState extends State<PremiumPagination> {
  bool _isNext = true;

  void _handleNext() {
    if (widget.currentPage < widget.totalPages) {
      setState(() => _isNext = true);
      widget.onPageChanged(widget.currentPage + 1);
      _triggerHaptics();
    }
  }

  void _handlePrevious() {
    if (widget.currentPage > 1) {
      setState(() => _isNext = false);
      widget.onPageChanged(widget.currentPage - 1);
      _triggerHaptics();
    }
  }

  void _triggerHaptics() {
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle =
        widget.style.labelStyle ??
        widget.style.textStyle.copyWith(
          color: widget.style.textStyle.color?.withValues(alpha: 0.4),
          fontWeight: FontWeight.w400,
          fontSize: widget.style.textStyle.fontSize != null
              ? widget.style.textStyle.fontSize! * 0.7
              : 16,
        );

    return Container(
      padding: widget.style.padding,
      decoration: BoxDecoration(
        color: widget.style.backgroundColor,
        borderRadius: BorderRadius.circular(widget.style.borderRadius),
        border: Border.all(
          color: widget.style.borderColor,
          width: widget.style.borderWidth,
        ),
        boxShadow: widget.style.shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PaginationButton(
            key: const ValueKey('pagination_prev'),
            icon: widget.previousIcon,
            onPressed: _handlePrevious,
            enabled: widget.currentPage > 1,
            style: widget.style,
            label: 'Previous page',
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.style.spacing),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PremiumFlipCounter(
                  value: widget.currentPage,
                  upward: _isNext,
                  style: widget.style.textStyle,
                  padWithZero: widget.style.padWithZero,
                  maxDigits:
                      widget.style.maxDigits ??
                      widget.totalPages.toString().length,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(widget.separatorText, style: labelStyle),
                ),
                Text('${widget.totalPages}', style: widget.style.textStyle),
              ],
            ),
          ),
          _PaginationButton(
            key: const ValueKey('pagination_next'),
            icon: widget.nextIcon,
            onPressed: _handleNext,
            enabled: widget.currentPage < widget.totalPages,
            style: widget.style,
            label: 'Next page',
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatefulWidget {
  /// Creates a [_PaginationButton] widget.
  const _PaginationButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.enabled,
    required this.style,
    required this.label,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;
  final PremiumPaginationStyle style;
  final String label;

  @override
  State<_PaginationButton> createState() => _PaginationButtonState();
}

class _PaginationButtonState extends State<_PaginationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: const PortalSpringCurve()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActuallyEnabled = widget.enabled;

    return Semantics(
      button: true,
      enabled: isActuallyEnabled,
      label: widget.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: isActuallyEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: GestureDetector(
          onTapDown: isActuallyEnabled ? (_) => _controller.forward() : null,
          onTapUp: isActuallyEnabled ? (_) => _controller.reverse() : null,
          onTapCancel: isActuallyEnabled ? () => _controller.reverse() : null,
          onTap: isActuallyEnabled ? widget.onPressed : null,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.style.buttonSize,
              height: widget.style.buttonSize,
              decoration: BoxDecoration(
                shape: widget.style.buttonBorderRadius == null
                    ? BoxShape.circle
                    : BoxShape.rectangle,
                borderRadius: widget.style.buttonBorderRadius != null
                    ? BorderRadius.circular(widget.style.buttonBorderRadius!)
                    : null,
                boxShadow: isActuallyEnabled ? widget.style.shadows : null,
                color: isActuallyEnabled
                    ? (_isHovered
                          ? widget.style.buttonColor.withValues(alpha: 0.9)
                          : widget.style.buttonColor)
                    : const Color(0xFFF2F2F7), // Soft grey when unavailable
              ),
              child: Icon(
                widget.icon,
                color: isActuallyEnabled
                    ? widget.style.iconColor
                    : widget.style.iconColor.withValues(alpha: 0.3),
                size: widget.style.iconSize ?? (widget.style.buttonSize * 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
