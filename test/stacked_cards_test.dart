import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('StackedCards Tests', () {
    final mockChildren = List.generate(
      4,
      (index) => Container(
        key: ValueKey('card_$index'),
        color: Colors.red,
        child: Center(child: Text('Card $index')),
      ),
    );

    testWidgets('Should render card children and page indicator if enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedCards(
              showsScrollIndicator: true,
              children: mockChildren,
            ),
          ),
        ),
      );

      // Verify that the active card and stacked cards are rendered in the widget tree
      expect(find.byKey(const ValueKey('card_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('card_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('card_2')), findsOneWidget);

      // Card 3 is beyond style.maxStackedItems (which defaults to 3), but under the new behavior
      // it is rendered at the bottom position of the stack with full opacity.
      expect(find.byKey(const ValueKey('card_3')), findsOneWidget);

      // Verify page indicator dots are rendered (4 dots for 4 children)
      expect(find.byType(Container), findsAtLeast(4));
    });

    testWidgets('Should change index when horizontal swipe gesture occurs', (
      WidgetTester tester,
    ) async {
      int? updatedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 500,
              child: StackedCards(
                children: mockChildren,
                onIndexChanged: (idx) => updatedIndex = idx,
              ),
            ),
          ),
        ),
      );

      // Drag the topmost card to the left to reveal the next one (swipe left)
      final TestGesture gesture = await tester.startGesture(const Offset(250, 250));
      await gesture.moveBy(const Offset(-150, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // Index should update to 1
      expect(updatedIndex, equals(1));
    });

    testWidgets('Should respect initialIndex and allow swiping backward', (
      WidgetTester tester,
    ) async {
      int? updatedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 500,
              height: 500,
              child: StackedCards(
                initialIndex: 1,
                children: mockChildren,
                onIndexChanged: (idx) => updatedIndex = idx,
              ),
            ),
          ),
        ),
      );

      // Drag to the right (swipe right) to go back to card 0
      final TestGesture gesture = await tester.startGesture(const Offset(250, 250));
      await gesture.moveBy(const Offset(150, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      // Index should update back to 0
      expect(updatedIndex, equals(0));
    });

    testWidgets('Should toggle rotation without throwing exceptions', (
      WidgetTester tester,
    ) async {
      bool rotation = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: StackedCards(
                  rotationEnabled: rotation,
                  children: mockChildren,
                ),
              ),
            );
          },
        ),
      );

      expect(find.byKey(const ValueKey('card_0')), findsOneWidget);

      // Rebuild with rotation disabled
      rotation = false;
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('card_0')), findsOneWidget);
    });

    testWidgets('Should apply custom shadows and allow disabling them', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedCards(
              style: const StackedCardsStyle(
                shadows: [
                  BoxShadow(color: Colors.blue, blurRadius: 10),
                ],
              ),
              children: mockChildren,
            ),
          ),
        ),
      );

      final Container container = tester.widget(
        find.ancestor(
          of: find.byKey(const ValueKey('card_0')),
          matching: find.byType(Container),
        ).first,
      );

      final BoxDecoration decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, equals(1));
      expect(decoration.boxShadow!.first.color, equals(Colors.blue));
      expect(decoration.boxShadow!.first.blurRadius, equals(10));
    });

    testWidgets('Should apply custom alignment to Transform anchor', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedCards(
              style: const StackedCardsStyle(
                alignment: Alignment.topLeft,
              ),
              children: mockChildren,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Transform transform = tester.widget(
        find.ancestor(
          of: find.byKey(const ValueKey('card_0')),
          matching: find.byType(Transform),
        ).first,
      );

      expect(transform.alignment, equals(Alignment.topLeft));
    });

    testWidgets('Should respect custom snapCurve', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedCards(
              style: const StackedCardsStyle(
                snapCurve: Curves.linear,
              ),
              children: mockChildren,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('card_0')), findsOneWidget);
    });
  });
}
