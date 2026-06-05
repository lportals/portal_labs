import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  group('ScoreGauge & SegmentedStrengthIndicator Tests', () {
    testWidgets('ScoreGauge should render value and label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScoreGauge(
                value: 750.0,
                label: 'VERY GOOD',
              ),
            ),
          ),
        ),
      );

      // Verify the score text is rendered via semantics
      expect(find.bySemanticsLabel('750'), findsOneWidget);
      // Verify the label text is rendered
      expect(find.text('VERY GOOD'), findsOneWidget);
      // Verify ScoreGauge is present
      expect(find.byType(ScoreGauge), findsOneWidget);
    });

    testWidgets('ScoreGauge should respect custom valueFormatter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScoreGauge(
                value: 500.0,
                min: 0.0,
                max: 1000.0,
                label: 'MIDPOINT',
                valueFormatter: (val) => '${val.round()}/1000',
              ),
            ),
          ),
        ),
      );

      // Verify formatted score is rendered
      expect(find.bySemanticsLabel('500/1000'), findsOneWidget);
      expect(find.text('MIDPOINT'), findsOneWidget);
    });

    testWidgets('ScoreGauge animates smoothly on value change', (WidgetTester tester) async {
      double score = 400.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: ScoreGauge(
                        value: score,
                        label: 'TEST',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          score = 800.0;
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.bySemanticsLabel('400'), findsOneWidget);

      // Tap to trigger update
      await tester.tap(find.byType(ElevatedButton));
      // Pump initial frame of animation
      await tester.pump();
      // Score text should be in-transition (not yet 800, maybe still near 400)
      expect(find.bySemanticsLabel('800'), findsNothing);

      // Wait for animation to finish
      await tester.pumpAndSettle(const Duration(seconds: 2));
      // Score text should now be 800
      expect(find.bySemanticsLabel('800'), findsOneWidget);
    });

  });
}
