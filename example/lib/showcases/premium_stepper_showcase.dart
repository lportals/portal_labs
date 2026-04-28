import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class PremiumStepperShowcase extends StatefulWidget {
  const PremiumStepperShowcase({super.key});

  @override
  State<PremiumStepperShowcase> createState() =>
      _PremiumStepperShowcaseState();
}

class _PremiumStepperShowcaseState extends State<PremiumStepperShowcase> {
  int _value = 99;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Premium Stepper',
      backgroundColor: Colors.white,
      description:
          'Minimalist tactile stepper with mechanical flip counter animations '
          'and haptic feedback. PremiumFlipCounter integration for fluid '
          'odometer-style numerical transitions. Circular buttons with scale feedback.',
      codeSnippet: '''PremiumStepper(
  value: _quantity,
  min: 0,
  max: 99,
  onChanged: (val) => setState(() => _quantity = val),
  style: PremiumStepperStyle(
    backgroundColor: Colors.white,
    borderColor: Color(0xFFF2F2F7),
    buttonColor: Color(0xFFF2F2F7),
    iconColor: Colors.black,
  ),
)''',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: PremiumStepper(
            value: _value,
            onChanged: (val) => setState(() => _value = val),
            style: const PremiumStepperStyle(
              backgroundColor: Colors.white,
              borderColor: Color(0xFFF2F2F7),
              buttonColor: Color(0xFFF2F2F7),
              iconColor: Colors.black,
              textStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
