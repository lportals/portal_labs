import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'models/stacked_toast_item.dart';
import 'models/stacked_toast_style.dart';

/// A premium, interactive toast stack that appears from the top and stacks
/// multiple notifications with a card-stack effect.
class StackedToastInteraction extends StatefulWidget {
  /// Creates a [StackedToastInteraction].
  const StackedToastInteraction({
    super.key,
    this.controller,
    this.style = const StackedToastStyle(),
    this.animationDuration = const Duration(milliseconds: 500),
  });

  /// Localized controller to trigger toasts.
  final StackedToastController? controller;

  /// Optional style configuration for the whole stack.
  final StackedToastStyle style;

  /// Duration for individual toast entry/exit animations.
  final Duration animationDuration;

  @override
  State<StackedToastInteraction> createState() => _StackedToastInteractionState();
}

class _StackedToastInteractionState extends State<StackedToastInteraction> {
  final List<StackedToastItem> _activeToasts = [];
  final Set<String> _exitingToastIds = {};
  final Map<String, Timer> _toastTimers = {};

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    for (var timer in _toastTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void showToast(StackedToastItem item) {
    setState(() {
      _activeToasts.insert(0, item);
    });

    _toastTimers[item.id] = Timer(item.duration, () {
      _removeToast(item.id);
    });
  }

  void _removeToast(String id) {
    if (!mounted || _exitingToastIds.contains(id)) return;
    
    setState(() {
      _exitingToastIds.add(id);
    });

    Future.delayed(widget.animationDuration, () {
      if (!mounted) return;
      setState(() {
        _activeToasts.removeWhere((toast) => toast.id == id);
        _exitingToastIds.remove(id);
        _toastTimers.remove(id)?.cancel();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + widget.style.topMargin;

    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        ..._activeToasts.asMap().entries.map((entry) {
          final index = entry.key;
          final toast = entry.value;
          final isExiting = _exitingToastIds.contains(toast.id);

          if (index > widget.style.maxStackedItems && !isExiting) return const SizedBox.shrink();

          return _AnimatedToastCard(
            key: ValueKey(toast.id),
            toast: toast,
            index: index,
            isExiting: isExiting,
            style: widget.style,
            duration: widget.animationDuration,
            topPadding: topPadding,
            onClose: () => _removeToast(toast.id),
          );
        }).toList().reversed,
      ],
    );
  }
}

/// Controller used to programmatically show toasts in a [StackedToastInteraction].
class StackedToastController {
  _StackedToastInteractionState? _state;
  void _attach(_StackedToastInteractionState state) => _state = state;
  void _detach() => _state = null;

  /// Shows a new toast in the stack.
  void show(StackedToastItem toast) => _state?.showToast(toast);
}

class _AnimatedToastCard extends StatefulWidget {

  const _AnimatedToastCard({
    required super.key,
    required this.toast,
    required this.index,
    required this.isExiting,
    required this.style,
    required this.duration,
    required this.topPadding,
    required this.onClose,
  });
  final StackedToastItem toast;
  final int index;
  final bool isExiting;
  final StackedToastStyle style;
  final Duration duration;
  final double topPadding;
  final VoidCallback onClose;

  @override
  State<_AnimatedToastCard> createState() => _AnimatedToastCardState();
}

class _AnimatedToastCardState extends State<_AnimatedToastCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = _controller;
    
    _runSpring(true);
  }

  @override
  void didUpdateWidget(_AnimatedToastCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExiting != oldWidget.isExiting && widget.isExiting) {
      _runSpring(false);
    }
  }

  void _runSpring(bool entering) {
    final spring = widget.style.spring ?? const SpringDescription(
      mass: 1.0,
      stiffness: 180,
      damping: 20,
    );

    final simulation = SpringSimulation(
      spring,
      _controller.value,
      entering ? 1.0 : 0.0,
      entering ? 2.5 : -2.5, // Initial velocity for punchy entry/exit
    );

    _controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        final bool isFront = widget.index == 0;
        
        final double offset = (1.0 - t) * -200.0 + (widget.index * widget.style.stackOffset);
        final double scale = (0.95 + (0.05 * t)) - (widget.index * widget.style.stackScaleFactor);
        final double opacity = t * (1.0 - (widget.index * 0.15)).clamp(0.0, 1.0);

        return Positioned(
          top: widget.topPadding + offset,
          left: widget.style.horizontalPadding,
          right: widget.style.horizontalPadding,
          child: GestureDetector(
            onVerticalDragEnd: (details) {
              if (isFront && details.primaryVelocity! < -100) {
                HapticFeedback.lightImpact();
                widget.onClose();
              }
            },
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: _ToastContent(
                  toast: widget.toast,
                  globalStyle: widget.style,
                  isFront: isFront && t > 0.9,
                  onClose: widget.onClose,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToastContent extends StatelessWidget {

  const _ToastContent({
    required this.toast,
    required this.globalStyle,
    required this.isFront,
    required this.onClose,
  });
  final StackedToastItem toast;
  final StackedToastStyle globalStyle;
  final bool isFront;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (toast.builder != null) {
      return Material(
        color: Colors.transparent,
        child: toast.builder!(context, onClose),
      );
    }

    final theme = _getTheme(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        color: toast.backgroundColor ?? Colors.white,
        borderRadius: toast.borderRadius ?? globalStyle.borderRadius ?? BorderRadius.circular(28),
        boxShadow: globalStyle.shadows,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Icon(
            toast.icon ?? theme.icon,
            color: toast.primaryColor ?? theme.primary,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toast.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: toast.titleTextStyle ?? globalStyle.titleTextStyle ?? TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: toast.primaryColor ?? theme.primary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  toast.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: toast.messageTextStyle ?? globalStyle.messageTextStyle ?? const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isFront)
            GestureDetector(
              onTap: () {
                if (toast.onAction != null) {
                  toast.onAction!();
                }
                onClose();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: toast.primaryColor ?? theme.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  toast.actionLabel,
                  style: toast.actionTextStyle ?? globalStyle.actionTextStyle ?? TextStyle(
                    color: theme.onPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _ToastTheme _getTheme(BuildContext context) {
    switch (toast.type) {
      case StackedToastType.info:
        return _ToastTheme(
          primary: const Color(0xFF007AFF),
          onPrimary: Colors.white,
          icon: Icons.info_outline_rounded,
        );
      case StackedToastType.warning:
        return _ToastTheme(
          primary: const Color(0xFFFF9500),
          onPrimary: Colors.white,
          icon: Icons.shield_outlined,
        );
      case StackedToastType.success:
        return _ToastTheme(
          primary: const Color(0xFF34C759),
          onPrimary: Colors.white,
          icon: Icons.check_circle_outline_rounded,
        );
      case StackedToastType.error:
        return _ToastTheme(
          primary: const Color(0xFFFF3B30),
          onPrimary: Colors.white,
          icon: Icons.error_outline_rounded,
        );
      case StackedToastType.custom:
        return _ToastTheme(
          primary: const Color(0xFF1C1C1E),
          onPrimary: Colors.white,
          icon: toast.icon ?? Icons.notifications_none_rounded,
        );
    }
  }
}

class _ToastTheme {

  _ToastTheme({
    required this.primary,
    required this.onPrimary,
    required this.icon,
  });
  final Color primary;
  final Color onPrimary;
  final IconData icon;
}
