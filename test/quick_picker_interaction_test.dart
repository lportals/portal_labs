import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('QuickPickerInteraction Tests', () {
    final List<QuickPickerOption> mockOptions = const [
      QuickPickerOption(
        value: 'private',
        label: 'Private',
        icon: Icons.lock_rounded,
      ),
      QuickPickerOption(
        value: 'public',
        label: 'Public',
        icon: Icons.public_rounded,
      ),
    ];

    testWidgets('Should render initial option correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickPickerInteraction(
                options: mockOptions,
              ),
            ),
          ),
        ),
      );

      // Verify the initially selected option is set in the trigger semantics label
      expect(
        find.bySemanticsLabel(RegExp(r'Selector, currently set to Private')),
        findsOneWidget,
      );

      // The trigger displays cinematic text, which splits words into single chars.
      // So no complete "Private" text widget should be present when the popup is closed.
      expect(find.text('Private'), findsNothing);

      // Verify the icon and chevron are rendered
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    });

    testWidgets('Should show segmented options popup on tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickPickerInteraction(
                options: mockOptions,
              ),
            ),
          ),
        ),
      );

      // Tap the picker trigger
      await tester.tap(find.byType(QuickPickerInteraction));
      await tester.pumpAndSettle();

      // Now both options should be visible inside the popup row as normal text widgets!
      expect(find.text('Private'), findsOneWidget);
      expect(find.text('Public'), findsOneWidget);

      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(2)); // Trigger + Popup
      expect(find.byIcon(Icons.public_rounded), findsOneWidget); // Popup
    });

    testWidgets('Should trigger onChanged and close popup on selection', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickPickerInteraction(
                options: mockOptions,
                onChanged: (index) {
                  selectedIndex = index;
                },
              ),
            ),
          ),
        ),
      );

      // Open the picker
      await tester.tap(find.byType(QuickPickerInteraction));
      await tester.pumpAndSettle();

      // Tap on the 'Public' option segment inside the popup.
      await tester.tap(find.text('Public'));
      await tester.pump(); // Starts the exit animation
      await tester.pumpAndSettle(const Duration(milliseconds: 300)); // Wait for slide & fade to settle

      // Callback should have triggered with index 1 (Public)
      expect(selectedIndex, equals(1));

      // The popup should be closed, so no Popup segments are rendered.
      expect(find.text('Private'), findsNothing);
      expect(find.text('Public'), findsNothing);

      // Verify the trigger now displays "Public" via semantics
      expect(
        find.bySemanticsLabel(RegExp(r'Selector, currently set to Public')),
        findsOneWidget,
      );
    });

    testWidgets(
      'Should NOT fire onChanged immediately on tap — only after popup closes',
      (WidgetTester tester) async {
        bool onChangedFired = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: QuickPickerInteraction(
                  options: mockOptions,
                  // Use a fast style so the test doesn't timeout waiting for timers.
                  style: const QuickPickerStyle(
                    animationDuration: Duration(milliseconds: 100),
                    popupAnimationDuration: Duration(milliseconds: 50),
                    selectionDismissDelay: Duration(milliseconds: 50),
                  ),
                  onChanged: (_) => onChangedFired = true,
                ),
              ),
            ),
          ),
        );

        // Open the picker
        await tester.tap(find.byType(QuickPickerInteraction));
        await tester.pumpAndSettle();

        // Tap an option but only process the gesture — no time advancement yet.
        await tester.tap(find.text('Public'));
        await tester.pump();

        // onChanged must NOT have fired: the dismiss timer and popup exit
        // animation haven't completed yet.
        expect(onChangedFired, isFalse,
            reason:
                'onChanged should be deferred until after the popup closes');

        // Settle all pending timers and animations.
        await tester.pumpAndSettle();

        // Now the popup has closed and onChanged should have fired.
        expect(onChangedFired, isTrue,
            reason: 'onChanged should fire once the popup exit animation ends');
      },
    );

    testWidgets('Should close popup without changing value when tapping outside', (
      WidgetTester tester,
    ) async {
      int? selectedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                const Positioned.fill(
                  child: Center(
                    child: Text('Background Area'),
                  ),
                ),
                Center(
                  child: QuickPickerInteraction(
                    options: mockOptions,
                    onChanged: (index) {
                      selectedIndex = index;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Open picker
      await tester.tap(find.byType(QuickPickerInteraction));
      await tester.pumpAndSettle();

      // Tap outside the popup container to dismiss. Since the overlay dismiss target 
      // is opaque and covers the screen, we can tap at any far-away coordinate like Offset(10, 10).
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pumpAndSettle();

      // The value should not have changed, and the popup should close
      expect(selectedIndex, isNull);

      // Trigger still set to Private
      expect(
        find.bySemanticsLabel(RegExp(r'Selector, currently set to Private')),
        findsOneWidget,
      );
      expect(find.text('Private'), findsNothing);
      expect(find.text('Public'), findsNothing);
    });

    testWidgets('Should respect disabled state and block interaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuickPickerInteraction(
                options: mockOptions,
                enabled: false,
              ),
            ),
          ),
        ),
      );

      // Tap the disabled picker
      await tester.tap(find.byType(QuickPickerInteraction));
      await tester.pumpAndSettle();

      // The popup should NOT be open
      expect(find.text('Public'), findsNothing);
    });
  });
}
