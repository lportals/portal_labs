import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class LabeledProgressIndicatorShowcase extends StatefulWidget {
  const LabeledProgressIndicatorShowcase({super.key});

  @override
  State<LabeledProgressIndicatorShowcase> createState() =>
      _LabeledProgressIndicatorShowcaseState();
}

class _LabeledProgressIndicatorShowcaseState
    extends State<LabeledProgressIndicatorShowcase> {
  double _progress = 0.0;
  bool _isLoading = false;
  bool _isError = false;

  final List<ProgressStage> _stages = const [
    ProgressStage(label: 'Consulting', endProgress: 0.1),
    ProgressStage(label: 'Processing', endProgress: 0.8),
    ProgressStage(label: 'Completed', endProgress: 1.0),
  ];

  Future<void> _startLoading() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _progress = 0.0;
      _isError = false;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    const int totalSteps = 100;
    for (int i = 0; i <= totalSteps; i++) {
      if (_isError) return;
      int delay;
      if (_progress < 0.1) {
        delay = 8;
      } else if (_progress < 0.8) {
        delay = 40;
      } else {
        delay = 15;
      }
      await Future.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      setState(() => _progress = i / totalSteps);
    }
    setState(() => _isLoading = false);
    HapticFeedback.heavyImpact();
  }

  void _triggerError() {
    HapticFeedback.vibrate();
    setState(() {
      _isError = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Labeled Progress',
      description:
          'Sequential loading flow with tranquil label transitions using '
          'Skew-X, Motion Blur, and Elastic Bounce. ProgressStage objects '
          'support non-uniform thresholds and a size-independent shimmer system.',
      codeSnippet: '''LabeledProgressIndicator(
  progress: _progress,
  stages: [
    ProgressStage(label: 'Consulting', endProgress: 0.1),
    ProgressStage(label: 'Processing', endProgress: 0.8),
    ProgressStage(label: 'Completed', endProgress: 1.0),
  ],
  isError: _isError,
  errorLabel: 'System timeout. Please retry.',
  onComplete: () => print('Done!'),
  style: LabeledProgressIndicatorStyle(
    progressColor: Color(0xFF007AFF),
    shimmerColor: Color(0xFF00FBFF),
  ),
)''',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildModernCard()],
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_isLoading)
                _buildMinorButton(
                  label: 'FAIL',
                  color: Colors.red[400]!,
                  onTap: _triggerError,
                ),
              if (_isLoading) const SizedBox(width: 8),
              _buildActionButton(),
            ],
          ),
          const SizedBox(height: 40),
          LabeledProgressIndicator(
            progress: _progress,
            stages: _stages,
            isError: _isError,
            errorLabel: 'System timeout. Please retry.',
            onComplete: () => debugPrint('Complete!'),
            style: LabeledProgressIndicatorStyle(
              progressColor: const Color(0xFF007AFF),
              shimmerColor: const Color(0xFF00FBFF),
              showPercentage: false,
              height: 14,
              borderRadius: BorderRadius.circular(8),
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMinorButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final bool canRun = !_isLoading;
    return GestureDetector(
      onTap: canRun ? _startLoading : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: canRun ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          _isLoading ? 'RUNNING...' : (_progress > 0 ? 'RESTART' : 'START'),
          style: TextStyle(
            color: canRun ? Colors.white : Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
