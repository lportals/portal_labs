import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class PremiumPaginationShowcase extends StatefulWidget {
  const PremiumPaginationShowcase({super.key});

  @override
  State<PremiumPaginationShowcase> createState() =>
      _PremiumPaginationShowcaseState();
}

class _PremiumPaginationShowcaseState
    extends State<PremiumPaginationShowcase> {
  int _currentPage = 5;
  final int _totalPages = 10;

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Premium Pagination',
      backgroundColor: Colors.white,
      description:
          'Tactile pagination with mechanical flip counter animations. '
          'Intelligent column width calculation based on total pages prevents '
          'layout jumps. Each digit uses an independent odometer roller.',
      codeSnippet: '''PremiumPagination(
  currentPage: _page,
  totalPages: 24,
  onPageChanged: (page) => setState(() => _page = page),
  style: PremiumPaginationStyle(
    activeColor: Colors.black,
  ),
)''',
      child: Center(
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
