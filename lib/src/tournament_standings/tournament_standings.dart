import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/tournament_standings_models.dart';
import 'models/tournament_standings_style.dart';
import 'widgets/tournament_stage_selector.dart';
import 'widgets/group_stage_column.dart';
import 'widgets/bracket_match_card.dart';

/// A premium split-panel tournament standings and bracket viewer.
///
/// Features a custom sliding stage selector, condensed group tables that remain
/// visible on the left side, and a horizontal scrollable bracket tree in knockout
/// stages, complete with a custom painter for connectors and highlighted team paths.
class TournamentStandings extends StatefulWidget {
  /// Creates a [TournamentStandings] widget.
  const TournamentStandings({
    super.key,
    required this.data,
    this.style = const TournamentStandingsStyle(),
    this.initialStage = TournamentStage.groupStage,
    this.onTeamTap,
    this.onMatchTap,
  });

  /// The tournament standings and bracket matches data.
  final TournamentStandingsData data;

  /// The style configuration.
  final TournamentStandingsStyle style;

  /// The initial stage displayed when loading.
  final TournamentStage initialStage;

  /// Callback when a team is tapped.
  final ValueChanged<TournamentTeam>? onTeamTap;

  /// Callback when a match is tapped.
  final ValueChanged<BracketMatch>? onMatchTap;

  @override
  State<TournamentStandings> createState() => _TournamentStandingsState();
}

class _TournamentStandingsState extends State<TournamentStandings>
    with TickerProviderStateMixin {
  late TournamentStage _startStage;
  late TournamentStage _endStage;
  final ValueNotifier<String?> _highlightedTeamNotifier =
      ValueNotifier<String?>(null);

  late final ScrollController _bracketScrollController;
  late final AnimationController _lineAnimController;
  late final CurvedAnimation _lineAnimation;

  Set<TournamentStage> get _selectedStages {
    final startIdx = TournamentStage.values.indexOf(_startStage);
    final endIdx = TournamentStage.values.indexOf(_endStage);
    final minIdx = math.min(startIdx, endIdx);
    final maxIdx = math.max(startIdx, endIdx);
    return TournamentStage.values.sublist(minIdx, maxIdx + 1).toSet();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialStage == TournamentStage.groupStage) {
      _startStage = TournamentStage.groupStage;
      _endStage = TournamentStage.groupStage;
    } else {
      _startStage = TournamentStage.roundOf32;
      _endStage = TournamentStage.final_;
    }
    _bracketScrollController = ScrollController();
    _lineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _lineAnimation = CurvedAnimation(
      parent: _lineAnimController,
      curve: Curves.linear,
    );
    _lineAnimController.forward();

    _highlightedTeamNotifier.addListener(() {
      _lineAnimController.forward(from: 0.0);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStageColumn(animate: false);
    });
  }

  @override
  void dispose() {
    _lineAnimController.dispose();
    _bracketScrollController.dispose();
    _highlightedTeamNotifier.dispose();
    super.dispose();
  }

  void _scrollToStageColumn({bool animate = true}) {
    if (_bracketScrollController.hasClients) {
      if (animate) {
        _bracketScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _bracketScrollController.jumpTo(0.0);
      }
    }
  }

  void _onStageRangeChanged(TournamentStage start, TournamentStage end) {
    if (widget.style.enableHaptics) {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _startStage = start;
      _endStage = end;
    });

    // Maintain the fully drawn lines when changing stages, rather than replaying from 0
    _lineAnimController.value = 1.0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStageColumn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style;
    final rootBg = style.backgroundColor ?? theme.scaffoldBackgroundColor;
    final contentBg = style.contentBackgroundColor ?? Colors.transparent;

    return Container(
      color: rootBg,
      child: Column(
        children: [
          _buildTopHeader(theme, style),
          _buildStageSelector(theme, style),
          Expanded(
            child: Container(
              color: contentBg,
              child: _buildKnockoutBracketView(theme, style),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(ThemeData theme, TournamentStandingsStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            'https://www.edigitalagency.com.au/wp-content/uploads/new-FIFA-World-Cup-2026-logo-black-PNG-large-size.png',
            height: 45,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          Text(
            'FIFA World Cup 2026',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSelector(ThemeData theme, TournamentStandingsStyle style) {
    final activeColor = style.accentColor ?? theme.colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TournamentStageRangeSelector(
        startStage: _startStage,
        endStage: _endStage,
        stages: TournamentStage.values,
        labels: TournamentStage.values
            .map((s) => s.shortLabel.toUpperCase())
            .toList(),
        onChanged: _onStageRangeChanged,
        accentColor: activeColor,
        enableHaptics: widget.style.enableHaptics,
      ),
    );
  }

  Widget _buildKnockoutBracketView(
    ThemeData theme,
    TournamentStandingsStyle style,
  ) {
    final stages = TournamentStage.values;
    final visibleStages = stages
        .where((stage) => _selectedStages.contains(stage))
        .toList();

    final knockoutStages = visibleStages
        .where((s) => s != TournamentStage.groupStage)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final int visibleCount = visibleStages.length;

        // ── Proportional Column Layout System ─────────────────────
        // Uses a weight-based distribution so every combination of
        // selected stages behaves consistently and adapts to the
        // actual available width instead of using hardcoded pixel
        // breakpoints per stage count.

        final bool hasGroupStage = visibleStages.contains(
          TournamentStage.groupStage,
        );
        final int knockoutCount = visibleCount - (hasGroupStage ? 1 : 0);

        // Adaptive inter-column margins: tighter spacing when more columns are visible
        final double colMargin = visibleCount <= 2
            ? 20.0
            : (visibleCount <= 4 ? 14.0 : 10.0);

        // Account for inter-column gaps and the horizontal scroll padding (16px each side)
        const double scrollPaddingH = 16.0;
        final double totalGaps = visibleCount > 1
            ? (visibleCount - 1) * colMargin
            : 0;
        final double distributableWidth =
            (availableWidth - totalGaps - (2 * scrollPaddingH)).clamp(
              0.0,
              double.infinity,
            );

        // Weight-based proportional allocation:
        // The group column receives 1.6× the width of each knockout column,
        // ensuring the group table always gets adequate space while knockout
        // columns share the remainder evenly.
        const double groupWeight = 1.6;
        const double knockoutWeight = 1.0;

        double groupColWidth = 0;
        double colWidth = 0;

        if (visibleCount == 1) {
          // Single column fills the entire visible area
          if (hasGroupStage) {
            groupColWidth = distributableWidth;
          } else {
            colWidth = distributableWidth;
          }
        } else {
          final double totalWeight =
              (hasGroupStage ? groupWeight : 0) +
              (knockoutCount * knockoutWeight);
          final double unitWidth = distributableWidth / totalWeight;

          groupColWidth = hasGroupStage ? unitWidth * groupWeight : 0;
          colWidth = knockoutCount > 0 ? unitWidth * knockoutWeight : 0;
        }

        // Determine group detail level from the ACTUAL allocated width
        // instead of from the number of visible stages.
        final GroupDetailLevel groupDetailLevel;
        if (groupColWidth >= 260) {
          groupDetailLevel = GroupDetailLevel.full;
        } else if (groupColWidth >= 85) {
          groupDetailLevel = GroupDetailLevel.medium;
        } else {
          groupDetailLevel = GroupDetailLevel.condensed;
        }

        // Card scaling derived from actual column width vs. ideal card width
        final double cardHeightScale = knockoutCount > 0
            ? (colWidth / style.matchCardWidth).clamp(0.45, 1.0)
            : 1.0;
        final double cardHeight = style.matchCardHeight * cardHeightScale;
        final double cardSpacing = style.matchCardSpacing * cardHeightScale;

        // Determine flag visibility in knockout cards from the actual
        // column width — not from cardHeightScale — so that selecting
        // GS+R32 vs SF+F with the same column count behaves identically.
        final bool showFlagsInKnockout = colWidth >= 120;

        int maxMatches = 0;
        if (knockoutStages.isNotEmpty) {
          final firstKnockout = knockoutStages.first;
          maxMatches = widget.data.bracketMatches
              .where((m) => m.stage == firstKnockout)
              .length;
        }

        final double knockoutHeight = (cardHeight + cardSpacing) * maxMatches;

        return SingleChildScrollView(
          child: SingleChildScrollView(
            controller: _bracketScrollController,
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 16.0,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _lineAnimation,
                    builder: (context, _) => CustomPaint(
                      painter: BracketLinesPainter(
                        stages: visibleStages,
                        matches: widget.data.bracketMatches,
                        highlightedTeamId: _highlightedTeamNotifier.value,
                        style: style,
                        theme: theme,
                        colWidth: colWidth,
                        groupColWidth: groupColWidth,
                        colMargin: colMargin,
                        cardHeight: cardHeight,
                        cardSpacing: cardSpacing,
                        animationProgress: _lineAnimation.value,
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: visibleStages.map((stage) {
                    final isSelected = _selectedStages.contains(stage);
                    final isLastSelected = stage == visibleStages.last;
                    final double targetWidth =
                        stage == TournamentStage.groupStage
                        ? groupColWidth
                        : colWidth;
                    final double width = isSelected ? targetWidth : 0.0;
                    final double marginRight = (isSelected && !isLastSelected)
                        ? colMargin
                        : 0.0;

                    if (stage == TournamentStage.groupStage) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        width: width,
                        margin: EdgeInsets.only(right: marginRight),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          clipBehavior: Clip.none,
                          child: SizedBox(
                            width: targetWidth,
                            child: GroupStandingsColumn(
                              data: widget.data,
                              style: style,
                              detailLevel: groupDetailLevel,
                              selectedStages: _selectedStages,
                              highlightedTeamNotifier: _highlightedTeamNotifier,
                              onTeamTap: widget.onTeamTap,
                            ),
                          ),
                        ),
                      );
                    }

                    final colIndex = knockoutStages.indexOf(stage);
                    final displayColIndex = colIndex != -1 ? colIndex : 0;
                    final matchesInStage =
                        widget.data.bracketMatches
                            .where((m) => m.stage == stage)
                            .toList()
                          ..sort(
                            (a, b) => a.roundIndex.compareTo(b.roundIndex),
                          );

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      width: width,
                      margin: EdgeInsets.only(right: marginRight),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        clipBehavior: Clip.none,
                        child: SizedBox(
                          width: targetWidth,
                          height: knockoutHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ...matchesInStage.map((match) {
                                final double slotHeight =
                                    (cardHeight + cardSpacing) *
                                    math.pow(2, displayColIndex);
                                final double y =
                                    (match.roundIndex * slotHeight) +
                                    (slotHeight / 2) -
                                    (cardHeight / 2);

                                // Map this card's column index to its transition entry point on the animation timeline.
                                // The line leading INTO this column starts drawing at (displayColIndex - 1) / totalSegments
                                // and finishes drawing at displayColIndex / totalSegments.
                                // When the line finishes drawing (or progress passes that point), we trigger a bouncy scale feedback.
                                final int knockoutCount = knockoutStages.length;
                                final double totalSegments = knockoutCount > 1
                                    ? (knockoutCount - 1).toDouble()
                                    : 1.0;
                                final double lineArrivalProgress =
                                    displayColIndex > 0
                                    ? (displayColIndex.toDouble() /
                                              totalSegments)
                                          .clamp(0.0, 1.0)
                                    : 0.0;

                                return Positioned(
                                  top: y,
                                  left: 4.0,
                                  right: 4.0,
                                  height: cardHeight,
                                  child: AnimatedBuilder(
                                    animation: _lineAnimation,
                                    builder: (context, child) {
                                      final double currentProgress =
                                          _lineAnimation.value;

                                      // If a team is selected and is in this match, we trigger a bounce scale when the line reaches it
                                      final bool isHighlightedMatch =
                                          (match.teamA != null &&
                                              _highlightedTeamNotifier.value ==
                                                  match.teamA!.id) ||
                                          (match.teamB != null &&
                                              _highlightedTeamNotifier.value ==
                                                  match.teamB!.id);

                                      double scaleFactor = 1.0;
                                      final bool isReached =
                                          currentProgress >=
                                          lineArrivalProgress;

                                      if (isHighlightedMatch && isReached) {
                                        final double diff =
                                            currentProgress -
                                            lineArrivalProgress;
                                        if (diff < 0.25) {
                                          final double t = diff / 0.25;
                                          // Scale bounce animation
                                          scaleFactor =
                                              1.0 +
                                              (math.sin(t * math.pi) * 0.12);
                                        } else {
                                          scaleFactor = 1.05;
                                        }
                                      }

                                      return Transform.scale(
                                        scale: scaleFactor,
                                        child: BracketMatchCard(
                                          match: match,
                                          style: style,
                                          highlightedTeamNotifier:
                                              _highlightedTeamNotifier,
                                          cardHeightScale: cardHeightScale,
                                          showFlags: showFlagsInKnockout,
                                          isReached: isReached,
                                          onMatchTap: widget.onMatchTap,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BracketLinesPainter extends CustomPainter {
  /// Creates a [BracketLinesPainter].
  const BracketLinesPainter({
    required this.stages,
    required this.matches,
    required this.highlightedTeamId,
    required this.style,
    required this.theme,
    required this.colWidth,
    required this.groupColWidth,
    required this.colMargin,
    required this.cardHeight,
    required this.cardSpacing,
    this.animationProgress = 1.0,
  });

  /// The knockout stages in order.
  final List<TournamentStage> stages;

  /// All bracket matches.
  final List<BracketMatch> matches;

  /// The team ID currently highlighted/focused by user taps.
  final String? highlightedTeamId;

  /// Styling configurations.
  final TournamentStandingsStyle style;

  /// The surrounding theme data.
  final ThemeData theme;

  /// Width of each match card column.
  final double colWidth;

  /// Width of the group standings column.
  final double groupColWidth;

  /// Horizontal margin between columns.
  final double colMargin;

  /// Height of match cards.
  final double cardHeight;

  /// Vertical spacing between match cards.
  final double cardSpacing;

  /// Progress of the drawing animation (0.0 = nothing drawn, 1.0 = fully drawn).
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = style.connectingLineColor ?? Colors.grey.shade400
      ..strokeWidth = style.connectingLineThickness
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = style.accentColor ?? theme.colorScheme.onSurface
      ..strokeWidth = style.connectingLineThickness + 1.0
      ..style = PaintingStyle.stroke;

    // Loop through stages to connect col `c` to col `c + 1`
    for (int c = 0; c < stages.length - 1; c++) {
      final currentStage = stages[c];
      final nextStage = stages[c + 1];

      // If either stage is groupStage, do not paint connecting lines
      if (currentStage == TournamentStage.groupStage ||
          nextStage == TournamentStage.groupStage) {
        continue;
      }

      final currentMatches = matches
          .where((m) => m.stage == currentStage)
          .toList();
      final nextMatches = matches.where((m) => m.stage == nextStage).toList();

      // Find the visual index of this transition among visible knockout stages
      final List<TournamentStage> visibleKnockoutStages = stages
          .where((s) => s != TournamentStage.groupStage)
          .toList();
      final int transitionsCount = visibleKnockoutStages.length - 1;
      final int transitionIndex = visibleKnockoutStages.indexOf(currentStage);

      // Determine local progress for this transition segment
      double stageProgress = 1.0;
      if (transitionsCount > 0 && transitionIndex >= 0) {
        final double segmentMin = transitionIndex / transitionsCount;
        final double segmentMax = (transitionIndex + 1) / transitionsCount;
        if (animationProgress <= segmentMin) {
          stageProgress = 0.0;
        } else if (animationProgress >= segmentMax) {
          stageProgress = 1.0;
        } else {
          stageProgress =
              (animationProgress - segmentMin) / (segmentMax - segmentMin);
        }
      }

      for (final match in currentMatches) {
        if (match.nextMatchId == null) continue;

        // Find the destination match in the next column
        final nextMatch = nextMatches.firstWhere(
          (m) => m.id == match.nextMatchId,
          orElse: () =>
              const BracketMatch(id: '', stage: TournamentStage.final_),
        );
        if (nextMatch.id.isEmpty) continue;

        // Calculate positioning
        // Current match column X coordinates based on single-side right margin
        double currentStartX = 0.0;
        for (int i = 0; i < c; i++) {
          if (stages[i] == TournamentStage.groupStage) {
            currentStartX += groupColWidth + colMargin;
          } else {
            currentStartX += colWidth + colMargin;
          }
        }
        final double currentEndX = currentStartX + colWidth - 4.0;

        // Next match column X coordinates
        final double nextStartX = currentStartX + colWidth + colMargin + 4.0;

        // Calculate Y coordinates using relative stage indices based on visible knockout stages
        final int currentStageIndex = visibleKnockoutStages.indexOf(
          currentStage,
        );
        final int nextStageIndex = visibleKnockoutStages.indexOf(
          nextMatch.stage,
        );

        final double currentSlotHeight =
            (cardHeight + cardSpacing) * math.pow(2, currentStageIndex);
        final double currentY =
            (match.roundIndex * currentSlotHeight) + (currentSlotHeight / 2);

        final double nextSlotHeight =
            (cardHeight + cardSpacing) * math.pow(2, nextStageIndex);
        final double nextY =
            (nextMatch.roundIndex * nextSlotHeight) + (nextSlotHeight / 2);

        // Path coordinates (midpoint is exactly halfway across the margin)
        final double midX = (currentEndX + nextStartX) / 2;

        final double cornerRadius = math.min(12.0, ((nextStartX - currentEndX) / 2).abs());
        final double verticalDistance = (nextY - currentY).abs();
        final double actualRadius = math.min(
          cornerRadius,
          verticalDistance / 2,
        );
        final double signY = nextY > currentY ? 1.0 : -1.0;

        final path = Path();
        path.moveTo(currentEndX, currentY);

        if (actualRadius > 0) {
          path.lineTo(midX - actualRadius, currentY);
          path.quadraticBezierTo(
            midX,
            currentY,
            midX,
            currentY + actualRadius * signY,
          );
          path.lineTo(midX, nextY - actualRadius * signY);
          path.quadraticBezierTo(midX, nextY, midX + actualRadius, nextY);
        } else {
          path.lineTo(midX, currentY);
          path.lineTo(midX, nextY);
        }

        path.lineTo(nextStartX, nextY);

        // Determine if this path should be highlighted
        bool shouldHighlight = false;
        if (highlightedTeamId != null &&
            match.winner != null &&
            match.winner!.id == highlightedTeamId) {
          if (nextMatch.teamA?.id == highlightedTeamId ||
              nextMatch.teamB?.id == highlightedTeamId) {
            shouldHighlight = true;
          }
        }

        // Draw the background connector lines (always visible)
        canvas.drawPath(path, linePaint);

        // If this path is highlighted, we animate the highlight "lighting up" sequentially
        if (shouldHighlight) {
          // If the animation has progressed past this transition segment, light it up
          for (final metric in path.computeMetrics()) {
            final drawLength = metric.length * stageProgress;
            if (drawLength > 0) {
              canvas.drawPath(
                metric.extractPath(0, drawLength),
                highlightPaint,
              );
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BracketLinesPainter oldDelegate) {
    return oldDelegate.highlightedTeamId != highlightedTeamId ||
        oldDelegate.stages != stages ||
        oldDelegate.matches != matches ||
        oldDelegate.animationProgress != animationProgress;
  }
}

/// A premium stage range selector with a modern segmented track design.
///
/// Highlights the active range with an animated pill overlay and provides
/// small arrow handles on the left and right to adjust the selection.
