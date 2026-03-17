import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'showcases/reveal_copy_showcase.dart';
import 'showcases/premium_choice_chips_showcase.dart';
import 'showcases/weight_picker_showcase.dart';
import 'showcases/card_splitting_accordion_showcase.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Portal Labs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSubtitle('Interactions'),
          const SizedBox(height: 16),
          _ComponentCard(
            title: 'Reveal & Copy',
            subtitle: 'Secure scramble reveal with copy animation',
            icon: LucideIcons.eye,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RevealCopyShowcase(),
                ),
              );
            },
          ),
          _ComponentCard(
            title: 'Premium Choice Chips',
            subtitle: 'Animated selection with pyramid flying media',
            icon: LucideIcons.smile,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PremiumChoiceChipsShowcase(),
                ),
              );
            },
          ),
          _ComponentCard(
            title: 'Modern Weight Picker',
            subtitle: 'Curved ruler interaction with snapping physics',
            icon: LucideIcons.gauge,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WeightPickerShowcase(),
                ),
              );
            },
          ),
          _ComponentCard(
            title: 'Card Splitting Accordion',
            subtitle: 'Cards that physically split to reveal content',
            icon: LucideIcons.layers,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CardSplittingAccordionShowcase(),
                ),
              );
            },
          ),
          
          // Future categories could go here...


          // const SizedBox(height: 32),
          // _buildSubtitle('Widgets'),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Color(0xFF999999),
        ),
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ComponentCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0F000000), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          highlightColor: const Color(0x05000000),
          splashColor: const Color(0x0A000000),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF7A7A7A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: Color(0xFFCCCCCC),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
