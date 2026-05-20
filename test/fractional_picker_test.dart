import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/src/fractional_picker/fractional_picker.dart';
import 'package:portal_labs/src/fractional_picker/models/fractional_picker_style.dart';

void main() {
  group('ModernFractionalPicker', () {
    testWidgets('renders correctly with initial value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernFractionalPicker(
              initialValue: 50.0,
              onValueChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify the widget exists
      expect(find.byType(ModernFractionalPicker), findsOneWidget);

      // Verify semantics/initial value
      final semantics = tester.getSemantics(find.byType(SingleChildScrollView));
      expect(semantics.value, '50');
    });

    testWidgets('scrolls and updates value', (WidgetTester tester) async {
      double lastValue = 50.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ModernFractionalPicker(
                initialValue: 50.0,
                onValueChanged: (val) => lastValue = val,
              ),
            ),
          ),
        ),
      );

      // Drag the ruler
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-64.0, 0.0),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The value should have changed to approximately 51
      expect(lastValue, closeTo(51.0, 0.1));
    });

    testWidgets('snaps to integer values when decimalPlaces is 0', (
      WidgetTester tester,
    ) async {
      double lastValue = 50.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ModernFractionalPicker(
                initialValue: 50.0,
                onValueChanged: (val) => lastValue = val,
              ),
            ),
          ),
        ),
      );

      // Drag 33 pixels (more than half a unit). It should snap to 51.
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-33.0, 0.0),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should be 51
      expect(lastValue, 51.0);

      // Drag back 10 pixels. Should stay at 51 because it's not enough to cross the 0.5 threshold.
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(10.0, 0.0),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(lastValue, 51.0);
    });

    testWidgets('supports decimal places', (WidgetTester tester) async {
      double lastValue = 50.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ModernFractionalPicker(
                initialValue: 50.0,
                decimalPlaces: 1,
                onValueChanged: (val) => lastValue = val,
              ),
            ),
          ),
        ),
      );

      // pixelsPerUnit for decimalPlaces: 1 is 120.0
      // stepWidth is 12.0 (120 / 10)
      // Drag 12 pixels to move 0.1 units
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-12.0, 0.0),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(lastValue, 50.1);
    });

    testWidgets('respects min and max bounds', (WidgetTester tester) async {
      double lastValue = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ModernFractionalPicker(
                initialValue: 1.0,
                maxValue: 2.0,
                onValueChanged: (val) => lastValue = val,
              ),
            ),
          ),
        ),
      );

      // Drag way past max
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(-500.0, 0.0),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(lastValue, 2.0);

      // Drag way past min
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(1000.0, 0.0),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(lastValue, 0.0);
    });

    testWidgets('custom style is applied', (WidgetTester tester) async {
      const customStyle = FractionalPickerStyle(
        backgroundColor: Colors.red,
        activeColor: Colors.blue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernFractionalPicker(
              onValueChanged: (_) {},
              style: customStyle,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });
  });
}
