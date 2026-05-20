/// Definition of a loading stage with a specific progress range.
class ProgressStage {
  /// Creates a [ProgressStage].
  const ProgressStage({required this.label, required this.endProgress})
    : assert(endProgress >= 0 && endProgress <= 1.0);

  /// The text to display during this stage.
  final String label;

  /// The progress value (0.0 to 1.0) at which this stage ends.
  final double endProgress;
}
