import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('StackedToastInteraction', () {
    late StackedToastController controller;

    setUp(() {
      controller = StackedToastController();
    });

    testWidgets('renders multiple toasts in a stack', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedToastInteraction(
              controller: controller,
            ),
          ),
        ),
      );

      controller.show(const StackedToastItem(
        id: '1',
        title: 'Toast 1',
        message: 'Message 1',
      ));
      await tester.pump(); // Start entry animation
      await tester.pump(const Duration(milliseconds: 500)); // Finish entry animation

      expect(find.text('Toast 1'), findsOneWidget);

      controller.show(const StackedToastItem(
        id: '2',
        title: 'Toast 2',
        message: 'Message 2',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Toast 2'), findsOneWidget);
      expect(find.text('Toast 1'), findsOneWidget);
    });

    testWidgets('dismisses toast on action button tap', (WidgetTester tester) async {
      bool actionTriggered = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedToastInteraction(
              controller: controller,
            ),
          ),
        ),
      );

      controller.show(StackedToastItem(
        id: '1',
        title: 'Action Toast',
        message: 'Message',
        actionLabel: 'Undo',
        onAction: () => actionTriggered = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Undo'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
      expect(find.text('Action Toast'), findsNothing);
    });

    testWidgets('dismisses toast automatically after duration', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedToastInteraction(
              controller: controller,
            ),
          ),
        ),
      );

      controller.show(const StackedToastItem(
        id: '1',
        title: 'Auto Dismiss',
        message: 'Message',
        duration: Duration(seconds: 1),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Auto Dismiss'), findsOneWidget);

      // Wait for duration
      await tester.pump(const Duration(seconds: 1));
      // Trigger the _removeToast call
      await tester.pump(); 
      // Wait for animationDuration (Future.delayed)
      await tester.pump(const Duration(milliseconds: 600));
      // Wait for spring settling
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('Auto Dismiss'), findsNothing);
    });

    testWidgets('dismisses toast on swipe up', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StackedToastInteraction(
              controller: controller,
            ),
          ),
        ),
      );

      controller.show(const StackedToastItem(
        id: '1',
        title: 'Swipe Me',
        message: 'Message',
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Swipe Me'), findsOneWidget);

      // Fling up with high velocity
      await tester.fling(find.text('Swipe Me'), const Offset(0, -500), 2000);
      await tester.pump(); // Start exit animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Swipe Me'), findsNothing);
    });
  });
}
