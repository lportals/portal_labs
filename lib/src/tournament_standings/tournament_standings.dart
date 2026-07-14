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
    this.stageLabelBuilder,
    this.stageIconBuilder,
    this.headerBuilder,
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

  /// Optional builder to customize the stage names in the slider and column headers (localization).
  final String Function(BuildContext context, TournamentStage stage)? stageLabelBuilder;

  /// Optional builder to provide custom icons for each stage in the slider range selector.
  final Widget Function(BuildContext context, TournamentStage stage, bool isSelected)? stageIconBuilder;

  /// Optional builder to customize the top logo/title header section.
  final Widget Function(BuildContext context)? headerBuilder;

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

  // ── Layout transition animation ────────────────────────────────
  // A dedicated controller that drives synchronized interpolation
  // of ALL layout values so column widths and painter coordinates
  // are always perfectly in sync during transitions.
  late final AnimationController _layoutAnimController;
  late final CurvedAnimation _layoutAnimation;

  // Cached layout values from the previous settled build pass.
  // These become the "from" snapshot when a new stage transition begins.
  final Map<TournamentStage, double> _cachedStageWidths = {};
  final Map<TournamentStage, double> _cachedStageMargins = {};
  double _cachedCardHeightScale = 1.0;

  // "From" snapshot captured at the moment of stage change.
  Map<TournamentStage, double> _fromStageWidths = {};
  Map<TournamentStage, double> _fromStageMargins = {};
  double _fromCardHeightScale = 1.0;
  bool _hasLayoutSnapshot = false;

  Set<TournamentStage> get _selectedStages {
    final activeStages = widget.data.activeStages;
    if (activeStages.isEmpty) return {};
    final startIdx = activeStages.indexOf(_startStage);
    final endIdx = activeStages.indexOf(_endStage);
    if (startIdx == -1 || endIdx == -1) return {activeStages.first};
    final minIdx = math.min(startIdx, endIdx);
    final maxIdx = math.max(startIdx, endIdx);
    return activeStages.sublist(minIdx, maxIdx + 1).toSet();
  }

  @override
  void initState() {
    super.initState();
    final activeStages = widget.data.activeStages;
    if (activeStages.isNotEmpty) {
      if (activeStages.contains(widget.initialStage)) {
        _startStage = widget.initialStage;
        _endStage = widget.initialStage;
      } else {
        _startStage = activeStages.first;
        _endStage = activeStages.first;
      }
    } else {
      _startStage = TournamentStage.groupStage;
      _endStage = TournamentStage.groupStage;
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

    // Layout transition: 300ms ease-out (Emil: entering content = ease-out)
    _layoutAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _layoutAnimation = CurvedAnimation(
      parent: _layoutAnimController,
      curve: Curves.easeOut,
    );
    // Start fully settled so the first build uses target values directly.
    _layoutAnimController.value = 1.0;

    _highlightedTeamNotifier.addListener(() {
      _lineAnimController.forward(from: 0.0);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStageColumn(animate: false);
    });
  }

  @override
  void dispose() {
    _layoutAnimController.dispose();
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

    // Capture current layout values as the "from" snapshot before
    // the stage selection changes so we can lerp smoothly.
    _fromStageWidths = Map.of(_cachedStageWidths);
    _fromStageMargins = Map.of(_cachedStageMargins);
    _fromCardHeightScale = _cachedCardHeightScale;
    _hasLayoutSnapshot = true;

    setState(() {
      _startStage = start;
      _endStage = end;
    });

    // Drive both the layout transition and the line drawing animation
    // from the same starting point so they stay synchronized.
    _layoutAnimController.forward(from: 0.0);
    _lineAnimController.forward(from: 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStageColumn();
    });
  }

  /// Linearly interpolates between [a] and [b] by factor [t].
  static double _lerp(double a, double b, double t) => a + (b - a) * t;

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
    if (widget.headerBuilder != null) {
      return widget.headerBuilder!(context);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            'https://www.edigitalagency.com.au/wp-content/uploads/new-FIFA-World-Cup-2026-logo-black-PNG-large-size.png',
            height: 45,
            fit: BoxFit.contain,
            gaplessPlayback: true,
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
    final activeStages = widget.data.activeStages;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TournamentStageRangeSelector(
        startStage: _startStage,
        endStage: _endStage,
        stages: activeStages,
        labels: activeStages
            .map((s) => widget.stageLabelBuilder?.call(context, s) ?? s.shortLabel.toUpperCase())
            .toList(),
        onChanged: _onStageRangeChanged,
        accentColor: activeColor,
        enableHaptics: widget.style.enableHaptics,
        stageIconBuilder: widget.stageIconBuilder,
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



    // Wrap in AnimatedBuilder so the build re-runs on every layout
    // animation tick, producing smoothly interpolated values.
    return AnimatedBuilder(
      animation: _layoutAnimation,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final int visibleCount = visibleStages.length;

          // ── Proportional Column Layout System ─────────────────────
          final bool hasGroupStage = visibleStages.contains(
            TournamentStage.groupStage,
          );
          final int knockoutCount = visibleCount - (hasGroupStage ? 1 : 0);

          // Compute TARGET layout values for the current stage selection
          final double targetColMargin = visibleCount <= 2
              ? 12.0
              : (visibleCount <= 4 ? 8.0 : 6.0);

          const double scrollPaddingH = 8.0;
          final double targetTotalGaps = visibleCount > 1
              ? (visibleCount - 1) * targetColMargin
              : 0;
          final double targetDistributableWidth =
              (availableWidth - targetTotalGaps - (2 * scrollPaddingH)).clamp(
                0.0,
                double.infinity,
              );

          const double groupWeight = 1.0;
          const double knockoutWeight = 1.0;

          double targetGroupColWidth = 0;
          double targetColWidth = 0;

          if (visibleCount == 1) {
            if (hasGroupStage) {
              targetGroupColWidth = targetDistributableWidth;
            } else {
              targetColWidth = targetDistributableWidth;
            }
          } else if (visibleCount > 1) {
            final double totalWeight =
                (hasGroupStage ? groupWeight : 0) +
                (knockoutCount * knockoutWeight);
            final double unitWidth = targetDistributableWidth / totalWeight;

            targetGroupColWidth = hasGroupStage ? unitWidth * groupWeight : 0;
            targetColWidth = knockoutCount > 0 ? unitWidth * knockoutWeight : 0;
          }

          final double targetCardHeightScale = knockoutCount > 0
              ? (targetColWidth / style.matchCardWidth).clamp(0.45, 1.0)
              : 1.0;

          // ── Synchronized lerp ──────────────────────────────────────
          final double t = _layoutAnimation.value;
          
          Map<TournamentStage, double> currentWidths = {};
          Map<TournamentStage, double> currentMargins = {};

          for (final stage in TournamentStage.values) {
            final isSelected = _selectedStages.contains(stage);
            final double targetW = isSelected
                ? (stage == TournamentStage.groupStage ? targetGroupColWidth : targetColWidth)
                : 0.0;
            
            final isLastSelected = stage == visibleStages.lastOrNull;
            final double targetM = (isSelected && !isLastSelected) ? targetColMargin : 0.0;

            currentWidths[stage] = _hasLayoutSnapshot
                ? _lerp(_fromStageWidths[stage] ?? 0.0, targetW, t)
                : targetW;
                
            currentMargins[stage] = _hasLayoutSnapshot
                ? _lerp(_fromStageMargins[stage] ?? 0.0, targetM, t)
                : targetM;
                
            _cachedStageWidths[stage] = currentWidths[stage]!;
            _cachedStageMargins[stage] = currentMargins[stage]!;
          }

          final double cardHeightScale = _hasLayoutSnapshot
              ? _lerp(_fromCardHeightScale, targetCardHeightScale, t)
              : targetCardHeightScale;
          _cachedCardHeightScale = cardHeightScale;

          // ── Derived values from the (possibly lerped) dimensions ──
          final double cardHeight = style.matchCardHeight * cardHeightScale;
          final double cardSpacing = style.matchCardSpacing * cardHeightScale;



          final groupWidth = currentWidths[TournamentStage.groupStage] ?? 0.0;
          final GroupDetailLevel groupDetailLevel;
          if (groupWidth >= 260) {
            groupDetailLevel = GroupDetailLevel.full;
          } else if (groupWidth >= 85) {
            groupDetailLevel = GroupDetailLevel.medium;
          } else {
            groupDetailLevel = GroupDetailLevel.condensed;
          }

          // Use the target knockout column width for visibility decisions 
          // so they don't pop during transitions
          final bool showFlagsInKnockout = targetColWidth >= 120;

          // ── Compute explicit total dimensions for the Stack ──────
          double totalStackWidth = 0;
          for (final stage in TournamentStage.values) {
            totalStackWidth += currentWidths[stage] ?? 0.0;
            totalStackWidth += currentMargins[stage] ?? 0.0;
          }

          // Only render columns that have some visible width
          final renderedStages = TournamentStage.values
              .where((s) => (currentWidths[s] ?? 0) > 0.1)
              .toList();

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 16.0),
            child: SingleChildScrollView(
              controller: _bracketScrollController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: SizedBox(
                width: totalStackWidth,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _lineAnimation,
                        builder: (context, _) => CustomPaint(
                          painter: BracketLinesPainter(
                            stages: renderedStages,
                            selectedStages: _selectedStages,
                            matches: widget.data.bracketMatches,
                            highlightedTeamId: _highlightedTeamNotifier.value,
                            style: style,
                            theme: theme,
                            stageWidths: currentWidths,
                            stageMargins: currentMargins,
                            cardHeight: cardHeight,
                            cardSpacing: cardSpacing,
                            animationProgress: _lineAnimation.value,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: renderedStages.map((stage) {
                        final isSelected = _selectedStages.contains(stage);
                        final double stageWidth = currentWidths[stage] ?? 0.0;
                        final double marginRight = currentMargins[stage] ?? 0.0;
                        if (stage == TournamentStage.groupStage) {
                          return Container(
                            clipBehavior: isSelected ? Clip.none : Clip.hardEdge,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: stageWidth,
                            margin: EdgeInsets.only(right: marginRight),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              opacity: isSelected ? 1.0 : 0.0,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const NeverScrollableScrollPhysics(),
                                clipBehavior: Clip.none,
                                child: SizedBox(
                                  width: stageWidth,
                                  child: GroupStandingsColumn(
                                    data: widget.data,
                                    style: style,
                                    detailLevel: groupDetailLevel,
                                    selectedStages: _selectedStages,
                                    highlightedTeamNotifier: _highlightedTeamNotifier,
                                    topPadding: cardSpacing / 2,
                                    onTeamTap: widget.onTeamTap,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final knockoutStages = visibleStages
                            .where((s) => s != TournamentStage.groupStage)
                            .toList();
                        final int colIndex = knockoutStages.indexOf(stage);
                        final matchesInStage =
                            widget.data.bracketMatches
                                .where((m) => m.stage == stage)
                                .toList()
                              ..sort(
                                (a, b) => a.roundIndex.compareTo(b.roundIndex),
                              );

                        final double knockoutHeight = (cardHeight + cardSpacing) * 
                            math.pow(2, knockoutStages.length - 1);

                        return Container(
                          clipBehavior: isSelected ? Clip.none : Clip.hardEdge,
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          width: stageWidth,
                          margin: EdgeInsets.only(right: marginRight),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            opacity: isSelected ? 1.0 : 0.0,
                            child: SizedBox(
                              width: stageWidth,
                              height: knockoutHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ...matchesInStage.map((match) {
                                    final double slotHeight =
                                        (cardHeight + cardSpacing) *
                                        math.pow(2, colIndex);
                                    final double y =
                                        (match.roundIndex * slotHeight) +
                                        (slotHeight / 2) -
                                        (cardHeight / 2);

                                    final int knockoutCount = knockoutStages.length;
                                    final double totalSegments = knockoutCount > 1
                                        ? (knockoutCount - 1).toDouble()
                                        : 1.0;
                                    final double lineArrivalProgress =
                                        colIndex > 0
                                        ? (colIndex.toDouble() /
                                                  totalSegments)
                                              .clamp(0.0, 1.0)
                                        : 0.0;

                                    return Positioned(
                                      top: y,
                                      left: 0,
                                      right: 0,
                                      height: cardHeight,
                                      child: AnimatedBuilder(
                                        animation: _lineAnimation,
                                        builder: (context, child) {
                                          final double currentProgress =
                                              _lineAnimation.value;

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
                                              showDateHeader: visibleCount <= 2,
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
            ),
          );
        },
      ),
    );
  }
}

/// A custom painter that draws connecting bracket lines between stages in a knockout tournament.
class BracketLinesPainter extends CustomPainter {
  /// Creates a [BracketLinesPainter].
  const BracketLinesPainter({
    required this.stages,
    required this.selectedStages,
    required this.matches,
    required this.highlightedTeamId,
    required this.style,
    required this.theme,
    required this.stageWidths,
    required this.stageMargins,
    required this.cardHeight,
    required this.cardSpacing,
    this.animationProgress = 1.0,
  });

  /// The knockout stages in order.
  final List<TournamentStage> stages;

  /// The set of active selected stages in the range selector.
  final Set<TournamentStage> selectedStages;

  /// All bracket matches.
  final List<BracketMatch> matches;

  /// The team ID currently highlighted/focused by user taps.
  final String? highlightedTeamId;

  /// Styling configurations.
  final TournamentStandingsStyle style;

  /// The surrounding theme data.
  final ThemeData theme;

  /// Width of each match card column.
  final Map<TournamentStage, double> stageWidths;

  /// Horizontal margin between columns.
  final Map<TournamentStage, double> stageMargins;

  /// Height of match cards.
  final double cardHeight;

  /// Vertical spacing between match cards.
  final double cardSpacing;

  /// Progress of the drawing animation (0.0 = nothing drawn, 1.0 = fully drawn).
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (stages.isEmpty) return;

    double getXForStage(TournamentStage stage) {
      double x = 0;
      for (final s in stages) {
        if (s == stage) break;
        x += stageWidths[s] ?? 0.0;
        x += stageMargins[s] ?? 0.0;
      }
      return x;
    }

    // ── Adaptive line thickness ──────────────────────────────────
    final double avgWidth = stages.isEmpty ? 200 : (stages.map((s) => stageWidths[s] ?? 0).reduce((a, b) => a + b) / stages.length);
    final double scaleRatio = avgWidth > 0
        ? (avgWidth / 200.0).clamp(0.5, 1.0)
        : 1.0;
    final double effectiveThickness = math.max(
      1.0,
      style.connectingLineThickness * scaleRatio,
    );

    final linePaint = Paint()
      ..color = style.connectingLineColor ?? Colors.grey.shade400
      ..strokeWidth = effectiveThickness
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final highlightPaint = Paint()
      ..color = style.accentColor ?? theme.colorScheme.onSurface
      ..strokeWidth = effectiveThickness + 1.0
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final List<TournamentStage> visibleKnockoutStages = stages
        .where((s) => s != TournamentStage.groupStage && selectedStages.contains(s))
        .toList();

    // Loop through stages to connect col `c` to col `c + 1`
    for (int c = 0; c < stages.length - 1; c++) {
      final currentStage = stages[c];
      final nextStage = stages[c + 1];

      // If either stage is groupStage, or if either stage is not selected/active in the selector, do not paint connecting lines
      if (currentStage == TournamentStage.groupStage ||
          nextStage == TournamentStage.groupStage ||
          !selectedStages.contains(currentStage) ||
          !selectedStages.contains(nextStage) ||
          (stageWidths[currentStage] ?? 0.0) < 1.0 ||
          (stageWidths[nextStage] ?? 0.0) < 1.0) {
        continue;
      }

      final currentMatches = matches
          .where((m) => m.stage == currentStage)
          .toList();
      final nextMatches = matches.where((m) => m.stage == nextStage).toList();

      final int transitionsCount = stages.length - 1;
      final int transitionIndex = c;

      // Determine local progress for this transition segment
      double stageProgress = 1.0;
      if (transitionsCount > 0) {
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

        final nextMatch = nextMatches.firstWhere(
          (m) => m.id == match.nextMatchId,
          orElse: () =>
              const BracketMatch(id: '', stage: TournamentStage.final_),
        );
        if (nextMatch.id.isEmpty) continue;

        // Current match column X coordinates — card edges now at 0/stageWidth
        final double currentStartX = getXForStage(currentStage);
        final double currentStageWidth = stageWidths[currentStage] ?? 0.0;
        final double currentEndX = currentStartX + currentStageWidth;

        // Next match column X coordinates
        final double nextStartX = getXForStage(nextStage);

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

        // ── Minimum corner radius enforcement ───────────────────
        // Clamp to at least 4px so rounded corners don't collapse
        // into zero-radius straight segments at tight column spacing.
        final double gap = (nextStartX - currentEndX).abs();
        final double cornerRadius = math.max(4.0, math.min(12.0, gap / 2));
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
        oldDelegate.selectedStages != selectedStages ||
        oldDelegate.matches != matches ||
        oldDelegate.stageWidths != stageWidths ||
        oldDelegate.stageMargins != stageMargins ||
        oldDelegate.cardHeight != cardHeight ||
        oldDelegate.cardSpacing != cardSpacing ||
        oldDelegate.animationProgress != animationProgress;
  }
}

/// A premium stage range selector with a modern segmented track design.
///
/// Highlights the active range with an animated pill overlay and provides
/// small arrow handles on the left and right to adjust the selection.
