import 'package:flutter/material.dart';
import 'showcases/reveal_copy_showcase.dart';
import 'showcases/premium_choice_chips_showcase.dart';
import 'showcases/weight_picker_showcase.dart';
import 'showcases/card_splitting_accordion_showcase.dart';
import 'showcases/journal_navigation_showcase.dart';
import 'showcases/adaptive_slider_showcase.dart';
import 'showcases/range_selection_slider_showcase.dart';
import 'showcases/subscription_pricing_picker_showcase.dart';
import 'showcases/media_collapsible_view_showcase.dart';
import 'showcases/knob_slider_showcase.dart';
import 'showcases/card_stack_interaction_showcase.dart';
import 'showcases/discrete_tabs_showcase.dart';
import 'showcases/split_button_interaction_showcase.dart';
import 'showcases/morphing_input_button_showcase.dart';
import 'showcases/scratch_to_reveal_showcase.dart';
import 'showcases/split_to_edit_showcase.dart';
import 'showcases/fractional_picker_showcase.dart';
import 'showcases/discovery_bar_showcase.dart';
import 'showcases/labeled_progress_indicator_showcase.dart';
import 'showcases/quick_switcher_showcase.dart';
import 'showcases/stacked_toast_showcase.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Inputs', 'Layout', 'Interactions'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFFFAFAFA),
            elevation: 0,
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
              centerTitle: false,
              title: const Text(
                'Portal Labs',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),
          // Category Filter Bar (Sticky)
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF666666),
                      ),
                      selectedColor: const Color(0xFF111111),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFEEEEEE),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildListDelegate(_filteredIcons(context)),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
        ],
      ),
    );
  }

  List<Widget> _filteredIcons(BuildContext context) {
    final List<_ComponentItem> allItems = const [
      _ComponentItem(
        title: 'Knob Slider',
        icon: Icons.track_changes_outlined,
        category: 'Inputs',
        page: KnobSliderShowcase(),
      ),
      _ComponentItem(
        title: 'Range Slider',
        icon: Icons.linear_scale_rounded,
        category: 'Inputs',
        page: RangeSelectionSliderShowcase(),
      ),
      _ComponentItem(
        title: 'Pricing Picker',
        icon: Icons.workspace_premium_outlined,
        category: 'Inputs',
        page: SubscriptionPricingPickerShowcase(),
      ),
      _ComponentItem(
        title: 'Choice Chips',
        icon: Icons.style_outlined,
        category: 'Inputs',
        page: PremiumChoiceChipsShowcase(),
      ),
      _ComponentItem(
        title: 'Weight Picker',
        icon: Icons.speed_outlined,
        category: 'Inputs',
        page: WeightPickerShowcase(),
      ),
      _ComponentItem(
        title: 'Color Slider',
        icon: Icons.tune,
        category: 'Inputs',
        page: AdaptiveSliderShowcase(),
      ),
      _ComponentItem(
        title: 'Journal Nav',
        icon: Icons.calendar_today_outlined,
        category: 'Layout',
        page: JournalNavigationShowcase(),
      ),
      _ComponentItem(
        title: 'Card Split',
        icon: Icons.layers_outlined,
        category: 'Layout',
        page: CardSplittingAccordionShowcase(),
      ),
      _ComponentItem(
        title: 'Video Reels',
        icon: Icons.video_library_outlined,
        category: 'Layout',
        page: MediaCollapsibleViewShowcase(),
      ),
      _ComponentItem(
        title: 'Secure Reveal',
        icon: Icons.visibility_outlined,
        category: 'Interactions',
        page: RevealCopyShowcase(),
      ),
      _ComponentItem(
        title: 'Card Stack',
        icon: Icons.layers_outlined,
        category: 'Interactions',
        page: CardStackInteractionShowcase(),
      ),
      _ComponentItem(
        title: 'Discrete Tabs',
        icon: Icons.more_horiz_rounded,
        category: 'Interactions',
        page: DiscreteTabsShowcase(),
      ),
      _ComponentItem(
        title: 'Split Button',
        icon: Icons.menu_open_rounded,
        category: 'Interactions',
        page: SplitButtonInteractionShowcase(),
      ),
      _ComponentItem(
        title: 'Morphing Input',
        icon: Icons.bolt_rounded,
        category: 'Interactions',
        page: MorphingInputButtonShowcase(),
      ),
      _ComponentItem(
        title: 'Scratch Reveal',
        icon: Icons.draw_rounded,
        category: 'Interactions',
        page: ScratchToRevealShowcase(),
      ),
      _ComponentItem(
        title: 'Split Edit',
        icon: Icons.compare_arrows_rounded,
        category: 'Interactions',
        page: SplitToEditShowcase(),
      ),
      _ComponentItem(
        title: 'Fractional Picker',
        icon: Icons.straighten,
        category: 'Inputs',
        page: FractionalPickerShowcase(),
      ),
      _ComponentItem(
        title: 'Discovery Bar',
        icon: Icons.manage_search_rounded,
        category: 'Inputs',
        page: DiscoveryBarShowcase(),
      ),
      _ComponentItem(
        title: 'Labeled Progress',
        icon: Icons.hourglass_top_rounded,
        category: 'Layout',
        page: LabeledProgressIndicatorShowcase(),
      ),
      _ComponentItem(
        title: 'Quick Switcher',
        icon: Icons.swap_horiz_rounded,
        category: 'Inputs',
        page: QuickSwitcherShowcase(),
      ),
      _ComponentItem(
        title: 'Toast Stack',
        icon: Icons.notification_important_outlined,
        category: 'Interactions',
        page: StackedToastShowcase(),
      ),
    ];


    return allItems
        .where(
          (item) =>
              _selectedCategory == 'All' || item.category == _selectedCategory,
        )
        .map(
          (item) => _ComponentIcon(
            title: item.title,
            icon: item.icon,
            onTap: () => _push(context, item.page),
          ),
        )
        .toList();
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }


}

class _ComponentIcon extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ComponentIcon({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(22),
                child: Center(
                  child: Icon(icon, size: 28, color: const Color(0xFF111111)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}

class _ComponentItem {
  final String title;
  final IconData icon;
  final String category;
  final Widget page;

  const _ComponentItem({
    required this.title,
    required this.icon,
    required this.category,
    required this.page,
  });
}
