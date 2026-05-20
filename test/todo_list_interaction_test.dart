import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('TodoListInteraction', () {
    final testCategories = [
      const TodoCategory(id: '1', title: 'Personal'),
      const TodoCategory(id: '2', title: 'Work'),
    ];

    final testItems = [
      const TodoItem(id: 'a', title: 'Buy milk', categoryId: '1'),
      const TodoItem(
        id: 'b',
        title: 'Call mom',
        categoryId: '1',
        isCompleted: true,
      ),
      const TodoItem(id: 'c', title: 'Finish report', categoryId: '2'),
    ];

    testWidgets('renders header date correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoListInteraction(
              items: testItems,
              categories: testCategories,
              dateString: 'MAY 08 2026',
            ),
          ),
        ),
      );

      expect(find.text('MAY 08 2026'), findsOneWidget);
    });

    testWidgets('renders all categories and items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoListInteraction(
              items: testItems,
              categories: testCategories,
              dateString: 'MAY 08 2026',
            ),
          ),
        ),
      );

      expect(find.text('Personal'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Call mom'), findsOneWidget);
      expect(find.text('Finish report'), findsOneWidget);
    });

    testWidgets('toggles item completion state on tap', (
      WidgetTester tester,
    ) async {
      List<TodoItem>? updatedItems;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoListInteraction(
              items: testItems,
              categories: testCategories,
              dateString: 'MAY 08 2026',
              onChanged: (items) => updatedItems = items,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buy milk'));
      // The implementation has a 350ms delay for flying animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(updatedItems, isNotNull);
      final buyMilk = updatedItems!.firstWhere((it) => it.id == 'a');
      expect(buyMilk.isCompleted, isTrue);
    });

    testWidgets('filters items correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoListInteraction(
              items: testItems,
              categories: testCategories,
              dateString: 'MAY 08 2026',
            ),
          ),
        ),
      );

      // Initially 'All' is selected.
      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Call mom'), findsOneWidget);

      // Select 'Pending'
      await tester.tap(find.text('Pending'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Call mom'), findsNothing);

      // Select 'Completed'
      await tester.tap(find.text('Completed'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Buy milk'), findsNothing);
      expect(find.text('Call mom'), findsOneWidget);
    });

    testWidgets('collapses and expands categories', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoListInteraction(
              items: testItems,
              categories: testCategories,
              dateString: 'MAY 08 2026',
            ),
          ),
        ),
      );

      // Initially expanded
      expect(find.text('Buy milk'), findsOneWidget);

      // Tap 'Personal' header to collapse
      await tester.tap(find.text('Personal'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // In the implementation, it uses AnimatedOpacity.
      // Instead of checking opacity which might be tricky with animations,
      // let's check if the widget is still "hit-testable" or visible.
      // Actually, it uses AnimatedOpacity with opacity: isItemVisible ? 1.0 : 0.0

      final opacityFinder = find
          .ancestor(
            of: find.text('Buy milk'),
            matching: find.byType(AnimatedOpacity),
          )
          .first;

      final animatedOpacity = tester.widget<AnimatedOpacity>(opacityFinder);
      expect(animatedOpacity.opacity, 0.0);
    });
  });
}
