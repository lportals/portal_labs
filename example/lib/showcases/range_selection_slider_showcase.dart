import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class RangeSelectionSliderShowcase extends StatefulWidget {
  const RangeSelectionSliderShowcase({super.key});

  @override
  State<RangeSelectionSliderShowcase> createState() =>
      _RangeSelectionSliderShowcaseState();
}

class _RangeSelectionSliderShowcaseState
    extends State<RangeSelectionSliderShowcase> {
  RangeValues _priceRange = const RangeValues(640, 2380);

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
          'Range Selection Slider',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. The main demo matching the provided image
              _demoSection(
                child: RangeSelectionSlider(
                  values: _priceRange,
                  min: 0,
                  max: 5000,
                  onChanged: (values) => setState(() => _priceRange = values),
                  onApply: (values) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Applied range: \$${values.start.round()} - \$${values.end.round()}',
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  onCancel: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _demoSection({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
