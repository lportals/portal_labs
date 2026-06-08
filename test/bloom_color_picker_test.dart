import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('BloomColorPicker Tests', () {
    testWidgets('Should render closed state with color circle and hex pill', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloomColorPicker(
                initialColor: const Color(0xFFEF4D3D),
                onColorChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Verify widget exists
      expect(find.byType(BloomColorPicker), findsOneWidget);
      // Verify text field exists (showing the hex code)
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('#EF4D3D'), findsOneWidget);
    });

    testWidgets('Should not show hex pill if showHexPill is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloomColorPicker(
                initialColor: const Color(0xFFEF4D3D),
                onColorChanged: (_) {},
                style: const BloomColorPickerStyle(showHexPill: false),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BloomColorPicker), findsOneWidget);
      // Verify no TextField is rendered
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('Should toggle state (expand) when tapping the main indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloomColorPicker(
                initialColor: const Color(0xFFEF4D3D),
                onColorChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Initially closed
      expect(find.byIcon(Icons.edit), findsOneWidget);

      // Tap main indicator (the color circle container)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump(); // start animation
      await tester.pumpAndSettle(); // finish animation

      // Should now be open and show the MorphingRingPainter in the overlay
      expect(
        find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MorphingRingPainter),
        findsOneWidget,
      );

      // Verify that the hex pill/edit icon is faded out (one of the ancestor FadeTransitions has opacity 0.0)
      final fadeTransitions = tester.widgetList<FadeTransition>(
        find.ancestor(
          of: find.byIcon(Icons.edit),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(fadeTransitions.any((ft) => ft.opacity.value == 0.0), isTrue);
    });

    testWidgets('Should restore the last valid color on invalid hex defocus', (WidgetTester tester) async {
      Color? changedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloomColorPicker(
                initialColor: const Color(0xFFEF4D3D),
                onColorChanged: (c) => changedColor = c,
              ),
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Enter an invalid hex string (allowed by formatters but parsed as null)
      await tester.enterText(textFieldFinder, '#AAAA');
      // Verify text is updated
      expect(find.text('#AAAA'), findsOneWidget);

      // Unfocus the TextField by tapping elsewhere or triggering focus loss
      final FocusScopeNode focusScope = FocusScope.of(tester.element(textFieldFinder));
      focusScope.unfocus();
      await tester.pumpAndSettle();

      // Text field should snap back to the last valid color (#EF4D3D)
      expect(find.text('#EF4D3D'), findsOneWidget);
      // No callback was fired with white color
      expect(changedColor, isNull);
    });

    testWidgets('Should update color when typing a valid hex string', (WidgetTester tester) async {
      Color? changedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloomColorPicker(
                initialColor: const Color(0xFFEF4D3D),
                onColorChanged: (c) => changedColor = c,
              ),
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      // Enter a valid hex string
      await tester.enterText(textFieldFinder, '#3B7BBF');
      await tester.pump();

      // The color changed callback should fire
      expect(changedColor, equals(const Color(0xFF3B7BBF)));
    });

    testWidgets('Should handle custom color lists shorter than 12 elements', (WidgetTester tester) async {
      // Pass only 3 colors, should repeat them and build successfully
      final List<Color> customColors = [
        const Color(0xFFEF4D3D),
        const Color(0xFF3B7BBF),
        const Color(0xFF4DBB5A),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BloomColorPicker(
                initialColor: const Color(0xFFEF4D3D),
                onColorChanged: (_) {},
                colors: customColors,
              ),
            ),
          ),
        ),
      );

      // Tap to open
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Verify we rendered without throwing exceptions
      expect(find.byType(BloomColorPicker), findsOneWidget);
    });
  });
}
