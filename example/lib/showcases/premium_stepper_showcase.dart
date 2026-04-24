import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class PremiumStepperShowcase extends StatefulWidget {
  const PremiumStepperShowcase({super.key});

  @override
  State<PremiumStepperShowcase> createState() => _PremiumStepperShowcaseState();
}

class _PremiumStepperShowcaseState extends State<PremiumStepperShowcase> {
  int _value = 99;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Stepper'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
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
