import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class AdaptiveSliderShowcase extends StatefulWidget {
  const AdaptiveSliderShowcase({super.key});

  @override
  State<AdaptiveSliderShowcase> createState() => _AdaptiveSliderShowcaseState();
}

class _AdaptiveSliderShowcaseState extends State<AdaptiveSliderShowcase> {
  double _currentCalories = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Adaptive Slider',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 1. Calories Slider (The original design)
              _buildDemoCard(
                child: AdaptiveSliderInteraction(
                  value: _currentCalories,
                  min: 0,
                  max: 350,
                  onChanged: (val) => setState(() => _currentCalories = val),
                  title: 'Calories',
                  unit: 'kCal',
                  step: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
