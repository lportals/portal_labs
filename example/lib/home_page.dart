import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
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
import 'showcases/disclosure_switch_showcase.dart';
import 'showcases/pinnable_list_showcase.dart';
import 'showcases/todo_list_interaction_showcase.dart';
import 'showcases/slot_picker_showcase.dart';
import 'showcases/tag_selection_interaction_showcase.dart';
import 'showcases/collapsible_notification_panel_showcase.dart';
import 'showcases/premium_stepper_showcase.dart';
import 'showcases/premium_pagination_showcase.dart';
import 'showcases/currency_swap_showcase.dart';
import 'showcases/premium_progress_stepper_showcase.dart';
import 'showcases/inline_delete_interaction_showcase.dart';
import 'showcases/feedback_interaction_showcase.dart';






class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<String> _categories = [
    'All',
    'Inputs',
    'Layout',
    'Interactions',
  ];


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
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 12),
              centerTitle: false,
              title: Text(
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
          // Category filter using the library's own DiscreteTabs component.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: DiscreteTabs(
                currentIndex: _selectedIndex,
                tabs: [
                  DiscreteTab(
                    label: 'All',
                    icon: Icons.apps_rounded,
                    activeColor: const Color(0xFF111111),
                  ),
                  DiscreteTab(
                    label: 'Inputs',
                    icon: Icons.tune_rounded,
                    activeColor: const Color(0xFF007AFF),
                  ),
                  DiscreteTab(
                    label: 'Layout',
                    icon: Icons.dashboard_rounded,
                    activeColor: const Color(0xFFFF9500),
                  ),
                  DiscreteTab(
                    label: 'Interactions',
                    icon: Icons.gesture_rounded,
                    activeColor: const Color(0xFFFF2D55),
                  ),
                ],
                onSelect: (index) => setState(() => _selectedIndex = index),
              ),
            ),
          ),
          // Replaced SliverGrid with a custom SpringyGrid for fluid physics-based 
          // transitions between categories. Items now 'fly' to their new positions.
          SliverToBoxAdapter(
            child: _SpringyGrid(
              selectedIndex: _selectedIndex,
              categories: _categories,
              onTap: (page) => _push(context, page),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

/// A premium grid implementation that uses spring physics for reordering.
class _SpringyGrid extends StatelessWidget {
  final int selectedIndex;
  final List<String> categories;
  final Function(Widget) onTap;

  const _SpringyGrid({
    required this.selectedIndex,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String selectedCategory = categories[selectedIndex];
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
      _ComponentItem(
        title: 'Disclosure Sw',
        icon: Icons.toggle_on_outlined,
        category: 'Interactions',
        page: DisclosureSwitchShowcase(),
      ),
      _ComponentItem(
        title: 'Pinnable List',
        icon: Icons.push_pin_outlined,
        category: 'Interactions',
        page: PinnableListShowcase(),
      ),
      _ComponentItem(
        title: 'Todo List',
        icon: Icons.checklist_rtl_rounded,
        category: 'Interactions',
        page: TodoListInteractionShowcase(),
      ),
      _ComponentItem(
        title: 'Slot Picker',
        icon: Icons.access_time_rounded,
        category: 'Inputs',
        page: SlotPickerShowcase(),
      ),
      _ComponentItem(
        title: 'Tag Selection',
        icon: Icons.label_important_outline_rounded,
        category: 'Interactions',
        page: TagSelectionInteractionShowcase(),
      ),
      _ComponentItem(
        title: 'Notify Panel',
        icon: Icons.notifications_active_outlined,
        category: 'Layout',
        page: CollapsibleNotificationPanelShowcase(),
      ),
      _ComponentItem(
        title: 'Premium Stepper',
        icon: Icons.add_circle_outline_rounded,
        category: 'Inputs',
        page: PremiumStepperShowcase(),
      ),
      _ComponentItem(
        title: 'Pagination',
        icon: Icons.last_page_rounded,
        category: 'Inputs',
        page: PremiumPaginationShowcase(),
      ),
      _ComponentItem(
        title: 'Swap Currency',
        icon: Icons.currency_exchange_rounded,
        category: 'Inputs',
        page: CurrencySwapShowcase(),
      ),
      _ComponentItem(
        title: 'Progress Step',
        icon: Icons.linear_scale_rounded,
        category: 'Layout',
        page: PremiumProgressStepperShowcase(),
      ),
      _ComponentItem(
        title: 'Inline Delete',
        icon: Icons.delete_sweep_rounded,
        category: 'Interactions',
        page: InlineDeleteInteractionShowcase(),
      ),
      _ComponentItem(
        title: 'Feedback Interaction',
        icon: Icons.thumbs_up_down_outlined,
        category: 'Interactions',
        page: FeedbackInteractionShowcase(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const int crossAxisCount = 3;
          const double spacing = 16.0;
          final double itemWidth =
              (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
                  crossAxisCount;
          final double itemHeight = itemWidth / 0.82;

          // Filter items and calculate their target positions
          final List<_ComponentItem> visibleItems = allItems
              .where((it) =>
                  selectedCategory == 'All' || it.category == selectedCategory)
              .toList();

          final int totalRowsVisible =
              (visibleItems.length / crossAxisCount).ceil();
          final double totalHeight =
              (totalRowsVisible * itemHeight) + ((totalRowsVisible - 1) * spacing);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: allItems.map((item) {
                final int visibleIndex = visibleItems.indexOf(item);
                final bool isVisible = visibleIndex != -1;

                // Target coordinates
                double targetTop = 0;
                double targetLeft = 0;

                if (isVisible) {
                  final int row = visibleIndex ~/ crossAxisCount;
                  final int col = visibleIndex % crossAxisCount;
                  targetTop = row * (itemHeight + spacing);
                  targetLeft = col * (itemWidth + spacing);
                } else {
                  // Move out-of-view items to a predictable hidden area 
                  // or just let them fade in place. 
                  // Moving them slightly down/right feels more organic.
                  final int originalIndex = allItems.indexOf(item);
                  final int row = originalIndex ~/ crossAxisCount;
                  final int col = originalIndex % crossAxisCount;
                  targetTop = (row + 1) * (itemHeight + spacing);
                  targetLeft = col * (itemWidth + spacing);
                }

                return AnimatedPositioned(
                  key: ValueKey('comp_${item.title}'),
                  duration: const Duration(milliseconds: 900),
                  curve: PortalSpringCurve(stiffness: 140, damping: 20),
                  top: targetTop,
                  left: targetLeft,
                  width: itemWidth,
                  height: itemHeight,
                  child: AnimatedScale(
                    scale: isVisible ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: isVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: IgnorePointer(
                        ignoring: !isVisible,
                        child: RepaintBoundary(
                          child: _ComponentIcon(
                            title: item.title,
                            icon: item.icon,
                            onTap: () => onTap(item.page),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
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
