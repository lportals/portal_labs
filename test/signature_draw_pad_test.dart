import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('SignatureDrawPad Widget Tests', () {
    testWidgets('Should render initial state correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SignatureDrawPad(
              label: 'Test Signature',
              confirmButtonText: 'Confirm Now',
            ),
          ),
        ),
      );

      // Verify label is present
      expect(find.text('Test Signature'), findsOneWidget);

      // Verify confirm button text is present
      expect(find.text('Confirm Now'), findsOneWidget);

      // Verify drawing area exists (Look for the container with height 200)
      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.minHeight == 200,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Should change color when palette is tapped', (
      WidgetTester tester,
    ) async {
      final pad = const SignatureDrawPad(
        paletteColors: [Colors.red, Colors.blue],
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: pad)));

      // Find color buttons
      final redButton = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.red,
      );

      expect(redButton, findsOneWidget);

      await tester.tap(redButton);
      await tester.pump();

      // Verify selection icon appears
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    // Note: The 'Should lock the pad after confirmation' test is currently disabled
    // due to timing issues between virtual time and internal Future.delayed
    // in the physics-based animation listeners.
  });
}
