import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/portal_animations.dart';
import 'models/tournament_standings_models.dart';
import 'models/tournament_standings_style.dart';

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
    with SingleTickerProviderStateMixin {
  late TournamentStage _startStage;
  late TournamentStage _endStage;
  String? _highlightedTeamId;

  late final ScrollController _bracketScrollController;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStageColumn(animate: false);
    });
  }

  @override
  void dispose() {
    _bracketScrollController.dispose();
    super.dispose();
  }

  void _scrollToStageColumn({bool animate = true}) {
    final visibleStages = TournamentStage.values
        .where((stage) => _selectedStages.contains(stage))
        .toList();

    if (visibleStages.isEmpty) return;

    final firstStage = visibleStages.first;
    final colIndex = TournamentStage.values.indexOf(firstStage);
    if (colIndex <= 0) {
      if (_bracketScrollController.hasClients) {
        if (animate) {
          _bracketScrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 500),
            curve: const PortalSpringCurve(),
          );
        } else {
          _bracketScrollController.jumpTo(0.0);
        }
      }
      return;
    }

    const double colMargin = 24.0;
    final double groupColWidth = math.max(widget.style.matchCardWidth * 1.6, 320.0);
    final double matchColWidth = widget.style.matchCardWidth;

    double targetScroll = 0.0;
    for (int i = 0; i < colIndex; i++) {
      if (TournamentStage.values[i] == TournamentStage.groupStage) {
        targetScroll += groupColWidth + colMargin * 2;
      } else {
        targetScroll += matchColWidth + colMargin * 2;
      }
    }

    if (_bracketScrollController.hasClients) {
      if (animate) {
        _bracketScrollController.animateTo(
          targetScroll.clamp(0.0, _bracketScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: const PortalSpringCurve(),
        );
      } else {
        _bracketScrollController.jumpTo(
          targetScroll.clamp(0.0, _bracketScrollController.position.maxScrollExtent),
        );
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToStageColumn();
    });
  }

  void _toggleTeamHighlight(String teamId) {
    setState(() {
      if (_highlightedTeamId == teamId) {
        _highlightedTeamId = null;
      } else {
        _highlightedTeamId = teamId;
      }
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
      child: Center(
        child: Text(
          'FIFA World Cup 2026',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildStageSelector(ThemeData theme, TournamentStandingsStyle style) {
    final activeColor = style.accentColor ?? theme.primaryColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TournamentStageRangeSelector(
        startStage: _startStage,
        endStage: _endStage,
        stages: TournamentStage.values,
        labels: TournamentStage.values.map((s) => s.shortLabel.toUpperCase()).toList(),
        onChanged: _onStageRangeChanged,
        accentColor: activeColor,
        enableHaptics: widget.style.enableHaptics,
      ),
    );
  }

  Widget _buildGroupStandingsColumn(
    ThemeData theme,
    TournamentStandingsStyle style, {
    required bool isCondensed,
    required bool isMedium,
  }) {
    final accent = style.accentColor ?? theme.primaryColor;
    final cardBg = style.matchCardBackgroundColor ?? theme.cardColor;
    final borderColor = style.matchCardBorderColor ?? theme.dividerColor.withValues(alpha: 0.10);

    if (isCondensed) {
      return ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: widget.data.groups.length,
        itemBuilder: (context, index) {
          final group = widget.data.groups[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimal header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Text(
                    'Group ${group.id}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Container(
                  height: 0.5,
                  color: theme.dividerColor.withValues(alpha: 0.08),
                ),
                ...group.standings.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final team = entry.value;
                  final advances = idx < 2;
                  final isOnBubble = idx == 2;

                  Color barColor = Colors.transparent;
                  final onlyGroupStageSelected = _startStage == TournamentStage.groupStage && _endStage == TournamentStage.groupStage;
                  if (!onlyGroupStageSelected) {
                    if (advances) {
                      barColor = Colors.green.shade400;
                    } else if (isOnBubble) {
                      barColor = Colors.amber.shade500;
                    }
                  }

                  final isHighlighted = _highlightedTeamId == team.id;
                  final isLastRow = idx == group.standings.length - 1;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (idx == 2)
                        Container(
                          height: 1.0,
                          color: theme.dividerColor.withValues(alpha: 0.25),
                        ),
                      GestureDetector(
                        onTap: () {
                          _toggleTeamHighlight(team.id);
                          widget.onTeamTap?.call(team);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 6.0),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? accent.withValues(alpha: 0.10)
                                : Colors.transparent,
                            borderRadius: isLastRow
                                ? const BorderRadius.vertical(bottom: Radius.circular(10))
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: -6.0,
                                top: -5.0,
                                bottom: -5.0,
                                width: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: team.primaryColor ?? Color(team.code.hashCode | 0xFF000000),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(isLastRow ? 10 : 0),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  // Margin to offset content due to color bar
                                  const SizedBox(width: 4),
                                  if (widget.style.showQualificationIndicators) ...[
                                    Container(
                                      width: 3,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: barColor,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    team.code,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                                      color: isHighlighted ? accent : theme.textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      );
    }

    // Column header labels for the stats table
    final statHeaders = isMedium ? ['PTS'] : ['GP', 'W', 'D', 'L', 'GD', 'PTS'];

    TextStyle statHeaderStyle(bool bold) => TextStyle(
          fontSize: 9,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: bold ? accent : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.45),
          letterSpacing: 0.8,
        );

    TextStyle statCellStyle(bool highlighted, bool bold) => TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          color: highlighted
              ? accent
              : theme.textTheme.bodyMedium?.color?.withValues(alpha: bold ? 1.0 : 0.75),
        );

    Widget statCell(String value, {bool bold = false, bool highlighted = false}) {
      return SizedBox(
        width: 26,
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: statCellStyle(highlighted, bold),
        ),
      );
    }

    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: widget.data.groups.length,
      itemBuilder: (context, index) {
        final group = widget.data.groups[index];
        return Container(
          margin: EdgeInsets.only(bottom: isMedium ? 10 : 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(isMedium ? 10 : 14),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Group Header ───────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMedium ? 8 : 12, vertical: 9),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(isMedium ? 10 : 14)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // Stat column headers aligned with stat cells below
                    ...statHeaders.map((h) => SizedBox(
                          width: 26,
                          child: Text(
                            h,
                            textAlign: TextAlign.center,
                            style: statHeaderStyle(h == 'PTS'),
                          ),
                        )),
                  ],
                ),
              ),
              // Divider line below header
              Container(
                height: 1,
                color: accent.withValues(alpha: 0.10),
              ),
              // ── Standings rows ─────────────────────────────
              ...group.standings.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final team = entry.value;
                final isHighlighted = _highlightedTeamId == team.id;
                final advancesAutomatically = rank <= 2;
                final isOnBubble = rank == 3;

                // Promotion indicator color
                Color qualColor = Colors.transparent;
                final onlyGroupStageSelected = _startStage == TournamentStage.groupStage && _endStage == TournamentStage.groupStage;
                if (!onlyGroupStageSelected) {
                  if (advancesAutomatically) {
                    qualColor = Colors.green.shade400;
                  } else if (isOnBubble) {
                    qualColor = Colors.amber.shade500;
                  }
                }

                final isLastRow = rank == group.standings.length;
                final double paddingVal = isMedium ? 8.0 : 12.0;
                final gd = team.goalDifference;
                final gdStr = gd >= 0 ? '+$gd' : '$gd';

                return GestureDetector(
                  onTap: () {
                    _toggleTeamHighlight(team.id);
                    widget.onTeamTap?.call(team);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? accent.withValues(alpha: 0.10)
                          : Colors.transparent,
                      border: isLastRow
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: theme.dividerColor.withValues(alpha: 0.06),
                              ),
                            ),
                      borderRadius: isLastRow
                          ? BorderRadius.vertical(bottom: Radius.circular(isMedium ? 10 : 14))
                          : null,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: paddingVal, vertical: 9),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.none,
                      children: [
                        // Left Team Color Bar (when isMedium is true)
                        if (isMedium)
                          Positioned(
                            left: -paddingVal,
                            top: -9,
                            bottom: -9,
                            width: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: team.primaryColor ?? Color(team.code.hashCode | 0xFF000000),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(isLastRow ? 10 : 0),
                                ),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            // Qualification bar
                            if (widget.style.showQualificationIndicators && !isMedium) ...[
                              Container(
                                width: 3,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: qualColor,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              ),
                              SizedBox(width: isMedium ? 5 : 7),
                            ],
                            // Rank number
                            SizedBox(
                              width: isMedium ? 10 : 14,
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            SizedBox(width: isMedium ? 4 : 6),
                            // Flag (Only when not in medium mode)
                            if (!isMedium) ...[
                              if (team.flagUrl != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Image.network(
                                    team.flagUrl!,
                                    width: 20,
                                    height: 13,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => _buildFlagFallback(team.code),
                                  ),
                                )
                              else
                                _buildFlagFallback(team.code),
                              const SizedBox(width: 8),
                            ],
                            // Team name
                            Expanded(
                              child: Text(
                                isMedium ? team.code : team.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                                  color: isHighlighted
                                      ? accent
                                      : theme.textTheme.bodyMedium?.color,
                                ),
                              ),
                            ),
                            // Stats cells: GD PTS
                            if (!isMedium) ...[
                              statCell('${team.played}'),
                              statCell('${team.wins}'),
                              statCell('${team.draws}'),
                              statCell('${team.losses}'),
                              statCell(gdStr),
                            ],
                            statCell('${team.points}', bold: true, highlighted: isHighlighted),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlagFallback(String code) {
    return Container(
      width: 18,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Text(
          code.substring(0, math.min(2, code.length)),
          style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKnockoutBracketView(ThemeData theme, TournamentStandingsStyle style) {
    final stages = TournamentStage.values;
    final visibleStages = stages
        .where((stage) => _selectedStages.contains(stage))
        .toList();

    final knockoutStages = visibleStages.where((s) => s != TournamentStage.groupStage).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        final int visibleCount = visibleStages.length;

        // Spacing parameters
        final double colMargin = visibleCount >= 3 ? 12.0 : 20.0;
        final double horizontalPadding = 12.0;
        final double remWidth = availableWidth - ((visibleCount - 1) * colMargin) - (2 * horizontalPadding);

        // Dynamically scale card dimensions based on the number of columns to keep proportions beautiful
        final double cardHeightScale = visibleCount >= 6
            ? 0.48
            : (visibleCount == 5
                ? 0.58
                : (visibleCount == 4
                    ? 0.70
                    : (visibleCount == 3 ? 0.85 : 1.0)));
        final double cardHeight = style.matchCardHeight * cardHeightScale;
        final double cardSpacing = style.matchCardSpacing * cardHeightScale;

        double groupColWidth;
        double colWidth;

        if (visibleCount == 1) {
          if (visibleStages.first == TournamentStage.groupStage) {
            groupColWidth = availableWidth - (2 * horizontalPadding);
            colWidth = style.matchCardWidth * cardHeightScale;
          } else {
            groupColWidth = 0.0;
            colWidth = availableWidth - (2 * horizontalPadding);
          }
        } else {
          // N > 1
          if (visibleStages.contains(TournamentStage.groupStage)) {
            final double groupRatio = visibleCount == 2 ? 0.45 : 0.30;
            final double matchRatio = 1.0 - groupRatio;
            final calcGroupWidth = remWidth * groupRatio;
            final calcColWidth = (remWidth * matchRatio) / (visibleCount - 1);

            // Clamp appropriately
            if (visibleCount == 2) {
              groupColWidth = calcGroupWidth.clamp(160.0, 220.0);
              colWidth = calcColWidth.clamp(140.0 * cardHeightScale, style.matchCardWidth * cardHeightScale);
            } else {
              groupColWidth = calcGroupWidth.clamp(70.0, 120.0);
              colWidth = calcColWidth.clamp(110.0 * cardHeightScale, style.matchCardWidth * cardHeightScale);
            }
          } else {
            final calcColWidth = remWidth / visibleCount;
            groupColWidth = 0.0;
            colWidth = calcColWidth.clamp(110.0 * cardHeightScale, style.matchCardWidth * cardHeightScale);
          }
        }

        int maxMatches = 16;
        if (knockoutStages.isNotEmpty) {
          final firstKnockout = knockoutStages.first;
          final matchCount = widget.data.bracketMatches.where((m) => m.stage == firstKnockout).length;
          if (matchCount > 0) {
            maxMatches = matchCount;
          }
        } else {
          maxMatches = 4; // Default compact height when only groups are shown
        }

        final double contentHeight =
            (cardHeight + cardSpacing) * maxMatches + 100.0;

        return SingleChildScrollView(
          child: SizedBox(
            height: contentHeight,
            child: SingleChildScrollView(
              controller: _bracketScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 40.0, bottom: 40.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BracketLinesPainter(
                        stages: visibleStages,
                        matches: widget.data.bracketMatches,
                        highlightedTeamId: _highlightedTeamId,
                        style: style,
                        theme: theme,
                        colWidth: colWidth,
                        groupColWidth: groupColWidth,
                        colMargin: colMargin,
                        cardHeight: cardHeight,
                        cardSpacing: cardSpacing,
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: stages.map((stage) {
                      final isSelected = _selectedStages.contains(stage);
                      final double targetWidth = stage == TournamentStage.groupStage ? groupColWidth : colWidth;
                      final double width = isSelected ? targetWidth : 0.0;
                      final double marginRight = isSelected ? colMargin : 0.0;

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
                          child: OverflowBox(
                            minWidth: targetWidth,
                            maxWidth: targetWidth,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: targetWidth,
                              child: _buildGroupStandingsColumn(
                                theme,
                                style,
                                isCondensed: visibleCount >= 3,
                                isMedium: visibleCount == 2,
                              ),
                            ),
                          ),
                        );
                      }

                      final colIndex = knockoutStages.indexOf(stage);
                      final displayColIndex = colIndex != -1 ? colIndex : 0;
                      final matchesInStage = widget.data.bracketMatches
                          .where((m) => m.stage == stage)
                          .toList()
                        ..sort((a, b) => a.roundIndex.compareTo(b.roundIndex));

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOutCubic,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        width: width,
                        margin: EdgeInsets.only(right: marginRight),
                        child: OverflowBox(
                          minWidth: targetWidth,
                          maxWidth: targetWidth,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: targetWidth,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ...matchesInStage.map((match) {
                                  final double slotHeight =
                                      (cardHeight + cardSpacing) *
                                          math.pow(2, displayColIndex);
                                  final double y = (match.roundIndex * slotHeight) +
                                      (slotHeight / 2) -
                                      (cardHeight / 2);

                                  return Positioned(
                                    top: y,
                                    left: 0,
                                    right: 0,
                                    height: cardHeight,
                                    child: _buildBracketMatchCard(theme, style, match, cardHeightScale: cardHeightScale),
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
    );
  }

  Widget _buildBracketMatchCard(
    ThemeData theme,
    TournamentStandingsStyle style,
    BracketMatch match, {
    double cardHeightScale = 1.0,
  }) {
    final isAHighlighted = match.teamA != null && _highlightedTeamId == match.teamA!.id;
    final isBHighlighted = match.teamB != null && _highlightedTeamId == match.teamB!.id;

    final cardBg = style.matchCardBackgroundColor ?? theme.cardColor;
    final borderColor = style.matchCardBorderColor ?? theme.dividerColor.withValues(alpha: 0.08);

    return GestureDetector(
      onTap: () {
        if (style.enableHaptics) {
          HapticFeedback.selectionClick();
        }
        widget.onMatchTap?.call(match);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12 * cardHeightScale),
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6 * cardHeightScale,
              offset: Offset(0, 3 * cardHeightScale),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildBracketTeamRow(
                theme,
                style,
                match.teamA,
                match.scoreA,
                match.penaltyScoreA,
                isAHighlighted,
                match.winner == match.teamA && match.isCompleted,
                true,
                cardHeightScale,
              ),
            ),
            Container(
              height: 1,
              color: borderColor,
            ),
            Expanded(
              child: _buildBracketTeamRow(
                theme,
                style,
                match.teamB,
                match.scoreB,
                match.penaltyScoreB,
                isBHighlighted,
                match.winner == match.teamB && match.isCompleted,
                false,
                cardHeightScale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBracketTeamRow(
    ThemeData theme,
    TournamentStandingsStyle style,
    TournamentTeam? team,
    int? score,
    int? penalties,
    bool isHighlighted,
    bool isWinner,
    bool isTop,
    double cardHeightScale,
  ) {
    final textStyle = style.matchCardTextStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final scoreStyle = style.scoreTextStyle ?? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle();

    // Scale font sizes gracefully (don't shrink below 9px for legibility)
    final double baseFontSize = textStyle.fontSize ?? 12.0;
    final double baseScoreSize = scoreStyle.fontSize ?? 12.0;
    final double scaledFontSize = math.max(9.0, baseFontSize * cardHeightScale);
    final double scaledScoreSize = math.max(9.0, baseScoreSize * cardHeightScale);

    // Scale flag dimensions
    final double flagW = math.max(14.0, 18.0 * cardHeightScale);
    final double flagH = math.max(9.0, 12.0 * cardHeightScale);
    final double flagSpacing = math.max(4.0, 8.0 * cardHeightScale);

    final double paddingVal = math.max(6.0, 12.0 * cardHeightScale);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingVal),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (style.accentColor ?? theme.primaryColor).withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 12 * cardHeightScale : 0),
          topRight: Radius.circular(isTop ? 12 * cardHeightScale : 0),
          bottomLeft: Radius.circular(!isTop ? 12 * cardHeightScale : 0),
          bottomRight: Radius.circular(!isTop ? 12 * cardHeightScale : 0),
        ),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        clipBehavior: Clip.none,
        children: [
          // Left Team Color Bar (when cardHeightScale < 0.8)
          if (team != null && cardHeightScale < 0.8)
            Positioned(
              left: -paddingVal,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: team.primaryColor ?? Color(team.code.hashCode | 0xFF000000),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTop ? 12 * cardHeightScale : 0),
                    bottomLeft: Radius.circular(!isTop ? 12 * cardHeightScale : 0),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              if (team != null) ...[
                // Flag (Only when cardHeightScale >= 0.8)
                if (cardHeightScale >= 0.8) ...[
                  if (team.flagUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(
                        team.flagUrl!,
                        width: flagW,
                        height: flagH,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildFlagFallback(team.code),
                      ),
                    )
                  else
                    _buildFlagFallback(team.code),
                  SizedBox(width: flagSpacing),
                ],
                Expanded(
                  child: Text(
                    team.code,
                    style: textStyle.copyWith(
                      fontSize: scaledFontSize,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                      color: isHighlighted ? (style.accentColor ?? theme.primaryColor) : null,
                    ),
                  ),
                ),
                if (score != null) ...[
                  if (penalties != null)
                    Text(
                      '($penalties)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                        fontSize: math.max(7.0, 9.0 * cardHeightScale),
                      ),
                    ),
                  SizedBox(width: math.max(3.0, 6.0 * cardHeightScale)),
                  Text(
                    '$score',
                    style: scoreStyle.copyWith(
                      fontSize: scaledScoreSize,
                      color: isWinner ? (style.accentColor ?? theme.primaryColor) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ] else ...[
                if (cardHeightScale >= 0.8) ...[
                  _buildFlagFallback('TBD'),
                  SizedBox(width: flagSpacing),
                ],
                Expanded(
                  child: Text(
                    'TBD',
                    style: textStyle.copyWith(
                      fontSize: scaledFontSize,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw orthogonally connected tree lines between bracket match columns.
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

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = style.connectingLineColor ?? theme.dividerColor.withValues(alpha: 0.15)
      ..strokeWidth = style.connectingLineThickness
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = style.accentColor ?? theme.primaryColor
      ..strokeWidth = style.connectingLineThickness + 1.0
      ..style = PaintingStyle.stroke;

    // Loop through stages to connect col `c` to col `c + 1`
    for (int c = 0; c < stages.length - 1; c++) {
      final currentStage = stages[c];
      final nextStage = stages[c + 1];

      // If either stage is groupStage, do not paint connecting lines
      if (currentStage == TournamentStage.groupStage || nextStage == TournamentStage.groupStage) {
        continue;
      }

      final currentMatches = matches.where((m) => m.stage == currentStage).toList();
      final nextMatches = matches.where((m) => m.stage == nextStage).toList();

      for (final match in currentMatches) {
        if (match.nextMatchId == null) continue;

        // Find the destination match in the next column
        final nextMatch = nextMatches.firstWhere(
          (m) => m.id == match.nextMatchId,
          orElse: () => const BracketMatch(id: '', stage: TournamentStage.final_),
        );
        if (nextMatch.id.isEmpty) continue;

        // Calculate positioning
        // Current match column X coordinates based on single-side right margin
        final knockoutStages = stages.where((s) => s != TournamentStage.groupStage).toList();

        double currentStartX = 0.0;
        for (int i = 0; i < c; i++) {
          if (stages[i] == TournamentStage.groupStage) {
            currentStartX += groupColWidth + colMargin;
          } else {
            currentStartX += colWidth + colMargin;
          }
        }
        final double currentEndX = currentStartX + colWidth;

        // Next match column X coordinates
        final double nextStartX = currentStartX + colWidth + colMargin;

        // Calculate Y coordinates using relative stage indices based on visible knockout stages
        final int currentStageIndex = knockoutStages.indexOf(currentStage);
        final int nextStageIndex = knockoutStages.indexOf(nextMatch.stage);

        final double currentSlotHeight = (cardHeight + cardSpacing) * math.pow(2, currentStageIndex);
        final double currentY = (match.roundIndex * currentSlotHeight) +
            (currentSlotHeight / 2);

        final double nextSlotHeight = (cardHeight + cardSpacing) * math.pow(2, nextStageIndex);
        final double nextY = (nextMatch.roundIndex * nextSlotHeight) +
            (nextSlotHeight / 2);

        // Path coordinates (midpoint is exactly halfway across the margin)
        final double midX = currentEndX + (colMargin / 2);

        final double cornerRadius = math.min(12.0, (colMargin / 2).abs());
        final double verticalDistance = (nextY - currentY).abs();
        final double actualRadius = math.min(cornerRadius, verticalDistance / 2);
        final double signY = nextY > currentY ? 1.0 : -1.0;

        final path = Path();
        path.moveTo(currentEndX, currentY);
        
        if (actualRadius > 0) {
          path.lineTo(midX - actualRadius, currentY);
          path.quadraticBezierTo(midX, currentY, midX, currentY + actualRadius * signY);
          path.lineTo(midX, nextY - actualRadius * signY);
          path.quadraticBezierTo(midX, nextY, midX + actualRadius, nextY);
        } else {
          path.lineTo(midX, currentY);
          path.lineTo(midX, nextY);
        }
        
        path.lineTo(nextStartX, nextY);

        // Determine if this path should be highlighted
        bool shouldHighlight = false;
        if (highlightedTeamId != null && match.winner != null && match.winner!.id == highlightedTeamId) {
          if (nextMatch.teamA?.id == highlightedTeamId || nextMatch.teamB?.id == highlightedTeamId) {
            shouldHighlight = true;
          }
        }

        canvas.drawPath(path, shouldHighlight ? highlightPaint : linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BracketLinesPainter oldDelegate) {
    return oldDelegate.highlightedTeamId != highlightedTeamId ||
        oldDelegate.stages != stages ||
        oldDelegate.matches != matches;
  }
}

/// A premium stage range selector with a modern segmented track design.
///
/// Highlights the active range with an animated pill overlay and provides
/// small arrow handles on the left and right to adjust the selection.
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

  @override
  State<TournamentStageRangeSelector> createState() => _TournamentStageRangeSelectorState();
}

class _TournamentStageRangeSelectorState extends State<TournamentStageRangeSelector> {
  final GlobalKey _trackKey = GlobalKey();

  int? _anchorIndex;

  int _getIndexFromGlobal(Offset globalPos, int itemCount) {
    final RenderBox? box = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return 0;
    
    final localOffset = box.globalToLocal(globalPos);
    final double dx = localOffset.dx.clamp(0.0, box.size.width - 0.1);
    final double itemWidth = box.size.width / itemCount;
    return (dx / itemWidth).floor().clamp(0, itemCount - 1);
  }

  void _handleTouchStart(Offset globalPos) {
    final int touchIndex = _getIndexFromGlobal(globalPos, widget.stages.length);
    final int currentStartIdx = widget.stages.indexOf(widget.startStage);
    final int currentEndIdx = widget.stages.indexOf(widget.endStage);

    if (touchIndex == currentStartIdx) {
      _anchorIndex = currentEndIdx;
    } else if (touchIndex == currentEndIdx) {
      _anchorIndex = currentStartIdx;
    } else {
      _anchorIndex = touchIndex;
      widget.onChanged(widget.stages[touchIndex], widget.stages[touchIndex]);
    }
    
    if (widget.enableHaptics) HapticFeedback.selectionClick();
  }

  void _handleTouchUpdate(Offset globalPos) {
    if (_anchorIndex == null) return;
    
    final int currentIndex = _getIndexFromGlobal(globalPos, widget.stages.length);
    final int currentMin = math.min(_anchorIndex!, currentIndex);
    final int currentMax = math.max(_anchorIndex!, currentIndex);

    final int previousMin = widget.stages.indexOf(widget.startStage);
    final int previousMax = widget.stages.indexOf(widget.endStage);

    if (currentMin != previousMin || currentMax != previousMax) {
      if (widget.enableHaptics) HapticFeedback.selectionClick();
      widget.onChanged(widget.stages[currentMin], widget.stages[currentMax]);
    }
  }

  void _handleTouchEnd() {
    _anchorIndex = null;
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
        final double innerWidth = outerWidth - 4.0; // 2px padding on each side
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
                  );
                }),
              ),
            ),
            // Track Container
            Container(
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
                    // Items (Icons only)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(widget.stages.length, (i) {
                        final isSelected = i >= startIdx && i <= endIdx;
                        return SizedBox(
                          width: itemWidth,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 18,
                              child: CustomPaint(
                                painter: _StepLinesPainter(
                                  stepIndex: i,
                                  color: isSelected ? segmentActiveColor : segmentInactiveColor,
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
          ],
        );
      },
    );
  }
}

/// Custom painter to draw the parallel line segments representing stages.
class _StepLinesPainter extends CustomPainter {
  const _StepLinesPainter({
    required this.stepIndex,
    required this.color,
  });

  final int stepIndex;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;
    
    const double lineWidth = 12.0;
    final double startX = (w - lineWidth) / 2;
    final double endX = startX + lineWidth;

    if (stepIndex == 0) {
      // Draw two lines close together, a space, and two lines close together to simulate group standings
      paint.strokeWidth = 2.0;
      canvas.drawLine(Offset(startX, h * 0.15), Offset(endX, h * 0.15), paint);
      canvas.drawLine(Offset(startX, h * 0.35), Offset(endX, h * 0.35), paint);
      
      canvas.drawLine(Offset(startX, h * 0.65), Offset(endX, h * 0.65), paint);
      canvas.drawLine(Offset(startX, h * 0.85), Offset(endX, h * 0.85), paint);
      return;
    }

    if (stepIndex == 5) {
      // Draw a clean trophy icon outline for the final stage instead of lines
      final path = Path()
        ..moveTo(w / 2 - 4, h / 2 - 4)
        ..lineTo(w / 2 + 4, h / 2 - 4)
        ..lineTo(w / 2 + 2, h / 2 + 1)
        ..quadraticBezierTo(w / 2, h / 2 + 3, w / 2 - 2, h / 2 + 1)
        ..close()
        ..moveTo(w / 2 - 1, h / 2 + 3)
        ..lineTo(w / 2 - 1, h / 2 + 5)
        ..moveTo(w / 2 + 1, h / 2 + 3)
        ..lineTo(w / 2 + 1, h / 2 + 5)
        ..moveTo(w / 2 - 2.5, h / 2 + 5)
        ..lineTo(w / 2 + 2.5, h / 2 + 5);
      canvas.drawPath(path, paint);
      return;
    }

    // Number of lines: R32=5 (thin), R16=4, QF=2, SF=2
    int numLines = 4;
    double strokeW = 1.5;
    if (stepIndex == 1) {
      numLines = 5;
      strokeW = 0.8;
    } else if (stepIndex == 2) {
      numLines = 4;
      strokeW = 1.0;
    } else if (stepIndex == 3) {
      numLines = 2;
      strokeW = 1.2;
    } else if (stepIndex == 4) {
      numLines = 2;
      strokeW = 1.5;
    }

    paint.strokeWidth = strokeW;

    final double stepY = h / (numLines + 1);
    for (int i = 0; i < numLines; i++) {
      final double y = stepY * (i + 1);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StepLinesPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.stepIndex != stepIndex;
  }
}

