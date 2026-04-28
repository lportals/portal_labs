import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class CardSplittingAccordionShowcase extends StatelessWidget {
  const CardSplittingAccordionShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Card Splitting Accordion',
      description:
          'Cards dynamically merge and separate based on expansion state. '
          'Phase-shifted corner radius interpolation creates a natural physical '
          'splitting feel. Fully themeable via AccordionStyle.',
      backgroundColor: const Color(0xFFF8F9FA),
      codeSnippet: '''CardSplittingAccordion(
  items: [
    AccordionItem(
      title: 'UX Strategy',
      content: 'Finalizing the vision for user-centered design.',
      icon: Icons.mouse_rounded,
    ),
    AccordionItem(
      title: 'Architecture',
      content: 'Defining the technical blueprint for scalability.',
      icon: Icons.developer_board_rounded,
    ),
  ],
)''',
      child: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardSplittingAccordion(
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
