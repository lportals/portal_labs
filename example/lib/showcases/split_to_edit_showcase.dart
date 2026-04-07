import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class SplitToEditShowcase extends StatefulWidget {
  const SplitToEditShowcase({super.key});

  @override
  State<SplitToEditShowcase> createState() => _SplitToEditShowcaseState();
}

class _SplitToEditShowcaseState extends State<SplitToEditShowcase> {
  int _hours = 2;
  int _minutes = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Neutral light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
          'Split Edit',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Align(
        alignment: const Alignment(0, -0.15), // Ajuste sutil de centro óptico
        child: SplitToEditDuration(
          hours: _hours,
          minutes: _minutes,
          onChanged: (h, m) {
            setState(() {
              _hours = h;
              _minutes = m;
            });
          },
        ),
      ),
    );
  }
}
