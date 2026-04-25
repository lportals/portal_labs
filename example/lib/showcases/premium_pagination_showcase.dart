import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class PremiumPaginationShowcase extends StatefulWidget {
  const PremiumPaginationShowcase({super.key});

  @override
  State<PremiumPaginationShowcase> createState() => _PremiumPaginationShowcaseState();
}

class _PremiumPaginationShowcaseState extends State<PremiumPaginationShowcase> {
  int _currentPage = 5;
  final int _totalPages = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pagination'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: PremiumPagination(
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChanged: (page) => setState(() => _currentPage = page),
          ),
        ),
      ),
    );
  }
}
