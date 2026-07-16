import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/src/swipeable_action_tile/models/swipe_action.dart';
import 'package:portal_labs/src/swipeable_action_tile/swipeable_action_tile.dart';

void main() {
  group('SwipeableActionTile', () {
    testWidgets('renders child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SwipeableActionTile(
              child: Text('Message Item'),
            ),
          ),
        ),
      );

      expect(find.text('Message Item'), findsOneWidget);
    });

    testWidgets('swiping right reveals startActions', (WidgetTester tester) async {
      bool actionTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeableActionTile(
              startActions: [
                SwipeAction(
                  icon: const Icon(Icons.check),
                  backgroundColor: Colors.blue,
                  onTap: () => actionTapped = true,
                ),
              ],
              child: const SizedBox(
                height: 60,
                width: 300,
                child: Text('Message Item'),
              ),
            ),
          ),
        ),
      );

      // Drag the child to the right
      await tester.drag(find.text('Message Item'), const Offset(100, 0));
      await tester.pumpAndSettle();

      // Tap the action
      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });

    testWidgets('swiping left reveals endActions', (WidgetTester tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SwipeableActionTile(
              endActions: [
                SwipeAction(
                  icon: const Icon(Icons.delete),
                  backgroundColor: Colors.red,
                  onTap: () => actionTapped = true,
                ),
              ],
              child: const SizedBox(
                height: 60,
                width: 300,
                child: Text('Message Item'),
              ),
            ),
          ),
        ),
      );

      // Drag the child to the left
      await tester.drag(find.text('Message Item'), const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Tap the action
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });
  });
}
