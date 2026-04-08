import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class FractionalPickerShowcase extends StatefulWidget {
  const FractionalPickerShowcase({super.key});

  @override
  State<FractionalPickerShowcase> createState() => _FractionalPickerShowcaseState();
}

class _FractionalPickerShowcaseState extends State<FractionalPickerShowcase> {
  double _value1 = 18.0;

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
          'Fractional Picker',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ModernFractionalPicker(
              initialValue: 18,
              minValue: 0,
              maxValue: 100,
              decimalPlaces: 0,
              onValueChanged: (val) {
                setState(() {
                  _value1 = val;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
