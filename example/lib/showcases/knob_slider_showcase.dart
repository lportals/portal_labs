import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class KnobSliderShowcase extends StatefulWidget {
  const KnobSliderShowcase({super.key});

  @override
  State<KnobSliderShowcase> createState() => _KnobSliderShowcaseState();
}

class _KnobSliderShowcaseState extends State<KnobSliderShowcase> {
  double _value = 73.0;

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
          'Knob Slider',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 1. The main demo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: KnobSlider(
                      value: _value,
                      min: 0,
                      max: 100,
                      step: 1,
                      onChanged: (val) {
                        setState(() {
                          _value = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
