import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class PremiumProgressStepperShowcase extends StatefulWidget {
  const PremiumProgressStepperShowcase({super.key});

  @override
  State<PremiumProgressStepperShowcase> createState() =>
      _PremiumProgressStepperShowcaseState();
}

class _PremiumProgressStepperShowcaseState
    extends State<PremiumProgressStepperShowcase> {
  late PageController _pageController;
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _hasAcceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  bool get _canContinue {
    // Only Step 2 (index 1) requires validation in this demo
    if (_currentStep == 1) return _hasAcceptedTerms;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Premium Progress Stepper',
      backgroundColor: Colors.white,
      description:
          'A synchronized onboarding experience with step-specific validation '
          'logic. Step 2 requires accepting terms to proceed.',
      codeSnippet: '''PremiumProgressStepper(
  totalSteps: 4,
  currentStep: _currentStep,
  canContinue: _currentStep == 1 ? _hasAccepted : true,
  onStepChanged: (step) => ...,
)''',
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              physics: _canContinue 
                  ? const BouncingScrollPhysics() 
                  : const NeverScrollableScrollPhysics(),
              children: [
                _StepContent(
                  title: 'High-Fidelity UI',
                  subtitle: 'Engineered with precision for Apple-like aesthetics.',
                  icon: Icons.palette_rounded,
                  accentColor: const Color(0xFF424245),
                ),
                _StepContent(
                  title: 'Fluid Interactions',
                  subtitle: 'Spring physics and tactile feedback in every single gesture.',
                  icon: Icons.touch_app_rounded,
                  accentColor: const Color(0xFF636366),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox.adaptive(
                        value: _hasAcceptedTerms,
                        activeColor: const Color(0xFF1D1D1F),
                        onChanged: (val) => setState(() => _hasAcceptedTerms = val ?? false),
                      ),
                      const Text(
                        'Accept Interaction Terms',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF424245),
                        ),
                      ),
                    ],
                  ),
                ),
                _StepContent(
                  title: 'Fully Customizable',
                  subtitle: 'Control every aspect of the design system with ease.',
                  icon: Icons.tune_rounded,
                  accentColor: const Color(0xFF8E8E93),
                ),
                _StepContent(
                  title: 'Ready for Launch',
                  subtitle: 'Zero dependencies, maximum performance, and total reusability.',
                  icon: Icons.verified_rounded,
                  accentColor: const Color(0xFF424245),
                ),
              ],
            ),
          ),
          PremiumProgressStepper(
            totalSteps: _totalSteps,
            currentStep: _currentStep,
            canContinue: _canContinue,
            onStepChanged: _onStepChanged,
            onFinish: () {
              _onStepChanged(0);
              setState(() => _hasAcceptedTerms = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Onboarding Completed!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: const PremiumProgressStepperStyle(
              stepSpacing: 60,
              inactiveColor: Color(0xFFF3F4F6),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 48,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Color(0xFF424245),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey.shade600,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (child != null) ...[
            const SizedBox(height: 32),
            child!,
          ],
        ],
      ),
    );
  }
}
