import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('PremiumPagination', () {
    testWidgets('renders correctly with current and total pages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumPagination(
              currentPage: 1,
              totalPages: 5,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('of'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      
      // Previous button should be disabled
      final prevNode = tester.getSemantics(find.byKey(const ValueKey('pagination_prev')));
      expect(prevNode.label, 'Previous page');
      expect(prevNode.flagsCollection.isButton, isTrue);
      expect(prevNode.flagsCollection.isEnabled, isFalse);
      
      final nextNode = tester.getSemantics(find.byKey(const ValueKey('pagination_next')));
      expect(nextNode.label, 'Next page');
      expect(nextNode.flagsCollection.isButton, isTrue);
      expect(nextNode.flagsCollection.isEnabled, isTrue);
    });

    testWidgets('triggers onPageChanged when next is clicked', (WidgetTester tester) async {
      int? changedPage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumPagination(
              currentPage: 1,
              totalPages: 5,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('pagination_next')));
      await tester.pump();

      expect(changedPage, 2);
    });

    testWidgets('triggers onPageChanged when previous is clicked', (WidgetTester tester) async {
      int? changedPage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumPagination(
              currentPage: 3,
              totalPages: 5,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('pagination_prev')));
      await tester.pump();

      expect(changedPage, 2);
    });

    testWidgets('respects totalPages limit', (WidgetTester tester) async {
      int? changedPage;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumPagination(
              currentPage: 5,
              totalPages: 5,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      final nextNode = tester.getSemantics(find.byKey(const ValueKey('pagination_next')));
      expect(nextNode.flagsCollection.isEnabled, isFalse);
      
      await tester.tap(find.byKey(const ValueKey('pagination_next')));
      await tester.pump();
      
      expect(changedPage, isNull);
    });
  });
}
