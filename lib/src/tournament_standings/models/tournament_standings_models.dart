import 'package:flutter/foundation.dart';

/// The stages of a tournament.
enum TournamentStage {
  /// The initial group phase.
  groupStage,

  /// Round of 32 knockout stage.
  roundOf32,

  /// Round of 16 knockout stage.
  roundOf16,

  /// Quarter-finals knockout stage.
  quarterFinal,

  /// Semi-finals knockout stage.
  semiFinal,

  /// The final match of the tournament.
  final_,
}

/// Extension on [TournamentStage] to provide user-friendly display names.
extension TournamentStageExtension on TournamentStage {
  /// Returns a clean, capitalized label for the stage.
  String get label {
    switch (this) {
      case TournamentStage.groupStage:
        return 'Group Stage';
      case TournamentStage.roundOf32:
        return 'Round of 32';
      case TournamentStage.roundOf16:
        return 'Round of 16';
      case TournamentStage.quarterFinal:
        return 'Quarter-Finals';
      case TournamentStage.semiFinal:
        return 'Semi-Finals';
      case TournamentStage.final_:
        return 'Final';
    }
  }

  /// Returns a shorter abbreviation for tab headers if space is tight.
  String get shortLabel {
    switch (this) {
      case TournamentStage.groupStage:
        return 'GS';
      case TournamentStage.roundOf32:
        return 'R32';
      case TournamentStage.roundOf16:
        return 'R16';
      case TournamentStage.quarterFinal:
        return 'QF';
      case TournamentStage.semiFinal:
        return 'SF';
      case TournamentStage.final_:
        return 'F';
    }
  }
}

/// Represents a team competing in the tournament.
@immutable
class TournamentTeam {
  /// Creates a [TournamentTeam] entry.
  const TournamentTeam({
    required this.id,
    required this.name,
    required this.code,
    this.flagUrl,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
  });

  /// Unique identifier for the team.
  final String id;

  /// Full display name of the team (e.g. "Argentina").
  final String name;

  /// Abbreviated code (e.g. "ARG").
  final String code;

  /// Path or URL to the team's flag image.
  final String? flagUrl;

  /// Number of matches played.
  final int played;

  /// Number of matches won.
  final int wins;

  /// Number of matches drawn.
  final int draws;

  /// Number of matches lost.
  final int losses;

  /// Goals scored by the team.
  final int goalsFor;

  /// Goals conceded by the team.
  final int goalsAgainst;

  /// Total points accumulated.
  final int points;

  /// Calculates goal difference (Goals For - Goals Against).
  int get goalDifference => goalsFor - goalsAgainst;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TournamentTeam &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a group containing teams in the group stage.
@immutable
class TournamentGroup {
  /// Creates a [TournamentGroup] containing standings.
  const TournamentGroup({
    required this.id,
    required this.name,
    required this.standings,
  });

  /// Unique identifier of the group.
  final String id;

  /// Name of the group (e.g. "Group A").
  final String name;

  /// List of team standings in the group, sorted by rank.
  final List<TournamentTeam> standings;
}

/// Represents a single match in a knockout bracket stage.
@immutable
class BracketMatch {
  /// Creates a [BracketMatch] entry.
  const BracketMatch({
    required this.id,
    required this.stage,
    this.teamA,
    this.teamB,
    this.scoreA,
    this.scoreB,
    this.penaltyScoreA,
    this.penaltyScoreB,
    this.isCompleted = false,
    this.matchDate,
    this.venue,
    this.nextMatchId,
    this.roundIndex = 0,
  });

  /// Unique identifier for the match.
  final String id;

  /// The tournament stage this match belongs to.
  final TournamentStage stage;

  /// First team competing in the match (null if not yet decided).
  final TournamentTeam? teamA;

  /// Second team competing in the match (null if not yet decided).
  final TournamentTeam? teamB;

  /// Score of team A (null if match hasn't started/completed).
  final int? scoreA;

  /// Score of team B (null if match hasn't started/completed).
  final int? scoreB;

  /// Penalty shootout score of team A (null if no penalties occurred).
  final int? penaltyScoreA;

  /// Penalty shootout score of team B (null if no penalties occurred).
  final int? penaltyScoreB;

  /// Whether the match has completed.
  final bool isCompleted;

  /// Optional date and time of the match.
  final DateTime? matchDate;

  /// Optional stadium or city venue.
  final String? venue;

  /// The ID of the subsequent match that the winner advances to.
  final String? nextMatchId;

  /// The vertical or grid position of the match in this round (0-indexed).
  /// Essential for mapping connecting lines correctly in the tree layout.
  final int roundIndex;

  /// Returns the winning team of this match if completed.
  TournamentTeam? get winner {
    if (!isCompleted || teamA == null || teamB == null || scoreA == null || scoreB == null) {
      return null;
    }
    if (scoreA! > scoreB!) return teamA;
    if (scoreB! > scoreA!) return teamB;
    if (penaltyScoreA != null && penaltyScoreB != null) {
      if (penaltyScoreA! > penaltyScoreB!) return teamA;
      if (penaltyScoreB! > penaltyScoreA!) return teamB;
    }
    return null;
  }
}

/// The root container holding all standings and bracket match data for the widget.
@immutable
class TournamentStandingsData {
  /// Creates a [TournamentStandingsData] package.
  const TournamentStandingsData({
    required this.groups,
    required this.bracketMatches,
  });

  /// The group standings data.
  final List<TournamentGroup> groups;

  /// All knockout stage matches.
  final List<BracketMatch> bracketMatches;
}
