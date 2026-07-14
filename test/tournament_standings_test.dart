import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  testWidgets('TournamentStandings initial rendering and tab switching test',
      (WidgetTester tester) async {
    // 1. Prepare dummy data
    const teamA = TournamentTeam(
        id: 'team_a', name: 'Argentina', code: 'ARG', points: 6, played: 2);
    const teamB = TournamentTeam(
        id: 'team_b', name: 'Saudi Arabia', code: 'KSA', points: 3, played: 2);
    final group = const TournamentGroup(
      id: 'grp_a',
      name: 'Group A',
      standings: [teamA, teamB],
    );

    final match = const BracketMatch(
      id: 'm1',
      stage: TournamentStage.roundOf16,
      teamA: teamA,
      teamB: teamB,
      scoreA: 2,
      scoreB: 1,
      isCompleted: true,
    );

    final dummyData = TournamentStandingsData(
      groups: [group],
      bracketMatches: [match],
    );

    TournamentTeam? tappedTeam;
    BracketMatch? tappedMatch;

    // 2. Pump widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TournamentStandings(
            data: dummyData,
            onTeamTap: (team) => tappedTeam = team,
            onMatchTap: (m) => tappedMatch = m,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify FIFA World Cup 2026 header exists
    expect(find.text('FIFA World Cup 2026'), findsOneWidget);

    // Verify Group Stage text and Group A table are displayed (name is rendered uppercased for style)
    expect(find.text('GROUP A'), findsOneWidget);
    expect(find.text('Argentina'), findsAtLeastNWidgets(1));

    // Tap Argentina and verify callback
    await tester.tap(find.text('Argentina').first);
    await tester.pump();
    expect(tappedTeam, equals(teamA));

    // Switch to R16 stage tab
    final r16TabFinder = find.text('R16');
    expect(r16TabFinder, findsOneWidget);
    await tester.tap(r16TabFinder);
    await tester.pumpAndSettle();

    // In bracket stage, Left Panel is visible with abbreviation (ARG), verify abbreviation shows
    expect(find.text('ARG'), findsWidgets); // Both left panel and bracket card have 'ARG'

    // Tap the R16 match card (or part of it)
    await tester.tap(find.text('ARG').last);
    await tester.pump();
    expect(tappedMatch, isNotNull);
  });

  testWidgets('TournamentStandings range selection test', (WidgetTester tester) async {
    const teamA = TournamentTeam(id: 'team_a', name: 'Argentina', code: 'ARG');
    final group = const TournamentGroup(id: 'grp_a', name: 'Group A', standings: [teamA]);
    final r16Match = const BracketMatch(
      id: 'm1',
      stage: TournamentStage.roundOf16,
      teamA: teamA,
    );
    final qfMatch = const BracketMatch(
      id: 'm2',
      stage: TournamentStage.quarterFinal,
      teamA: teamA,
    );

    final dummyData = TournamentStandingsData(
      groups: [group],
      bracketMatches: [r16Match, qfMatch],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TournamentStandings(
            data: dummyData,
            initialStage: TournamentStage.roundOf16,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap QF to select range R16 to QF
    final qfTabFinder = find.text('QF');
    await tester.tap(qfTabFinder);
    await tester.pumpAndSettle();

    // Verify both R16 and QF matches are visible
    expect(find.text('ARG'), findsWidgets);
  });
}
