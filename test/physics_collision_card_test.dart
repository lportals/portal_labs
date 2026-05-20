import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('PhysicsCollisionCard Widget Tests', () {
    testWidgets('renders PhysicsCollisionCard with items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: PhysicsCollisionCard(
                  items: [
                    PhysicsCollisionItem(
                      radius: 20.0,
                      child: Container(key: const Key('item_1')),
                    ),
                    PhysicsCollisionItem(
                      radius: 25.0,
                      child: Container(key: const Key('item_2')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Allow the post-frame callback to execute and spawn the items
      await tester.pump();

      // Verify widget and items are rendered
      expect(find.byType(PhysicsCollisionCard), findsOneWidget);
      expect(find.byKey(const Key('item_1')), findsOneWidget);
      expect(find.byKey(const Key('item_2')), findsOneWidget);
    });

    testWidgets('simulation updates item positions over time due to gravity', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: PhysicsCollisionCard(
                  items: [
                    PhysicsCollisionItem(
                      radius: 20.0,
                      initialPosition: const Offset(100.0, 50.0),
                      child: Container(key: const Key('item_1')),
                    ),
                  ],
                  style: const PhysicsCollisionCardStyle(
                    gravity: Offset(0, 500.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Spawn the items
      await tester.pump();

      // Check initial position of the positioned widget
      final initialPositioned = tester.widget<Positioned>(
        find.ancestor(
          of: find.byKey(const Key('item_1')),
          matching: find.byType(Positioned),
        ).first,
      );
      final initialTop = initialPositioned.top;

      // Pump to trigger frames and advance time
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      final updatedPositioned = tester.widget<Positioned>(
        find.ancestor(
          of: find.byKey(const Key('item_1')),
          matching: find.byType(Positioned),
        ).first,
      );
      final updatedTop = updatedPositioned.top;

      // With gravity pulling down, top should have increased (fallen down)
      expect(updatedTop, greaterThan(initialTop!));
    });

    testWidgets('dragging an item updates its position', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: PhysicsCollisionCard(
                  items: [
                    PhysicsCollisionItem(
                      radius: 20.0,
                      initialPosition: const Offset(100.0, 100.0),
                      child: Container(key: const Key('item_1')),
                    ),
                  ],
                  style: const PhysicsCollisionCardStyle(
                    gravity: Offset.zero, // turn off gravity for stable test
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Spawn the items
      await tester.pump();

      final itemFinder = find.byKey(const Key('item_1'));
      final center = tester.getCenter(itemFinder);

      // Drag the item
      final gesture = await tester.startGesture(center);
      await gesture.moveBy(const Offset(40, -30));
      await tester.pump();

      // Check positioned updated coordinates
      final positionedAfterDrag = tester.widget<Positioned>(
        find.ancestor(
          of: find.byKey(const Key('item_1')),
          matching: find.byType(Positioned),
        ).first,
      );

      // Position center should be shifted by (40, -30)
      // Original left was 100 - 20 = 80, top was 100 - 20 = 80.
      // Expected new center: (140, 70), so left: 120, top: 50.
      expect(positionedAfterDrag.left, closeTo(120.0, 1.0));
      expect(positionedAfterDrag.top, closeTo(50.0, 1.0));

      await gesture.up();
      await tester.pump();
    });
  });
}
