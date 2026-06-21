import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/src/scrollable_subgroups/scrollable_subgroups.dart';
import 'package:portal_labs/src/scrollable_subgroups/models/scrollable_subgroups_data.dart';
import 'package:portal_labs/src/scrollable_subgroups/models/scrollable_subgroups_style.dart';

void main() {
  testWidgets('ScrollableSubgroups sticky header rendering test', (WidgetTester tester) async {
    // 1. Create dummy data
    final dummyData = [
      const ScrollableSubgroupsData<String>(
        title: 'Group A',
        subGroups: ['Qatar', 'Ecuador', 'Senegal', 'Netherlands'],
      ),
      const ScrollableSubgroupsData<String>(
        title: 'Group B',
        subGroups: ['England', 'Iran', 'USA', 'Wales'],
      ),
      const ScrollableSubgroupsData<String>(
        title: 'Group C',
        subGroups: ['Argentina', 'Saudi Arabia', 'Mexico', 'Poland'],
      ),
    ];

    // Track clicked items
    final List<String> clickedTeams = [];

    // 2. Render the widget on the test screen
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrollableSubgroups<String>(
            data: dummyData,
            style: const ScrollableSubgroupsStyle(),
            onChanged: (selectedTeam) {
              clickedTeams.add(selectedTeam);
            },
            itemBuilder: (context, team) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.sports_soccer),
                  title: Text(team),
                  trailing: const Text('0 pts'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Allow widgets to settle
    await tester.pumpAndSettle();

    // Verify initial groups are rendered
    expect(find.text('Group A'), findsOneWidget);
    expect(find.text('Qatar'), findsOneWidget);

    // Tap on an item and verify the callback fires
    await tester.tap(find.text('Qatar'));
    expect(clickedTeams, contains('Qatar'));
  });
}
