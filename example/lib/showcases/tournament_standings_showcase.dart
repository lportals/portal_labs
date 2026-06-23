import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

/// Showcase for the [TournamentStandings] component, pre-populated with
/// realistic FIFA World Cup 2026 data.
class TournamentStandingsShowcase extends StatelessWidget {
  /// Creates a [TournamentStandingsShowcase].
  const TournamentStandingsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = _getMockWorldCupData();

    return ShowcaseShell(
      title: 'Tournament Standings',
      description: 'Split-panel tournament bracket and standings viewer inspired by '
          'the FIFA World Cup 2026 app UI. Features spring-driven stage selections, '
          'condensed left-side group cards, custom bracket line drawing, and path highlighting.',
      codeSnippet: '''TournamentStandings(
  data: tournamentData,
  style: TournamentStandingsStyle(
    accentColor: Colors.blueAccent,
    enableHaptics: true,
  ),
  onTeamTap: (team) => print('Tapped \${team.name}'),
  onMatchTap: (match) => print('Tapped Match \${match.id}'),
)''',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              elevation: 4,
              child: SizedBox(
                height: 700,
                child: TournamentStandings(
                  data: mockData,
                  style: const TournamentStandingsStyle(
                    accentColor: Color(0xFF007AFF),
                    matchCardBackgroundColor: Colors.white,
                  ),
                  onTeamTap: (team) {
                    debugPrint('Tapped team: ${team.name}');
                  },
                  onMatchTap: (match) {
                    debugPrint('Tapped match: ${match.id}');
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TournamentStandingsData _getMockWorldCupData() {
    // 1. Teams definition
    const mex = TournamentTeam(id: 'mex', name: 'Mexico', code: 'MEX', primaryColor: Color(0xFF006341), played: 2, wins: 2, points: 6, goalsFor: 3, goalsAgainst: 0);
    const kor = TournamentTeam(id: 'kor', name: 'Korea Republic', code: 'KOR', primaryColor: Color(0xFFC60C30), played: 2, wins: 1, losses: 1, points: 3, goalsFor: 1, goalsAgainst: 1);
    const cze = TournamentTeam(id: 'cze', name: 'Czechia', code: 'CZE', primaryColor: Color(0xFF11457E), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 1, goalsAgainst: 2);
    const rsa = TournamentTeam(id: 'rsa', name: 'South Africa', code: 'RSA', primaryColor: Color(0xFF007A4B), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 1, goalsAgainst: 3);

    const can = TournamentTeam(id: 'can', name: 'Canada', code: 'CAN', primaryColor: Color(0xFFFF0000), played: 2, wins: 1, draws: 1, points: 4, goalsFor: 7, goalsAgainst: 1);
    const sui = TournamentTeam(id: 'sui', name: 'Switzerland', code: 'SUI', primaryColor: Color(0xFFD52B1E), played: 2, wins: 1, draws: 1, points: 4, goalsFor: 4, goalsAgainst: 1);
    const bih = TournamentTeam(id: 'bih', name: 'Bosnia-Herz.', code: 'BIH', primaryColor: Color(0xFF002F6C), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 1, goalsAgainst: 4);
    const qat = TournamentTeam(id: 'qat', name: 'Qatar', code: 'QAT', primaryColor: Color(0xFF8A1538), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 1, goalsAgainst: 7);

    const bra = TournamentTeam(id: 'bra', name: 'Brazil', code: 'BRA', primaryColor: Color(0xFFFEDF00), played: 2, wins: 1, draws: 1, points: 4, goalsFor: 4, goalsAgainst: 1);
    const mar = TournamentTeam(id: 'mar', name: 'Morocco', code: 'MAR', primaryColor: Color(0xFFC1272D), played: 2, wins: 1, draws: 1, points: 4, goalsFor: 2, goalsAgainst: 1);
    const sco = TournamentTeam(id: 'sco', name: 'Scotland', code: 'SCO', primaryColor: Color(0xFF0065BD), played: 2, wins: 1, losses: 1, points: 3, goalsFor: 1, goalsAgainst: 1);
    const hai = TournamentTeam(id: 'hai', name: 'Haiti', code: 'HAI', primaryColor: Color(0xFF00209F), played: 2, losses: 2, points: 0, goalsFor: 0, goalsAgainst: 5);

    const usa = TournamentTeam(id: 'usa', name: 'USA', code: 'USA', primaryColor: Color(0xFF0A3161), played: 2, wins: 2, points: 6, goalsFor: 5, goalsAgainst: 0);
    const aus = TournamentTeam(id: 'aus', name: 'Australia', code: 'AUS', primaryColor: Color(0xFF002B7F), played: 2, wins: 1, losses: 1, points: 3, goalsFor: 1, goalsAgainst: 1);
    const par = TournamentTeam(id: 'par', name: 'Paraguay', code: 'PAR', primaryColor: Color(0xFFD52B1E), played: 2, wins: 1, losses: 1, points: 3, goalsFor: 1, goalsAgainst: 3);
    const tur = TournamentTeam(id: 'tur', name: 'Turkey', code: 'TUR', primaryColor: Color(0xFFE30A17), played: 2, losses: 2, points: 0, goalsFor: 0, goalsAgainst: 3);

    const ger = TournamentTeam(id: 'ger', name: 'Germany', code: 'GER', primaryColor: Color(0xFF000000), played: 2, wins: 2, points: 6, goalsFor: 4, goalsAgainst: 1);
    const civ = TournamentTeam(id: 'civ', name: 'Ivory Coast', code: 'CIV', primaryColor: Color(0xFFFF8200), played: 2, wins: 1, losses: 1, points: 3, goalsFor: 2, goalsAgainst: 2);
    const ecu = TournamentTeam(id: 'ecu', name: 'Ecuador', code: 'ECU', primaryColor: Color(0xFFFFD100), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 2, goalsAgainst: 3);
    const cuw = TournamentTeam(id: 'cuw', name: 'Curacao', code: 'CUW', primaryColor: Color(0xFF002B7F), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 1, goalsAgainst: 3);

    const ned = TournamentTeam(id: 'ned', name: 'Netherlands', code: 'NED', primaryColor: Color(0xFFFF4F00), played: 2, wins: 2, points: 6, goalsFor: 5, goalsAgainst: 1);
    const jpn = TournamentTeam(id: 'jpn', name: 'Japan', code: 'JPN', primaryColor: Color(0xFF0005A0), played: 2, wins: 1, losses: 1, points: 3, goalsFor: 2, goalsAgainst: 2);
    const swe = TournamentTeam(id: 'swe', name: 'Sweden', code: 'SWE', primaryColor: Color(0xFF006AA7), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 2, goalsAgainst: 3);
    const tun = TournamentTeam(id: 'tun', name: 'Tunisia', code: 'TUN', primaryColor: Color(0xFFE30A17), played: 2, draws: 1, losses: 1, points: 1, goalsFor: 1, goalsAgainst: 4);

    // 2. Groups mapping
    final groups = [
      const TournamentGroup(id: 'A', name: 'Group A', standings: [mex, kor, cze, rsa]),
      const TournamentGroup(id: 'B', name: 'Group B', standings: [can, sui, bih, qat]),
      const TournamentGroup(id: 'C', name: 'Group C', standings: [bra, mar, sco, hai]),
      const TournamentGroup(id: 'D', name: 'Group D', standings: [usa, aus, par, tur]),
      const TournamentGroup(id: 'E', name: 'Group E', standings: [ger, civ, ecu, cuw]),
      const TournamentGroup(id: 'F', name: 'Group F', standings: [ned, jpn, swe, tun]),
    ];

    // 3. Bracket definition (R32 feeds into R16, QF, SF, F)
    final bracket = <BracketMatch>[
      // --- ROUND OF 32 ---
      // Left feeding into R16 Match 1 (r16_1)
      const BracketMatch(id: 'r32_1', stage: TournamentStage.roundOf32, teamA: ger, teamB: kor, scoreA: 3, scoreB: 1, isCompleted: true, nextMatchId: 'r16_1', roundIndex: 0),
      const BracketMatch(id: 'r32_2', stage: TournamentStage.roundOf32, teamA: sui, teamB: cze, scoreA: 1, scoreB: 2, isCompleted: true, nextMatchId: 'r16_1', roundIndex: 1),

      // Left feeding into R16 Match 2 (r16_2)
      const BracketMatch(id: 'r32_3', stage: TournamentStage.roundOf32, teamA: mar, teamB: bih, scoreA: 2, scoreB: 0, isCompleted: true, nextMatchId: 'r16_2', roundIndex: 2),
      const BracketMatch(id: 'r32_4', stage: TournamentStage.roundOf32, teamA: mex, teamB: qat, scoreA: 4, scoreB: 1, isCompleted: true, nextMatchId: 'r16_2', roundIndex: 3),

      // Left feeding into R16 Match 3 (r16_3)
      const BracketMatch(id: 'r32_5', stage: TournamentStage.roundOf32, teamA: bra, teamB: aus, scoreA: 2, scoreB: 1, isCompleted: true, nextMatchId: 'r16_3', roundIndex: 4),
      const BracketMatch(id: 'r32_6', stage: TournamentStage.roundOf32, teamA: jpn, teamB: civ, scoreA: 0, scoreB: 1, isCompleted: true, nextMatchId: 'r16_3', roundIndex: 5),

      // Left feeding into R16 Match 4 (r16_4)
      const BracketMatch(id: 'r32_7', stage: TournamentStage.roundOf32, teamA: usa, teamB: par, scoreA: 3, scoreB: 0, isCompleted: true, nextMatchId: 'r16_4', roundIndex: 6),
      const BracketMatch(id: 'r32_8', stage: TournamentStage.roundOf32, teamA: ned, teamB: ecu, scoreA: 2, scoreB: 1, isCompleted: true, nextMatchId: 'r16_4', roundIndex: 7),

      // Placeholders for remaining R32 to keep matching tree vertical dimensions complete (16 positions)
      ...List.generate(8, (i) {
        final roundIdx = 8 + i;
        final nextId = 'r16_${5 + (i ~/ 2)}';
        return BracketMatch(id: 'r32_${9 + i}', stage: TournamentStage.roundOf32, teamA: null, teamB: null, nextMatchId: nextId, roundIndex: roundIdx);
      }),

      // --- ROUND OF 16 ---
      const BracketMatch(id: 'r16_1', stage: TournamentStage.roundOf16, teamA: ger, teamB: cze, scoreA: 2, scoreB: 0, isCompleted: true, nextMatchId: 'qf_1', roundIndex: 0),
      const BracketMatch(id: 'r16_2', stage: TournamentStage.roundOf16, teamA: mar, teamB: mex, scoreA: 1, scoreB: 2, isCompleted: true, nextMatchId: 'qf_1', roundIndex: 1),
      const BracketMatch(id: 'r16_3', stage: TournamentStage.roundOf16, teamA: bra, teamB: civ, scoreA: 3, scoreB: 1, isCompleted: true, nextMatchId: 'qf_2', roundIndex: 2),
      const BracketMatch(id: 'r16_4', stage: TournamentStage.roundOf16, teamA: usa, teamB: ned, scoreA: 2, scoreB: 1, isCompleted: true, nextMatchId: 'qf_2', roundIndex: 3),
      // R16 right-side placeholders
      const BracketMatch(id: 'r16_5', stage: TournamentStage.roundOf16, teamA: null, teamB: null, nextMatchId: 'qf_3', roundIndex: 4),
      const BracketMatch(id: 'r16_6', stage: TournamentStage.roundOf16, teamA: null, teamB: null, nextMatchId: 'qf_3', roundIndex: 5),
      const BracketMatch(id: 'r16_7', stage: TournamentStage.roundOf16, teamA: null, teamB: null, nextMatchId: 'qf_4', roundIndex: 6),
      const BracketMatch(id: 'r16_8', stage: TournamentStage.roundOf16, teamA: null, teamB: null, nextMatchId: 'qf_4', roundIndex: 7),

      // --- QUARTER FINALS ---
      const BracketMatch(id: 'qf_1', stage: TournamentStage.quarterFinal, teamA: ger, teamB: mex, scoreA: 1, scoreB: 2, isCompleted: true, nextMatchId: 'sf_1', roundIndex: 0),
      const BracketMatch(id: 'qf_2', stage: TournamentStage.quarterFinal, teamA: bra, teamB: usa, scoreA: 1, scoreB: 2, isCompleted: true, nextMatchId: 'sf_1', roundIndex: 1),
      const BracketMatch(id: 'qf_3', stage: TournamentStage.quarterFinal, teamA: null, teamB: null, nextMatchId: 'sf_2', roundIndex: 2),
      const BracketMatch(id: 'qf_4', stage: TournamentStage.quarterFinal, teamA: null, teamB: null, nextMatchId: 'sf_2', roundIndex: 3),

      // --- SEMI FINALS ---
      const BracketMatch(id: 'sf_1', stage: TournamentStage.semiFinal, teamA: mex, teamB: usa, scoreA: 1, scoreB: 2, isCompleted: true, nextMatchId: 'f_1', roundIndex: 0),
      const BracketMatch(id: 'sf_2', stage: TournamentStage.semiFinal, teamA: null, teamB: null, nextMatchId: 'f_1', roundIndex: 1),

      // --- FINAL ---
      const BracketMatch(id: 'f_1', stage: TournamentStage.final_, teamA: usa, teamB: null, roundIndex: 0),
    ];

    return TournamentStandingsData(
      groups: groups,
      bracketMatches: bracket,
    );
  }
}
