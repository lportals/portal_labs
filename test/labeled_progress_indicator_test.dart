import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/src/labeled_progress_indicator/labeled_progress_indicator.dart';
import 'package:portal_labs/src/labeled_progress_indicator/models/labeled_progress_indicator_style.dart';
import 'package:portal_labs/src/labeled_progress_indicator/models/progress_stage.dart';

void main() {
  group('LabeledProgressIndicator', () {
    final stages = [
      const ProgressStage(label: 'Initializing', endProgress: 0.3),
      const ProgressStage(label: 'Loading Data', endProgress: 0.7),
      const ProgressStage(label: 'Finishing', endProgress: 1.0),
    ];

    testWidgets('renders initial stage label correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.1,
              stages: stages,
            ),
          ),
        ),
      );

      expect(find.text('Initializing'), findsOneWidget);
      expect(find.text('Loading Data'), findsNothing);
    });

    testWidgets('transitions to next stage when progress increases', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.1,
              stages: stages,
            ),
          ),
        ),
      );

      expect(find.text('Initializing'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.5,
              stages: stages,
            ),
          ),
        ),
      );

      // Start of AnimatedSwitcher transition (600ms in widget)
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Loading Data'), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Initializing'), findsNothing);
      expect(find.text('Loading Data'), findsOneWidget);
    });

    testWidgets('shows percentage when enabled in style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.45,
              stages: stages,
              style: const LabeledProgressIndicatorStyle(
                showPercentage: true,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('45%'), findsOneWidget);
    });

    testWidgets('handles error state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.5,
              stages: stages,
              isError: true,
              errorLabel: 'Upload Failed',
            ),
          ),
        ),
      );

      expect(find.text('Upload Failed'), findsOneWidget);
      expect(find.text('Loading Data'), findsNothing);
      
      // Verify color is red (Colors.red[400] is used in the widget)
      final textWidget = tester.widget<Text>(find.text('Upload Failed'));
      expect(textWidget.style?.color, Colors.red[400]);
    });

    testWidgets('triggers onComplete when progress reaches 1.0', (WidgetTester tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.9,
              stages: stages,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      expect(completed, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 1.0,
              stages: stages,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      // Pulse animation takes 600ms
      await tester.pump(const Duration(seconds: 1));
      expect(completed, isTrue);
    });

    testWidgets('works with simple String stages', (WidgetTester tester) async {
      final stringStages = ['Step 1', 'Step 2', 'Step 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.1, // 0.1 * 3 = 0.3 -> index 0
              stages: stringStages,
            ),
          ),
        ),
      );

      expect(find.text('Step 1'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LabeledProgressIndicator(
              progress: 0.5, // 0.5 * 3 = 1.5 -> index 1
              stages: stringStages,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Step 2'), findsOneWidget);
    });
  });
}
