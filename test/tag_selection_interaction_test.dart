import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';
import 'package:portal_labs/src/tag_selection_interaction/widgets/tag_item_widget.dart';

void main() {
  group('TagSelectionInteraction', () {
    final testTags = [
      const TagModel(id: '1', label: 'Flutter'),
      const TagModel(id: '2', label: 'React'),
      const TagModel(id: '3', label: 'Swift'),
    ];

    testWidgets('renders all tags correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TagSelectionInteraction(allTags: testTags)),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('React'), findsOneWidget);
      expect(find.text('Swift'), findsOneWidget);
    });

    testWidgets('respects initial selected ids', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelectionInteraction(
              allTags: testTags,
              initialSelectedIds: const {'1'},
            ),
          ),
        ),
      );

      // Verify that the tag with id '1' is selected
      expect(
        find.byWidgetPredicate(
          (w) => w is TagItemWidget && (w).tag.id == '1' && (w).isSelected,
        ),
        findsOneWidget,
      );
    });

    testWidgets('toggles tag selection on tap', (WidgetTester tester) async {
      Set<String>? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelectionInteraction(
              allTags: testTags,
              onChanged: (ids) => selected = ids,
            ),
          ),
        ),
      );

      // Initially none selected
      expect(
        find.byWidgetPredicate((w) => w is TagItemWidget && (w).isSelected),
        findsNothing,
      );

      // Tap 'Flutter'
      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();

      expect(selected, contains('1'));
      expect(
        find.byWidgetPredicate(
          (w) => w is TagItemWidget && (w).tag.id == '1' && (w).isSelected,
        ),
        findsOneWidget,
      );

      // Tap 'Flutter' again to deselect
      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();

      expect(selected, isNot(contains('1')));
      expect(
        find.byWidgetPredicate((w) => w is TagItemWidget && (w).isSelected),
        findsNothing,
      );
    });

    testWidgets('renders selected title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagSelectionInteraction(
              allTags: testTags,
              selectedTitle: 'MY TAGS',
            ),
          ),
        ),
      );

      expect(find.text('MY TAGS'), findsOneWidget);
    });
  });
}
