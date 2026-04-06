import 'dart:ui';
import 'package:flutter/material.dart';
import 'models/choice_item.dart';
import '../common/premium_flip_counter.dart';

/// A premium, high-fidelity interaction component for selecting items or categories.
/// Features a multi-row horizontal scroller, 3D flip odometer counter, and flying media animations.
///
/// Supports [ChoiceItem] items which can contain emojis, icons, or images.
class PremiumChoiceChips extends StatefulWidget {

  /// Creates a [PremiumChoiceChips] with the given items and configuration.
  const PremiumChoiceChips({
    super.key,
    this.title = 'Selection',
    required this.items,
    this.onSelectionChanged,
    this.onActionPressed,
    this.backgroundColor = const Color(0xFFFAFAFA),
    this.accentColor = const Color(0xFF1D1D1F),
    this.buttonLabel = 'Item',
    this.buttonPluralLabel = 'Items',
  });
  /// The title displayed at the top of the component.
  final String title;

  /// The list of items to be displayed as chips.
  final List<ChoiceItem> items;

  /// Callback triggered when the selection list changes.
  final ValueChanged<List<ChoiceItem>>? onSelectionChanged;

  /// Callback triggered when the main action card (the counter) is pressed.
  final VoidCallback? onActionPressed;

  /// The color used for the background blur and depth gradients.
  final Color backgroundColor;

  /// The primary color used for text, selected borders, and the counter.
  final Color accentColor;

  /// The label used for the single count (e.g., 'Item').
  final String buttonLabel;

  /// The label used for plural counts (e.g., 'Items').
  final String buttonPluralLabel;

  @override
  State<PremiumChoiceChips> createState() => _PremiumChoiceChipsState();
}

class _PremiumChoiceChipsState extends State<PremiumChoiceChips>
    with TickerProviderStateMixin {
  final Set<ChoiceItem> _selectedItems = {};
  final List<_FlyingMediaData> _activeFlyingMedia = [];
  final LayerLink _buttonLayerLink = LayerLink();
  final GlobalKey _buttonTargetKey = GlobalKey();

  void _onChipTapped(ChoiceItem item) {
    if (_activeFlyingMedia.isNotEmpty) return;

    setState(() {
      final isSelected = _selectedItems.contains(item);
      if (isSelected) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
        _triggerMediaAnimation(item);
      }
      widget.onSelectionChanged?.call(_selectedItems.toList());
    });
  }

  void _triggerMediaAnimation(ChoiceItem item) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    Offset? buttonPos;
    try {
      final RenderBox? stackBox = context.findRenderObject() as RenderBox?;
      final RenderBox? targetBox =
          _buttonTargetKey.currentContext?.findRenderObject() as RenderBox?;

      if (stackBox != null) {
        if (targetBox != null) {
          buttonPos = stackBox.globalToLocal(
            targetBox.localToGlobal(targetBox.size.center(Offset.zero)),
          );
        } else {
          // Fallback if button is not yet rendered (first click)
          final Size size = stackBox.size;
          buttonPos = Offset(size.width / 2, size.height - 70);
        }
      }
    } catch (_) {}

    setState(() {
      _activeFlyingMedia.add(
        _FlyingMediaData(
          id: id,
          item: item,
          startPosition: buttonPos,
          targetPosition: buttonPos,
        ),
      );
    });
  }

  void _removeFlyingMedia(String id) {
    setState(() {
      _activeFlyingMedia.removeWhere((e) => e.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int itemsPerRow = (widget.items.length / 4).ceil();
    final List<List<ChoiceItem>> rows = [];
    for (int i = 0; i < 4; i++) {
      final start = i * itemsPerRow;
      if (start >= widget.items.length) break;
      final end = (start + itemsPerRow).clamp(0, widget.items.length);
      final row = widget.items.sublist(start, end);
      if (row.isNotEmpty) rows.add(row);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Content Area
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 32.0, bottom: 12.0),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: widget.accentColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.08, 0.92, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rows.map((rowItems) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: rowItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _ChoiceChip(
                                item: item,
                                isSelected: _selectedItems.contains(item),
                                accentColor: widget.accentColor,
                                onTap: () => _onChipTapped(item),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 40),
                  child: CompositedTransformTarget(
                    key: _buttonTargetKey,
                    link: _buttonLayerLink,
                    child: const SizedBox(height: 60, width: 10),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Flying Media & Overlay Layer
        Positioned.fill(
          child: Stack(
            clipBehavior: Clip.none,
            children: _activeFlyingMedia
                .map(
                  (anim) => _FlyingMedia(
                    key: ValueKey(anim.id),
                    item: anim.item,
                    startPosition: anim.startPosition,
                    targetPosition: anim.targetPosition,
                    backgroundColor: widget.backgroundColor,
                    accentColor: widget.accentColor,
                    onComplete: () => _removeFlyingMedia(anim.id),
                  ),
                )
                .toList(),
          ),
        ),

        // 3. Action Card
        Positioned(
          key: const ValueKey('action_button_positioned'),
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _buttonLayerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.center,
            followerAnchor: Alignment.center,
            child: GestureDetector(
              onTap: widget.onActionPressed,
              child: _BottomActionButton(
                count: _selectedItems.length,
                accentColor: widget.accentColor,
                label: widget.buttonLabel,
                pluralLabel: widget.buttonPluralLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FlyingMediaData {
  _FlyingMediaData({
    required this.id,
    required this.item,
    this.startPosition,
    this.targetPosition,
  });
  final String id;
  final ChoiceItem item;
  final Offset? startPosition;
  final Offset? targetPosition;
}

class _ChoiceMedia extends StatelessWidget {

  const _ChoiceMedia({required this.item, this.size = 20, this.color});
  final ChoiceItem item;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (item.emoji != null) {
      return Text(item.emoji!, style: TextStyle(fontSize: size));
    } else if (item.icon != null) {
      return Icon(item.icon, size: size, color: color);
    } else if (item.imagePath != null) {
      final isNetwork = item.imagePath!.startsWith('http');
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.2),
          image: DecorationImage(
            image: isNetwork
                ? NetworkImage(item.imagePath!) as ImageProvider
                : AssetImage(item.imagePath!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    return SizedBox(width: size, height: size);
  }
}

class _ChoiceChip extends StatelessWidget {

  const _ChoiceChip({
    required this.item,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });
  final ChoiceItem item;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? const Color(0xFFE5E5EA) : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChoiceMedia(
              item: item,
              color: isSelected ? accentColor : const Color(0xFF48484A),
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isSelected ? accentColor : const Color(0xFF48484A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionButton extends StatefulWidget {

  const _BottomActionButton({
    required this.count,
    required this.accentColor,
    required this.label,
    required this.pluralLabel,
  });
  final int count;
  final Color accentColor;
  final String label;
  final String pluralLabel;

  @override
  State<_BottomActionButton> createState() => _BottomActionButtonState();
}

class _BottomActionButtonState extends State<_BottomActionButton> {
  bool _upward = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(_BottomActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      setState(() {
        _upward = widget.count > oldWidget.count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVisible = widget.count > 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: isVisible
          ? Container(
              key: const ValueKey('bottom_action_button'),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFFE5E5EA), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PremiumFlipCounter(
                    value: widget.count,
                    upward: _upward,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor,
                    ),
                  ),
                  Text(
                    ' ${widget.count == 1 ? widget.label : widget.pluralLabel}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.accentColor,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('none')),
    );
  }
}

class _FlyingMedia extends StatefulWidget {

  const _FlyingMedia({
    super.key,
    required this.item,
    this.startPosition,
    this.targetPosition,
    required this.backgroundColor,
    required this.accentColor,
    required this.onComplete,
  });
  final ChoiceItem item;
  final Offset? startPosition;
  final Offset? targetPosition;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback onComplete;

  @override
  State<_FlyingMedia> createState() => _FlyingMediaState();
}

class _FlyingMediaState extends State<_FlyingMedia>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Use a post-frame callback to start the animation.
    // This ensures the first frame is rendered with t=0 (scale 0).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward().then((_) => widget.onComplete());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size stackSize = constraints.biggest;
          final double centerX = stackSize.width / 2;
          final double centerY = stackSize.height / 2 - 60;

          if (stackSize.width < 10 || stackSize.height < 10) {
            return const SizedBox.shrink();
          }

          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final double t = _animation.value;
              final Offset startOrigin =
                  widget.startPosition ??
                  Offset(centerX, stackSize.height - 40);
              final Offset endTarget =
                  widget.targetPosition ??
                  Offset(centerX, stackSize.height - 40);

              _EmojiAnimParams getParams(int index) {
                double upStart, upEnd, downStart, downEnd;
                double targetX, targetY;

                switch (index) {
                  case 0: // Left
                    upStart = 0.0;
                    upEnd = 0.3;
                    downStart = 0.7;
                    downEnd = 1.0;
                    targetX = centerX - 60;
                    targetY = centerY + 30;
                    break;
                  case 2: // Middle
                    upStart = 0.05;
                    upEnd = 0.35;
                    downStart = 0.65;
                    downEnd = 0.95;
                    targetX = centerX;
                    targetY = centerY - 60;
                    break;
                  case 1: // Right
                    upStart = 0.1;
                    upEnd = 0.4;
                    downStart = 0.6;
                    downEnd = 0.9;
                    targetX = centerX + 60;
                    targetY = centerY + 30;
                    break;
                  default:
                    upStart = 0;
                    upEnd = 0;
                    downStart = 0;
                    downEnd = 0;
                    targetX = 0;
                    targetY = 0;
                }

                double opacity = 0.0;
                double scale = 0.0;
                double blur = 0.0;
                double curX = startOrigin.dx;
                double curY = startOrigin.dy;

                if (t < upEnd) {
                  if (t < upStart) {
                    opacity = 0.0;
                    scale = 0.0;
                    blur = 0.0;
                  } else {
                    double localT = ((t - upStart) / (upEnd - upStart)).clamp(
                      0.0,
                      1.0,
                    );
                    // Smooth ascent
                    double posEased = Curves.easeOutCubic.transform(localT);

                    curY = lerpDouble(startOrigin.dy, targetY, posEased)!;
                    curX = lerpDouble(startOrigin.dx, targetX, posEased)!;

                    // MANDATORY: No fade-in during ascent to ensure visibility from the button
                    opacity = 1.0;
                    scale = 2.0 * localT;

                    // Rapid blur clear-up
                    blur = 10.0 * (1.0 - (localT / 0.25)).clamp(0.0, 1.0);
                  }
                } else if (t > downStart) {
                  double localT = ((t - downStart) / (downEnd - downStart))
                      .clamp(0.0, 1.0);
                  double eased = Curves.easeInCubic.transform(localT);
                  curY = lerpDouble(targetY, endTarget.dy, eased)!;
                  curX = lerpDouble(targetX, endTarget.dx, eased)!;
                  opacity = (1.0 - localT).clamp(0.0, 1.0);
                  scale = 2.0 * (1.0 - localT);
                  // Blur starts appearing only in the final 40% of the descent
                  blur = 12.0 * ((localT - 0.6) / 0.4).clamp(0.0, 1.0);
                } else {
                  curX = targetX;
                  curY = targetY;
                  opacity = 1.0;
                  scale = 2.0;
                  blur = 0.0;
                }

                return _EmojiAnimParams(curX, curY, scale, opacity, blur);
              }

              final p1 = getParams(0);
              final p2 = getParams(1);
              final p3 = getParams(2);

              double overlayOpacity = 0.0;
              if (t < 0.2) {
                overlayOpacity = Curves.easeOut.transform(
                  (t / 0.2).clamp(0.0, 1.0),
                );
              } else if (t < 0.8) {
                overlayOpacity = 1.0;
              } else {
                overlayOpacity = Curves.easeIn.transform(
                  (1.0 - ((t - 0.8) / 0.2)).clamp(0.0, 1.0),
                );
              }

              return Stack(
                children: [
                  if (overlayOpacity > 0.0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 320,
                      child: Opacity(
                        opacity: overlayOpacity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.3, 0.7, 1.0],
                              colors: [
                                widget.backgroundColor.withValues(alpha: 0.0),
                                widget.backgroundColor.withValues(alpha: 0.4),
                                widget.backgroundColor.withValues(alpha: 0.9),
                                widget.backgroundColor,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  _buildMedia(p1.x, p1.y, p1.scale * 0.9, p1.opacity, p1.blur),
                  _buildMedia(p2.x, p2.y, p2.scale * 0.9, p2.opacity, p2.blur),
                  _buildMedia(p3.x, p3.y, p3.scale, p3.opacity, p3.blur),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMedia(
    double x,
    double y,
    double scale,
    double opacity,
    double blur,
  ) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned(
      left: x - 30,
      top: y - 30,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale.clamp(0.0, 5.0),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: _ChoiceMedia(
              item: widget.item,
              size: 60,
              color: widget.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmojiAnimParams {
  _EmojiAnimParams(this.x, this.y, this.scale, this.opacity, this.blur);
  final double x, y, scale, opacity, blur;
}
