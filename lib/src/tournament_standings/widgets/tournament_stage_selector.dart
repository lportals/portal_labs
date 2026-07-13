import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tournament_standings_models.dart';
import '../painters/step_lines_painter.dart';

/// A custom widget designed to select a range of stages for a tournament bracket view.
class TournamentStageRangeSelector extends StatefulWidget {
  /// Creates a [TournamentStageRangeSelector].
  const TournamentStageRangeSelector({
    super.key,
    required this.startStage,
    required this.endStage,
    required this.stages,
    required this.labels,
    required this.onChanged,
    this.accentColor = const Color(0xFF007AFF),
    this.enableHaptics = true,
    this.stageIconBuilder,
  });

  /// The currently selected start stage (inclusive).
  final TournamentStage startStage;

  /// The currently selected end stage (inclusive).
  final TournamentStage endStage;

  /// Ordered list of stages to display.
  final List<TournamentStage> stages;

  /// Ordered labels for each tick position.
  final List<String> labels;

  /// Callback fired whenever the selection range changes.
  final void Function(TournamentStage start, TournamentStage end) onChanged;

  /// The accent/highlight color for the active range.
  final Color accentColor;

  /// Whether to emit haptic feedback on each tick during drag.
  final bool enableHaptics;

  /// Optional builder to supply custom icons for each stage key.
  final Widget Function(BuildContext context, TournamentStage stage, bool isSelected)? stageIconBuilder;

  @override
  State<TournamentStageRangeSelector> createState() => _TournamentStageRangeSelectorState();
}

class _TournamentStageRangeSelectorState extends State<TournamentStageRangeSelector> {
  final GlobalKey _trackKey = GlobalKey();

  int? _anchorIndex;
  bool _isDraggingBlock = false;
  int _initialTouchIndex = 0;
  int _initialStartIdx = 0;
  int _initialEndIdx = 0;

  int _getIndexFromGlobal(Offset globalPos, int itemCount) {
    final RenderBox? box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 0;
    
    final localOffset = box.globalToLocal(globalPos);
    final double dx = localOffset.dx.clamp(0.0, box.size.width - 0.1);
    final double itemWidth = box.size.width / itemCount;
    return (dx / itemWidth).floor().clamp(0, itemCount - 1);
  }

  void _handleTouchStart(Offset globalPos) {
    final RenderBox? box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localOffset = box.globalToLocal(globalPos);
    final double dx = localOffset.dx;
    final int itemCount = widget.stages.length;
    final double innerWidth = box.size.width - 4.0;
    final double itemWidth = innerWidth / itemCount;

    final int currentStartIdx = widget.stages.indexOf(widget.startStage);
    final int currentEndIdx = widget.stages.indexOf(widget.endStage);

    final double activeLeft = currentStartIdx * itemWidth + 2.0;
    final double activeRight = (currentEndIdx + 1) * itemWidth + 2.0;

    final bool touchedActivePill = dx >= activeLeft && dx <= activeRight;
    final bool touchedLeftHandle = dx >= activeLeft && dx < (activeLeft + 16.0);
    final bool touchedRightHandle = dx > (activeRight - 16.0) && dx <= activeRight;

    if (touchedActivePill && !touchedLeftHandle && !touchedRightHandle) {
      _isDraggingBlock = true;
      _initialTouchIndex = ((dx - 2.0) / itemWidth).floor().clamp(0, itemCount - 1);
      _initialStartIdx = currentStartIdx;
      _initialEndIdx = currentEndIdx;
    } else {
      _isDraggingBlock = false;
      final int touchIndex = ((dx - 2.0) / itemWidth).floor().clamp(0, itemCount - 1);

      if (touchIndex == currentStartIdx) {
        _anchorIndex = currentEndIdx;
      } else if (touchIndex == currentEndIdx) {
        _anchorIndex = currentStartIdx;
      } else {
        _anchorIndex = touchIndex;
        widget.onChanged(widget.stages[touchIndex], widget.stages[touchIndex]);
      }
    }

    if (widget.enableHaptics) HapticFeedback.selectionClick();
  }

  void _handleTouchUpdate(Offset globalPos) {
    final int itemCount = widget.stages.length;
    final int currentIndex = _getIndexFromGlobal(globalPos, itemCount);

    if (_isDraggingBlock) {
      final int delta = currentIndex - _initialTouchIndex;
      int newStartIdx = _initialStartIdx + delta;
      int newEndIdx = _initialEndIdx + delta;

      final int rangeLength = _initialEndIdx - _initialStartIdx;

      if (newStartIdx < 0) {
        newStartIdx = 0;
        newEndIdx = newStartIdx + rangeLength;
      } else if (newEndIdx >= itemCount) {
        newEndIdx = itemCount - 1;
        newStartIdx = newEndIdx - rangeLength;
      }

      final int previousMin = widget.stages.indexOf(widget.startStage);
      final int previousMax = widget.stages.indexOf(widget.endStage);

      if (newStartIdx != previousMin || newEndIdx != previousMax) {
        if (widget.enableHaptics) HapticFeedback.selectionClick();
        widget.onChanged(widget.stages[newStartIdx], widget.stages[newEndIdx]);
      }
    } else {
      if (_anchorIndex == null) return;
      
      final int currentMin = math.min(_anchorIndex!, currentIndex);
      final int currentMax = math.max(_anchorIndex!, currentIndex);

      final int previousMin = widget.stages.indexOf(widget.startStage);
      final int previousMax = widget.stages.indexOf(widget.endStage);

      if (currentMin != previousMin || currentMax != previousMax) {
        if (widget.enableHaptics) HapticFeedback.selectionClick();
        widget.onChanged(widget.stages[currentMin], widget.stages[currentMax]);
      }
    }
  }

  void _handleTouchEnd() {
    _anchorIndex = null;
    _isDraggingBlock = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final Color inactiveBg = const Color(0xFF2C2C2E);
    final Color activeBg = Colors.white.withValues(alpha: 0.30);
    final Color activeStroke = const Color(0xFF2C2C2E);
    
    final Color labelActive = theme.textTheme.bodyMedium?.color ?? Colors.black;
    final Color labelInactive = (theme.textTheme.bodySmall?.color ?? Colors.grey).withValues(alpha: 0.45);
    
    final Color segmentActiveColor = Colors.white;
    final Color segmentInactiveColor = Colors.white.withValues(alpha: 0.30);

    final int startIdx = widget.stages.indexOf(widget.startStage);
    final int endIdx = widget.stages.indexOf(widget.endStage);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double outerWidth = constraints.maxWidth;
        final double innerWidth = outerWidth - 8.0; // 2px label margin + 2px track padding on each side
        final double itemWidth = innerWidth / widget.stages.length;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Labels Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                children: List.generate(widget.stages.length, (i) {
                  final isSelected = i >= startIdx && i <= endIdx;
                  return SizedBox(
                    width: itemWidth,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (widget.enableHaptics) {
                            HapticFeedback.selectionClick();
                          }
                          widget.onChanged(widget.stages[i], widget.stages[i]);
                        },
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? labelActive : labelInactive,
                            letterSpacing: 0.5,
                          ),
                          child: Text(
                            widget.labels[i],
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Track Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Container(
                key: _trackKey,
                height: 54.0,
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  color: inactiveBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (details) => _handleTouchStart(details.globalPosition),
                  onPanUpdate: (details) => _handleTouchUpdate(details.globalPosition),
                  onPanEnd: (details) => _handleTouchEnd(),
                  onPanCancel: () => _handleTouchEnd(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Animated active pill background
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        left: startIdx * itemWidth,
                        top: 0,
                        bottom: 0,
                        width: ((endIdx - startIdx) + 1) * itemWidth,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: activeBg,
                            borderRadius: BorderRadius.circular(10), // Matched interior border radius (12 - 2px padding = 10px)
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Left grab handle indicator (White cap with mini chevron)
                              Container(
                                width: 16,
                                color: Colors.white,
                                child: Center(
                                  child: Icon(
                                    Icons.chevron_left,
                                    size: 12,
                                    color: activeStroke,
                                  ),
                                ),
                              ),
                              // Middle space showing the parent's activeBg
                              const Expanded(
                                child: SizedBox.shrink(),
                              ),
                              // Right grab handle indicator (White cap with mini chevron)
                              Container(
                                width: 16,
                                color: Colors.white,
                                child: Center(
                                  child: Icon(
                                    Icons.chevron_right,
                                    size: 12,
                                    color: activeStroke,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: List.generate(widget.stages.length, (i) {
                          final isSelected = i >= startIdx && i <= endIdx;
                          return SizedBox(
                            width: itemWidth,
                            child: Center(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: isSelected ? 1.25 : 1.0,
                                curve: Curves.elasticOut,
                                child: SizedBox(
                                  width: 24,
                                  height: 18,
                                  child: CustomPaint(
                                    painter: StepLinesPainter(
                                      stepIndex: i,
                                      color: isSelected ? segmentActiveColor : segmentInactiveColor,
                                      isSelected: isSelected,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
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
