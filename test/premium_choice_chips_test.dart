import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('PremiumChoiceChips Widget Tests', () {
    final List<ChoiceItem> mockItems = [
      const ChoiceItem(label: 'Chip 1', emoji: '🍎'),
      const ChoiceItem(label: 'Chip 2', emoji: '🍌'),
      const ChoiceItem(label: 'Chip 3', emoji: '🍒'),
    ];

    testWidgets('Should render title and items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumChoiceChips(title: 'Test Choices', items: mockItems),
          ),
        ),
      );

      expect(find.text('Test Choices'), findsOneWidget);
      expect(find.text('Chip 1'), findsOneWidget);
      expect(find.text('🍎'), findsOneWidget);
    });

    testWidgets('Should select item and show action button', (
      WidgetTester tester,
    ) async {
      List<ChoiceItem>? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumChoiceChips(
              items: mockItems,
              onSelectionChanged: (val) => selected = val,
            ),
          ),
        ),
      );

      // Action button should not be visible initially
      expect(find.byKey(const ValueKey('bottom_action_button')), findsNothing);

      // Tap on Chip 1
      await tester.tap(find.text('Chip 1'));
      await tester.pump(); // Start flying media
      await tester.pumpAndSettle(); // Complete animations

      expect(selected, isNotNull);
      expect(selected!.length, 1);
      expect(selected![0].label, 'Chip 1');

      // Action button should now be visible
      expect(
        find.byKey(const ValueKey('bottom_action_button')),
        findsOneWidget,
      );
      expect(find.byType(PremiumFlipCounter), findsOneWidget);
      expect(find.textContaining('Item'), findsOneWidget);
    });

    testWidgets('Should call onActionPressed when button is tapped', (
      WidgetTester tester,
    ) async {
      bool actionPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumChoiceChips(
              items: mockItems,
              onActionPressed: () => actionPressed = true,
            ),
          ),
        ),
      );

      // Select an item to show the button
      await tester.tap(find.text('Chip 1'));
      await tester.pumpAndSettle();

      // Tap the action button
      await tester.tap(find.byKey(const ValueKey('bottom_action_button')));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('Should handle multiple selection', (
      WidgetTester tester,
    ) async {
      List<ChoiceItem>? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PremiumChoiceChips(
              items: mockItems,
              onSelectionChanged: (val) => selected = val,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Chip 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chip 2'));
      await tester.pumpAndSettle();

      expect(selected!.length, 2);
      expect(find.byType(PremiumFlipCounter), findsOneWidget);
      expect(find.textContaining('Items'), findsOneWidget);
    });
  });
}
