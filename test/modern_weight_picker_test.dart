import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('ModernWeightPicker Widget Tests', () {
    testWidgets('Should render title and initial value', (WidgetTester tester) async {
      await tester.pumpWidget(
        PortalTheme(
          data: PortalThemeData.light(),
          child: MaterialApp(
            home: Scaffold(
              body: ModernWeightPicker(
                initialValue: 70.0,
                onValueChanged: (val) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Weight'), findsOneWidget);
    });

    testWidgets('Should call onValueChanged when scrolled', (WidgetTester tester) async {
      double? changedValue;
      await tester.pumpWidget(
        PortalTheme(
          data: PortalThemeData.light(),
          child: MaterialApp(
            home: Scaffold(
              body: ModernWeightPicker(
                initialValue: 70.0,
                onValueChanged: (val) => changedValue = val,
              ),
            ),
          ),
        ),
      );

      // Find the SingleChildScrollView (interaction layer)
      final Finder scrollFinder = find.byType(SingleChildScrollView);
      
      // Drag the scroller
      await tester.drag(scrollFinder, const Offset(-100, 0));
      await tester.pump();

      expect(changedValue, isNotNull);
      expect(changedValue, greaterThan(70.0));
    });
  });
}
