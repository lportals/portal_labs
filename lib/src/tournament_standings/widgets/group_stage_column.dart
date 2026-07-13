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

/// Builds a fallback widget containing the first two letters of the country code when the flag image is missing.
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

/// A widget that displays the standings list for all groups in a scrollable column.
///
/// Automatically adjusts its layout, statistics columns, and padding depending on [detailLevel].
class GroupStandingsColumn extends StatelessWidget {
  /// Creates a [GroupStandingsColumn].
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

  /// Additional vertical padding applied at the top of the column to align with adjacent knockout stages.
  final double topPadding;

  /// The global tournament standings data.
  final TournamentStandingsData data;

  /// Custom styling guidelines for the standings widget.
  final TournamentStandingsStyle style;

  /// The level of detail to render based on the current column width.
  final GroupDetailLevel detailLevel;

  /// The set of all selected and active tournament stages.
  final Set<TournamentStage> selectedStages;

  /// Notifier that triggers a visual highlight when a team code/name matches this value.
  final ValueNotifier<String?> highlightedTeamNotifier;

  /// Optional callback invoked when a team row is tapped.
  final ValueChanged<TournamentTeam>? onTeamTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = style.accentColor ?? theme.colorScheme.onSurface;
    final cardBg = style.matchCardBackgroundColor ?? theme.cardColor;
    final borderColor = style.matchCardBorderColor ?? theme.dividerColor.withValues(alpha: 0.10);

    final bool isCondensed = detailLevel == GroupDetailLevel.condensed;
    final bool isMedium = detailLevel == GroupDetailLevel.medium;
    final bool onlyGroupStageSelected = selectedStages.length == 1 && selectedStages.first == TournamentStage.groupStage;
    final bool hasFourOrMoreStages = selectedStages.length >= 4;
    final bool hidePtsColumn = isMedium && hasFourOrMoreStages;

    // Column header labels for the stats table
    final statHeaders = isCondensed
        ? <String>[]
        : (isMedium 
            ? (hidePtsColumn ? <String>[] : ['PTS']) 
            : ['GP', 'W', 'D', 'L', 'GD', 'PTS']);

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
            margin: EdgeInsets.only(bottom: isCondensed ? 12 : (isMedium ? 12 : 16)),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(isCondensed ? 10 : (isMedium ? 10 : 14)),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: isCondensed ? 8 : (isMedium ? 8 : 12),
                    vertical: isCondensed ? 5 : 9,
                  ),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(isCondensed ? 10 : (isMedium ? 10 : 14)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            isCondensed ? 'Group ${group.id}' : group.name.toUpperCase(),
                            style: isCondensed
                                ? TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                                  )
                                : theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                                  ),
                          ),
                        ),
                      ),
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
                  final idx = entry.key;
                  final rank = idx + 1;
                  final team = entry.value;
                  final isLastRow = rank == group.standings.length;
                  final paddingVal = isCondensed ? 8.0 : (isMedium ? 8.0 : 12.0);

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

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.only(
                            top: isCondensed ? 5.0 : (isMedium ? 8.0 : 10.0),
                            bottom: isCondensed ? 5.0 : (isMedium ? 8.0 : 10.0),
                            left: paddingVal,
                            right: isCondensed ? 6.0 : paddingVal,
                          ),
                          decoration: BoxDecoration(
                            color: isHighlighted
                                ? accent.withValues(alpha: isCondensed ? 0.10 : 0.08)
                                : Colors.transparent,
                            borderRadius: isLastRow
                                ? BorderRadius.vertical(
                                    bottom: Radius.circular(isCondensed ? 10 : (isMedium ? 10 : 14)),
                                  )
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            clipBehavior: Clip.none,
                            children: [
                              // Team color indicator on the left edge
                              Positioned(
                                left: -paddingVal,
                                top: isCondensed ? -5.0 : (isMedium ? -8.0 : -10.0),
                                bottom: isCondensed ? -5.0 : (isMedium ? -8.0 : -10.0),
                                width: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: team.primaryColor ?? Color(team.code.hashCode | 0xFF000000),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(isLastRow ? (isCondensed ? 10 : (isMedium ? 10 : 14)) : 0),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  const SizedBox(width: 4),
                                  if (!isCondensed) ...[
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
                                    // Flag
                                    if (!isMedium) ...[
                                      if (team.flagUrl != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: Image.network(
                                            team.flagUrl!,
                                            width: 20,
                                            height: 13,
                                            fit: BoxFit.cover,
                                            gaplessPlayback: true,
                                            errorBuilder: (_, _, _) => buildFlagFallback(team.code),
                                          ),
                                        )
                                      else
                                        buildFlagFallback(team.code),
                                      const SizedBox(width: 8),
                                    ],
                                  ],
                                  // Team name/code
                                  Expanded(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        (isCondensed || isMedium) ? team.code : team.name,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: isCondensed ? 10 : 12,
                                          fontWeight: isHighlighted
                                              ? (isCondensed ? FontWeight.w800 : FontWeight.w700)
                                              : (isCondensed ? FontWeight.w600 : FontWeight.w500),
                                          color: isHighlighted ? accent : theme.textTheme.bodyMedium?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Stats
                                  if (!isCondensed) ...[
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
