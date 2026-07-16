import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import 'models/swipe_action.dart';
import 'models/swipeable_action_tile_style.dart';

/// A premium, physics-based swipeable tile that reveals actions underneath.
/// Follows Emil design principles for spring animations and momentum scrolling.
class SwipeableActionTile extends StatefulWidget {
  /// Creates a swipeable action tile.
  const SwipeableActionTile({
    super.key,
    required this.child,
    this.startActions = const [],
    this.endActions = const [],
    this.style = const SwipeableActionTileStyle(),
    this.onSwipeStateChanged,
    this.onTap,
  });

  /// The main content of the tile (e.g. a message row).
  final Widget child;

  /// Callback when the tile itself is tapped (only triggered if not currently swiped open).
  final VoidCallback? onTap;

  /// Actions revealed when swiping left-to-right.
  final List<SwipeAction> startActions;

  /// Actions revealed when swiping right-to-left.
  final List<SwipeAction> endActions;

  /// The style configuration for the tile.
  final SwipeableActionTileStyle style;

  /// Callback when the swipe state changes (true if swiping/opened, false if closed/idle).
  final ValueChanged<bool>? onSwipeStateChanged;

  @override
  State<SwipeableActionTile> createState() => SwipeableActionTileState();
}

/// State for [SwipeableActionTile] to control spring simulation and offset.
class SwipeableActionTileState extends State<SwipeableActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragOffset = 0.0;
  bool _isTriggerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        final wasZero = _dragOffset == 0.0;
        setState(() {
          _dragOffset = _controller.value;
        });
        final isZero = _dragOffset == 0.0;
        if (wasZero != isZero) {
          widget.onSwipeStateChanged?.call(!isZero);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    if (widget.onSwipeStateChanged != null) {
      widget.onSwipeStateChanged!(true);
    }
  }

  double _getActionsWidth(List<SwipeAction> actions) {
    if (actions.isEmpty) return 0.0;
    final buttonSize = widget.style.actionButtonSize;
    return actions.length * (buttonSize + 6.0) + 6.0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final wasZero = _dragOffset == 0.0;
    setState(() {
      double delta = details.delta.dx;
      final maxStartOffset = _getActionsWidth(widget.startActions);
      final minEndOffset = -_getActionsWidth(widget.endActions);

      if (_dragOffset > 0 && widget.startActions.isEmpty) {
        delta *= 0.1;
      } else if (_dragOffset < 0 && widget.endActions.isEmpty) {
        delta *= 0.1;
      } else if (_dragOffset > maxStartOffset && delta > 0) {
        final overscroll = _dragOffset - maxStartOffset;
        delta *= (1.0 / (1.0 + overscroll * 0.05));
      } else if (_dragOffset < minEndOffset && delta < 0) {
        final overscroll = minEndOffset - _dragOffset;
        delta *= (1.0 / (1.0 + overscroll * 0.05));
      }

      _dragOffset += delta;
    });

    final isZero = _dragOffset == 0.0;
    if (wasZero != isZero) {
      widget.onSwipeStateChanged?.call(!isZero);
    }

    // Check if we swiped past the trigger threshold (actions width + 60px)
    final absDrag = _dragOffset.abs();
    final actionsWidth = _getActionsWidth(
        _dragOffset > 0 ? widget.startActions : widget.endActions);
    final threshold = actionsWidth + 60.0;
    final isReady = absDrag > threshold;

    if (isReady != _isTriggerReady) {
      setState(() {
        _isTriggerReady = isReady;
      });
      if (isReady && widget.style.enableHaptics) {
        HapticFeedback.mediumImpact(); // Dynamic haptic tick when trigger is active
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;

    final maxStartOffset = _getActionsWidth(widget.startActions);
    final minEndOffset = -_getActionsWidth(widget.endActions);

    if (_isTriggerReady) {
      // Swipe-to-trigger activated
      final primaryAction = _dragOffset > 0 
          ? widget.startActions.first 
          : widget.endActions.last;
      
      primaryAction.onTap();
      close();
      setState(() {
        _isTriggerReady = false;
      });
      return;
    }

    double targetOffset = 0.0;

    if (_dragOffset > 0 && widget.startActions.isNotEmpty) {
      if (velocity > 500 ||
          _dragOffset > maxStartOffset * widget.style.swipeThreshold) {
        targetOffset = maxStartOffset;
      }
    } else if (_dragOffset < 0 && widget.endActions.isNotEmpty) {
      if (velocity < -500 ||
          _dragOffset < minEndOffset * widget.style.swipeThreshold) {
        targetOffset = minEndOffset;
      }
    }

    if (targetOffset != 0 && widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    _runSpringSimulation(velocity, targetOffset);
  }

  void _runSpringSimulation(double velocity, double target) {
    final simulation = SpringSimulation(
      widget.style.springDescription,
      _dragOffset,
      target,
      velocity,
    );
    _controller.animateWith(simulation).then((_) {
      if (target == 0.0 && mounted) {
        setState(() {
          _dragOffset = 0.0;
          _controller.value = 0.0;
          _isTriggerReady = false;
        });
        widget.onSwipeStateChanged?.call(false);
      }
    });
  }

  /// Closes the swipeable action tile with a spring animation.
  void close() {
    if (widget.style.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    _runSpringSimulation(0, 0);
  }

  @override
  Widget build(BuildContext context) {
    // Interpolate cornerRadius and shadow based on drag distance
    final dragProgress = (_dragOffset.abs() / 16.0).clamp(0.0, 1.0);
    final currentRadius = widget.style.cornerRadius * dragProgress;
    
    final currentShadow = widget.style.tileShadow?.map((shadow) {
      return BoxShadow(
        color: shadow.color.withValues(alpha: shadow.color.a * dragProgress),
        blurRadius: shadow.blurRadius,
        spreadRadius: shadow.spreadRadius,
        offset: shadow.offset * dragProgress,
      );
    }).toList();

    // Interpolate card background color
    final Color? idleColor = widget.style.idleCardColor;
    final Color currentColor;
    if (idleColor != null) {
      currentColor = Color.lerp(idleColor, widget.style.cardColor, dragProgress)!;
    } else {
      currentColor = widget.style.cardColor;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background Actions
        Positioned.fill(
          child: Row(
            children: [
              // Start actions (left to right) - only rendered when swiping right
              if (_dragOffset > 0 && widget.startActions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Row(
                    children: widget.startActions.asMap().entries.map((entry) {
                      final isExpanding = entry.key == 0;
                      return Container(
                        padding: EdgeInsets.only(right: _isTriggerReady && !isExpanding ? 0.0 : 6.0),
                        child: _buildAction(entry.value, entry.key, true),
                      );
                    }).toList(),
                  ),
                ),
              const Spacer(),
              // End actions (left to right on the right side) - only rendered when swiping left
              if (_dragOffset < 0 && widget.endActions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Row(
                    children: widget.endActions.asMap().entries.map((entry) {
                      final isExpanding = entry.key == widget.endActions.length - 1;
                      return Container(
                        padding: EdgeInsets.only(left: _isTriggerReady && !isExpanding ? 0.0 : 6.0),
                        child: _buildAction(entry.value, entry.key, false),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Foreground child
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: GestureDetector(
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              onTap: () {
                if (_dragOffset != 0) {
                  close();
                } else if (widget.onTap != null) {
                  if (widget.style.enableHaptics) {
                    HapticFeedback.lightImpact();
                  }
                  widget.onTap!();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(currentRadius),
                  boxShadow: currentShadow,
                  color: currentColor,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(currentRadius),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      );
  }

  Widget _buildAction(SwipeAction action, int index, bool isStartAction) {
    final buttonSize = widget.style.actionButtonSize;
    
    // Determine exposure order
    final exposureIndex = isStartAction 
        ? index 
        : (widget.endActions.length - 1) - index;
        
    // Introduce a delay threshold so actions only start appearing after slot is partially uncovered
    final startOffset = exposureIndex * (buttonSize + 6.0) + 16.0;
    final revealRange = buttonSize - 12.0; // Faster popping range (36px)
    
    // Calculate progress (0.0 to 1.0) based on drag offset
    double progress = 0.0;
    if (isStartAction) {
      if (_dragOffset > 0) {
        progress = ((_dragOffset - startOffset) / revealRange).clamp(0.0, 1.0);
      }
    } else {
      if (_dragOffset < 0) {
        final absDrag = _dragOffset.abs();
        progress = ((absDrag - startOffset) / revealRange).clamp(0.0, 1.0);
      }
    }

    // Apply a subtle ease-out curve so it pops in smoothly
    final curvedProgress = Curves.easeOut.transform(progress);

    // Calculate overscroll stretching / full trigger size
    final isExpanding = isStartAction 
        ? index == 0 
        : index == widget.endActions.length - 1;
        
    double dynamicWidth = buttonSize;
    final absDrag = _dragOffset.abs();
    
    // Calculate the physical space available for this button to prevent overlap
    // Accounts for the 6.0px padding on the outer edge of the button
    final buttonEdge = exposureIndex * (buttonSize + 6.0) + 6.0;
    final availableSpace = absDrag - buttonEdge - 6.0;
    final maxAllowedWidth = availableSpace.clamp(0.0, buttonSize);
    
    if (isExpanding) {
      if (_isTriggerReady) {
        dynamicWidth = absDrag - 12.0; // Fills the entire drag area
      } else {
        final maxOffset = _getActionsWidth(isStartAction ? widget.startActions : widget.endActions);
        if (absDrag > maxOffset) {
          dynamicWidth = buttonSize + (absDrag - maxOffset);
        } else {
          dynamicWidth = (curvedProgress * buttonSize).clamp(0.0, maxAllowedWidth);
        }
      }
    } else {
      // Non-expanding buttons shrink to width 0 when trigger is active
      dynamicWidth = _isTriggerReady ? 0.0 : (curvedProgress * buttonSize).clamp(0.0, maxAllowedWidth);
    }

    final double dynamicHeight = (isExpanding && _isTriggerReady) || (isExpanding && absDrag > _getActionsWidth(isStartAction ? widget.startActions : widget.endActions))
        ? buttonSize
        : dynamicWidth;

    final double currentRadius = (isExpanding && _isTriggerReady) || (isExpanding && absDrag > _getActionsWidth(isStartAction ? widget.startActions : widget.endActions))
        ? buttonSize / 2
        : dynamicWidth / 2;

    return Semantics(
      button: true,
      label: action.label,
      onTap: () {
        action.onTap();
        close();
      },
      child: GestureDetector(
        onTap: () {
          action.onTap();
          close();
        },
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: _isTriggerReady && !isExpanding ? 0.0 : curvedProgress,
          child: Container(
            width: dynamicWidth,
            height: dynamicHeight,
            decoration: BoxDecoration(
              color: action.backgroundColor,
              borderRadius: BorderRadius.circular(currentRadius),
            ),
            alignment: _isTriggerReady && isExpanding
                ? (isStartAction ? Alignment.centerRight : Alignment.centerLeft)
                : Alignment.center,
            padding: _isTriggerReady && isExpanding
                ? (isStartAction
                    ? const EdgeInsets.only(right: 20.0)
                    : const EdgeInsets.only(left: 20.0))
                : EdgeInsets.zero,
            child: dynamicWidth < 16.0
                ? const SizedBox.shrink()
                : SizedBox(
                    width: dynamicWidth * 0.5,
                    height: dynamicHeight * 0.5,
                    child: FittedBox(
                      child: action.icon,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
