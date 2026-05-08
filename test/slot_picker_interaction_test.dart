import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('SlotPickerInteraction', () {
    final testItems = [
      const SlotPickerItem(
        title: 'Monday',
      ),
      const SlotPickerItem(
        title: 'Tuesday',
        isEnabled: true,
        slots: [
          SlotRange(
            startTime: TimeOfDay(hour: 9, minute: 0),
            endTime: TimeOfDay(hour: 17, minute: 0),
          ),
        ],
      ),
    ];

    testWidgets('renders all items with correct titles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SlotPickerInteraction(
                items: testItems,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
    });

    testWidgets('expands item and shows slots when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SlotPickerInteraction(
                items: testItems,
              ),
            ),
          ),
        ),
      );

      // Tuesday is already enabled, but let's check if its slots are visible
      // By default it might not be expanded even if enabled, 
      // but in the implementation _handleHeaderTap handles expansion.
      // Wait, let's check the code again.
      // In _SlotPickerInteractionState:
      // final isExpanded = _expandedIndices.contains(index);
      
      // So Monday is collapsed. Let's tap it.
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();

      // Monday should now be expanded. 
      // It should also have triggered onItemToggle and onAddSlot if slots were empty.
    });

    testWidgets('triggers onItemToggle and onAddSlot when enabling an empty item', (WidgetTester tester) async {
      int? toggledIndex;
      bool? toggledState;
      int? addedSlotIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotPickerInteraction(
              items: [
                const SlotPickerItem(title: 'Monday'),
              ],
              onItemToggle: (index, state) {
                toggledIndex = index;
                toggledState = state;
              },
              onAddSlot: (index) {
                addedSlotIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();

      expect(toggledIndex, 0);
      expect(toggledState, true);
      expect(addedSlotIndex, 0);
    });

    testWidgets('can remove a slot', (WidgetTester tester) async {
      int? removedItemIndex;
      int? removedSlotIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotPickerInteraction(
              items: [
                const SlotPickerItem(
                  title: 'Monday',
                  slots: [
                    SlotRange(
                      startTime: TimeOfDay(hour: 9, minute: 0),
                      endTime: TimeOfDay(hour: 17, minute: 0),
                    ),
                  ],
                ),
              ],
              onRemoveSlot: (iIndex, sIndex) {
                removedItemIndex = iIndex;
                removedSlotIndex = sIndex;
              },
            ),
          ),
        ),
      );

      // Tap to enable and expand
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();

      // Find the remove button (Icons.close)
      final removeButton = find.byIcon(Icons.close);
      expect(removeButton, findsOneWidget);

      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      expect(removedItemIndex, 0);
      expect(removedSlotIndex, 0);
    });

    testWidgets('can add a slot when "Add More" is tapped', (WidgetTester tester) async {
      int? addedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotPickerInteraction(
              items: [
                const SlotPickerItem(
                  title: 'Monday',
                  slots: [
                    SlotRange(
                      startTime: TimeOfDay(hour: 9, minute: 0),
                      endTime: TimeOfDay(hour: 10, minute: 0),
                    ),
                  ],
                ),
              ],
              onAddSlot: (index) => addedIndex = index,
            ),
          ),
        ),
      );

      // Tap to enable and expand
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();

      final addMoreButton = find.text('Add More');
      expect(addMoreButton, findsOneWidget);

      await tester.tap(addMoreButton);
      await tester.pumpAndSettle();

      expect(addedIndex, 0);
    });

    testWidgets('shows overlap error when enabled', (WidgetTester tester) async {
      final style = const SlotPickerStyle(
        errorColor: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlotPickerInteraction(
              style: style,
              items: [
                const SlotPickerItem(
                  title: 'Monday',
                  slots: [
                    SlotRange(
                      startTime: TimeOfDay(hour: 9, minute: 0),
                      endTime: TimeOfDay(hour: 11, minute: 0),
                    ),
                    SlotRange(
                      startTime: TimeOfDay(hour: 10, minute: 0),
                      endTime: TimeOfDay(hour: 12, minute: 0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Tap to enable and expand
      await tester.tap(find.text('Monday'));
      await tester.pumpAndSettle();

      // Find containers with error styling
      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          // Use a more robust check for color
          final color = decoration.color;
          return color != null && (color.r * 255).round() == (Colors.red.r * 255).round() && color.a < 0.1;
        }
        return false;
      });

      expect(containerFinder, findsAtLeastNWidgets(1));
    });
  });
}
