import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class WeightPickerShowcase extends StatefulWidget {
  const WeightPickerShowcase({super.key});

  @override
  State<WeightPickerShowcase> createState() => _WeightPickerShowcaseState();
}

class _WeightPickerShowcaseState extends State<WeightPickerShowcase> {
  double _weight = 24.0;

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
          'Modern Weight Picker',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2), // Optical adjustment to push it up
              ModernWeightPicker(
                initialValue: _weight,
                onValueChanged: (value) {
                  setState(() {
                    _weight = value;
                  });
                },
              ),
              const Spacer(flex: 3), // More space at the bottom than the top
            ],
          ),
        ),
      ),
    );
  }
}
