import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

class CardSplittingAccordionShowcase extends StatelessWidget {
  const CardSplittingAccordionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
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
          'Card Splitting Accordion',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CardSplittingAccordion(
                items: [
                  AccordionItem(
                    title: 'Introduction to UX',
                    content:
                        'Learn the fundamental concepts of User Experience design and why it matters in modern product development.',
                    icon: Icons.book_outlined,
                  ),
                  AccordionItem(
                    title: 'Design Research',
                    content:
                        'Methods for gathering and analyzing user data to inform design decisions.',
                    icon: Icons.search_rounded,
                  ),
                  AccordionItem(
                    title: 'Information Architecture',
                    content:
                        'Organizing and structuring content to ensure intuitive navigation and scalability.',
                    icon: Icons.account_tree_outlined,
                  ),
                  AccordionItem(
                    title: 'Visual Design Systems',
                    content:
                        'Creating a shared language of components, patterns, and principles to ensure visual consistency.',
                    icon: Icons.palette_outlined,
                  ),
                  AccordionItem(
                    title: 'Prototyping Strategy',
                    content:
                        'Developing high-fidelity interactive versions of your product to validate user flows and interactions.',
                    icon: Icons.developer_board_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
