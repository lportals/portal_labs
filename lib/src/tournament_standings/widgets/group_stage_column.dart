import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tournament_standings_models.dart';
import '../models/tournament_standings_style.dart';

/// Detail level for the group standings column, determined dynamically
/// by the actual allocated width rather than the visible stage count.
enum GroupDetailLevel {
  /// Full detail: flags, all stats (GP, W, D, L, GD, PTS), qualification indicators.
  full,

  /// Medium detail: team code + PTS column, left team brand color bar.
  medium,

  /// Condensed: team code only, left team brand color bar.
  condensed,
}

Widget buildFlagFallback(String code) {
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

class GroupStandingsColumn extends StatelessWidget {
  const GroupStandingsColumn({
    super.key,
    required this.data,
    required this.style,
    required this.detailLevel,
    required this.selectedStages,
    required this.highlightedTeamNotifier,
    this.topPadding = 4.0,
    this.onTeamTap,
  });

  final double topPadding;

  final TournamentStandingsData data;
  final TournamentStandingsStyle style;
  final GroupDetailLevel detailLevel;
  final Set<TournamentStage> selectedStages;
  final ValueNotifier<String?> highlightedTeamNotifier;
  final ValueChanged<TournamentTeam>? onTeamTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = style.accentColor ?? theme.colorScheme.onSurface;
    final cardBg = style.matchCardBackgroundColor ?? theme.cardColor;
    final borderColor = style.matchCardBorderColor ?? theme.dividerColor.withValues(alpha: 0.10);

    if (detailLevel == GroupDetailLevel.condensed) {
      return Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: 48, left: 4, right: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: data.groups.map((group) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Minimal header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.04),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
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
                    height: 1.0,
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                  ...group.standings.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final team = entry.value;
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
                            if (highlightedTeamNotifier.value == team.id) {
                              highlightedTeamNotifier.value = null;
                            } else {
                              highlightedTeamNotifier.value = team.id;
                            }
                            onTeamTap?.call(team);
                          },
                          child: ValueListenableBuilder<String?>(
                            valueListenable: highlightedTeamNotifier,
                            builder: (context, highlightedTeamId, child) {
                              final isHighlighted = highlightedTeamId == team.id;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 8.0, right: 6.0),
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
                                      left: -8.0,
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
                                        const SizedBox(width: 2),
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
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    // Derive convenience boolean from the detail level for the non-condensed path
    final bool isMedium = detailLevel == GroupDetailLevel.medium;
    final bool onlyGroupStageSelected = selectedStages.length == 1 && selectedStages.first == TournamentStage.groupStage;
    final bool hasFourOrMoreStages = selectedStages.length >= 4;
    final bool hidePtsColumn = isMedium && hasFourOrMoreStages;

    // Column header labels for the stats table
    final statHeaders = isMedium 
        ? (hidePtsColumn ? <String>[] : ['PTS']) 
        : ['GP', 'W', 'D', 'L', 'GD', 'PTS'];

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

    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 48, left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: data.groups.map((group) {
          return Container(
            margin: EdgeInsets.only(bottom: isMedium ? 12 : 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(isMedium ? 10 : 14),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
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
                    color: theme.dividerColor.withValues(alpha: 0.04),
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
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
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
                Container(
                  height: 1.0,
                  color: theme.dividerColor.withValues(alpha: 0.15),
                ),
                // ── Group Rows ────────────────────────────────
                ...group.standings.asMap().entries.expand((entry) {
                  final rank = entry.key + 1;
                  final team = entry.value;
                  final paddingVal = isMedium ? 8.0 : 12.0;

                  // Goal difference text
                  final gd = team.goalsFor - team.goalsAgainst;
                  final gdStr = gd > 0 ? '+$gd' : '$gd';

                  final rowWidget = GestureDetector(
                    onTap: () {
                      if (highlightedTeamNotifier.value == team.id) {
                        highlightedTeamNotifier.value = null;
                      } else {
                        highlightedTeamNotifier.value = team.id;
                      }
                      onTeamTap?.call(team);
                    },
                    child: ValueListenableBuilder<String?>(
                      valueListenable: highlightedTeamNotifier,
                      builder: (context, highlightedTeamId, child) {
                        final isHighlighted = highlightedTeamId == team.id;
                        final isLastRow = rank == group.standings.length;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: isMedium ? 8.0 : 10.0, horizontal: paddingVal),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? accent.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: isLastRow
                                ? BorderRadius.vertical(bottom: Radius.circular(isMedium ? 10 : 14))
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            clipBehavior: Clip.none,
                            children: [
                              // Team color indicator on the left edge
                              Positioned(
                                left: -paddingVal,
                                top: isMedium ? -8.0 : -10.0,
                                bottom: isMedium ? -8.0 : -10.0,
                                width: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: team.primaryColor ?? Color(team.code.hashCode | 0xFF000000),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(isLastRow ? (isMedium ? 10 : 14) : 0),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  // Margin to offset content due to color bar
                                  const SizedBox(width: 4),
                                  // Rank
                                  SizedBox(
                                    width: 14,
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: isMedium ? 4 : 6),
                                  // Flag (Only when not in medium mode)
                                  if (team.flagUrl != null && !isMedium) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: Image.network(
                                        team.flagUrl!,
                                        width: 20,
                                        height: 13,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => buildFlagFallback(team.code),
                                      ),
                                    )
                                  ] else if (!isMedium) ...[
                                    buildFlagFallback(team.code),
                                  ],
                                  if (!isMedium) const SizedBox(width: 8),
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
                                  if (!hidePtsColumn)
                                    statCell('${team.points}', bold: true, highlighted: isHighlighted),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );

                  // If rank is 2, insert a qualification cut-off line below it
                  if (rank == 2) {
                    return [
                      rowWidget,
                      Container(
                        height: 1.0,
                        margin: EdgeInsets.symmetric(horizontal: paddingVal),
                        color: onlyGroupStageSelected 
                            ? theme.dividerColor.withValues(alpha: 0.15) 
                            : Colors.green.shade400.withValues(alpha: 0.45),
                      ),
                    ];
                  }

                  return [rowWidget];
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
