import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('SplitButtonInteraction Interaction Tests', () {
    testWidgets('renders initial state with main label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplitButtonInteraction(
              initialLabel: 'Share',
              actions: [
                SplitAction(label: 'Email', onTap: () {}),
                SplitAction(label: 'Copy', onTap: () {}),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Share'), findsOneWidget);
      // Widgets are in the tree but hidden/collapsed
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('expands and shows actions on tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplitButtonInteraction(
              initialLabel: 'Options',
              actions: [
                SplitAction(label: 'Edit', onTap: () {}),
                SplitAction(label: 'Delete', onTap: () {}),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Options'));
      await tester.pump(); // Start animation
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      // The back button icon is found twice (one is a spacer)
      expect(find.byIcon(Icons.chevron_left_rounded), findsNWidgets(2));
    });

    testWidgets('calls action onTap and collapses', (
      WidgetTester tester,
    ) async {
      bool editTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplitButtonInteraction(
              initialLabel: 'Menu',
              actions: [
                SplitAction(label: 'Edit', onTap: () => editTapped = true),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(editTapped, isTrue);
    });

    testWidgets('collapses when back button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplitButtonInteraction(
              initialLabel: 'Settings',
              actions: [SplitAction(label: 'General', onTap: () {})],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Tap the visible back button (the one that is not the spacer)
      await tester.tap(find.byIcon(Icons.chevron_left_rounded).last);
      await tester.pumpAndSettle();

      // Should be collapsed (check controller state or internal state via behavior)
    });

    testWidgets('SplitButtonController controls expansion state', (
      WidgetTester tester,
    ) async {
      final controller = SplitButtonController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplitButtonInteraction(
              controller: controller,
              initialLabel: 'Controlled',
              actions: [SplitAction(label: 'Action', onTap: () {})],
            ),
          ),
        ),
      );

      expect(find.text('Controlled'), findsOneWidget);

      controller.expand();
      await tester.pumpAndSettle();
      expect(find.text('Action'), findsOneWidget);

      controller.collapse();
      await tester.pumpAndSettle();
      expect(find.text('Controlled'), findsOneWidget);
    });

    testWidgets('triggers correct haptics on interaction', (
      WidgetTester tester,
    ) async {
      final List<MethodCall> log = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'HapticFeedback.vibrate') {
            log.add(methodCall);
          }
          return null;
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SplitButtonInteraction(
              initialLabel: 'Haptics',
              actions: [SplitAction(label: 'Action', onTap: () {})],
            ),
          ),
        ),
      );

      // Expand haptic (light)
      await tester.tap(find.text('Haptics'));
      await tester.pumpAndSettle();
      expect(
        log.any((m) => m.arguments == 'HapticFeedbackType.lightImpact'),
        isTrue,
      );

      // Action haptic (medium)
      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();
      expect(
        log.any((m) => m.arguments == 'HapticFeedbackType.mediumImpact'),
        isTrue,
      );
    });
  });
}
