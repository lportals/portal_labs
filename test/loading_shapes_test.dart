import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('LoadingShapes', () {
    testWidgets('renders correctly when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingShapes(),
          ),
        ),
      );

      expect(find.byType(LoadingShapes), findsOneWidget);
      expect(
        find.descendant(of: find.byType(LoadingShapes), matching: find.byType(CustomPaint)),
        findsOneWidget,
      );
    });

    testWidgets('does not render when isLoading is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingShapes(
              isLoading: false,
              style: LoadingShapesStyle(shapes: []),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingShapes(isLoading: false),
          ),
        ),
      );
      
      expect(
        find.descendant(of: find.byType(LoadingShapes), matching: find.byType(CustomPaint)),
        findsOneWidget,
      );
    });
    
    testWidgets('respects custom style', (WidgetTester tester) async {
      const customColor = Colors.red;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingShapes(
              style: LoadingShapesStyle(
                color: customColor,
                size: 50.0,
              ),
            ),
          ),
        ),
      );

      final customPaintFinder = find.descendant(
        of: find.byType(LoadingShapes),
        matching: find.byType(CustomPaint),
      );
      final customPaint = tester.widget<CustomPaint>(customPaintFinder);
      expect(customPaint.size, const Size(50.0, 50.0));
    });
  });
}
