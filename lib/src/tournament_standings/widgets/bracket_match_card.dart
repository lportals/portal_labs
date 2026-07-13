import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tournament_standings_models.dart';
import '../models/tournament_standings_style.dart';
import 'group_stage_column.dart' show buildFlagFallback;

/// A card widget that displays information for a single match in the bracket.
///
/// Features highlighted teams, scores, flag assets, and an optional date header.
class BracketMatchCard extends StatelessWidget {
  /// Creates a [BracketMatchCard].
  const BracketMatchCard({
    super.key,
    required this.match,
    required this.style,
    required this.highlightedTeamNotifier,
    this.cardHeightScale = 1.0,
    this.showFlags = true,
    this.isReached = true,
    this.showDateHeader = false,
    this.onMatchTap,
  });

  /// The bracket match info to render.
  final BracketMatch match;

  /// Custom styling guidelines for the bracket match card.
  final TournamentStandingsStyle style;

  /// Notifier that triggers a visual highlight when a team code/name matches this value.
  final ValueNotifier<String?> highlightedTeamNotifier;

  /// A scaling factor to adjust size dynamically depending on column width.
  final double cardHeightScale;

  /// Whether to render flag network images.
  final bool showFlags;

  /// Whether the connection path animation has reached this card.
  final bool isReached;

  /// Whether to display a header container with the formatted date of the match.
  final bool showDateHeader;

  /// Optional callback invoked when the card is tapped.
  final ValueChanged<BracketMatch>? onMatchTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardBg = style.matchCardBackgroundColor ?? Theme.of(context).cardColor;
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        // If the card is extremely squished during resize/shrink animations,
        // render an empty background to avoid layout overflows and console noise.
        if (width < 40.0 || height < 20.0) {
          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12 * cardHeightScale),
            ),
          );
        }

        // Dynamically hide flags and date header if the card is too narrow to avoid overflows
        final bool effectiveShowFlags = showFlags && width >= 90.0;
        final bool effectiveShowDateHeader = showDateHeader && width >= 110.0;
        final bool showScores = width >= 55.0;

        return ValueListenableBuilder<String?>(
          valueListenable: highlightedTeamNotifier,
          builder: (context, highlightedTeamId, child) {
            final theme = Theme.of(context);
            final double paddingVal = math.max(6.0, 12.0 * cardHeightScale);
            
            final isAHighlighted = match.teamA != null && highlightedTeamId == match.teamA!.id;
            final isBHighlighted = match.teamB != null && highlightedTeamId == match.teamB!.id;

            final borderColor = style.matchCardBorderColor ?? theme.dividerColor.withValues(alpha: 0.08);

            final isHighlightedMatch = isAHighlighted || isBHighlighted;
            final isSelectedAndReached = isHighlightedMatch && isReached;

            return GestureDetector(
              onTap: () {
                if (style.enableHaptics) {
                  HapticFeedback.selectionClick();
                }
                onMatchTap?.call(match);
              },
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12 * cardHeightScale),
                  border: Border.all(
                    color: isSelectedAndReached 
                        ? (style.accentColor ?? theme.colorScheme.onSurface)
                        : borderColor,
                    width: isSelectedAndReached ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelectedAndReached
                          ? (style.accentColor ?? theme.colorScheme.onSurface).withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.04),
                      blurRadius: isSelectedAndReached ? 12 * cardHeightScale : 6 * cardHeightScale,
                      offset: Offset(0, isSelectedAndReached ? 5 * cardHeightScale : 3 * cardHeightScale),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (effectiveShowDateHeader && match.matchDate != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: paddingVal,
                          vertical: 5.0 * cardHeightScale,
                        ),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12 * cardHeightScale),
                          ),
                        ),
                        child: Text(
                          _formatMatchDate(match.matchDate!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: math.max(8.0, 9.5 * cardHeightScale),
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: borderColor,
                      ),
                    ],
                    Expanded(
                      child: _buildBracketTeamRow(
                        theme: theme,
                        style: style,
                        team: match.teamA,
                        score: match.scoreA,
                        penalties: match.penaltyScoreA,
                        isHighlighted: isAHighlighted && isReached,
                        isWinner: match.winner == match.teamA && match.isCompleted,
                        isTop: !effectiveShowDateHeader,
                        cardHeightScale: cardHeightScale,
                        showFlags: effectiveShowFlags,
                        showScores: showScores,
                      ),
                    ),
                    Container(
                      height: 1,
                      color: borderColor,
                    ),
                    Expanded(
                      child: _buildBracketTeamRow(
                        theme: theme,
                        style: style,
                        team: match.teamB,
                        score: match.scoreB,
                        penalties: match.penaltyScoreB,
                        isHighlighted: isBHighlighted && isReached,
                        isWinner: match.winner == match.teamB && match.isCompleted,
                        isTop: false,
                        cardHeightScale: cardHeightScale,
                        showFlags: effectiveShowFlags,
                        showScores: showScores,
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBracketTeamRow({
    required ThemeData theme,
    required TournamentStandingsStyle style,
    required TournamentTeam? team,
    required int? score,
    required int? penalties,
    required bool isHighlighted,
    required bool isWinner,
    required bool isTop,
    required double cardHeightScale,
    required bool showFlags,
    required bool showScores,
  }) {
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
            ? (style.accentColor ?? theme.colorScheme.onSurface).withValues(alpha: 0.08)
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
          // Left Team Color Bar (when flags are not shown)
          if (team != null && !showFlags)
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
                // Flag (Only when showFlags is true)
                if (showFlags) ...[
                  if (team.logoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Image.network(
                        team.logoUrl!,
                        width: flagW,
                        height: flagH,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (_, _, _) => buildFlagFallback(team.code),
                      ),
                    )
                  else
                    buildFlagFallback(team.code),
                  SizedBox(width: flagSpacing),
                ],
                Expanded(
                  child: Text(
                    team.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle.copyWith(
                      fontSize: scaledFontSize,
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                      color: isHighlighted ? (style.accentColor ?? theme.colorScheme.onSurface) : null,
                    ),
                  ),
                ),
                if (score != null && showScores) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: scoreStyle.copyWith(
                          fontSize: scaledScoreSize,
                          color: isWinner ? (style.accentColor ?? theme.colorScheme.onSurface) : Colors.grey.shade500,
                        ),
                      ),
                      if (penalties != null) ...[
                        const SizedBox(width: 1),
                        Text(
                          '($penalties)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                            fontSize: math.max(7.0, 9.0 * cardHeightScale),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ] else ...[
                if (showFlags) ...[
                  buildFlagFallback('TBD'),
                  SizedBox(width: flagSpacing),
                ],
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'TBD',
                      maxLines: 1,
                      softWrap: false,
                      style: textStyle.copyWith(
                        fontSize: scaledFontSize,
                        color: Colors.grey.shade500,
                      ),
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

  String _formatMatchDate(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    
    final hourNum = date.hour;
    final minuteNum = date.minute;
    final period = hourNum >= 12 ? 'PM' : 'AM';
    final displayHour = hourNum % 12 == 0 ? 12 : hourNum % 12;
    final displayMinute = minuteNum.toString().padLeft(2, '0');
    
    return '$weekday, $month $day · $displayHour:$displayMinute $period';
  }
}
