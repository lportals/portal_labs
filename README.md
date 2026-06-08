# Portal Labs

A specialized collection of **40+ premium, high-performance, and
dependency-free** Flutter UI components and advanced interactions. Built
exclusively with vanilla Flutter and Dart to ensure maximum portability and
long-term stability.

[**🌐 Live Demo**](https://luisportal.com/labs)

![Portal Labs Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/general.gif)

## Design Philosophy

The Portal Labs architecture is centered around three core pillars:
**performance**, **portability**, and **visual excellence**. By adhering to a
strict "zero-dependency" technical policy, we ensure that every component
remains lightweight and compatible across all Flutter-supported platforms.

### Technical Constraints

To maintain a clean architecture and eliminate overhead, this repository follows
these engineering standards:

- **SDK-Only Foundation**: Components are developed using only core Flutter and
  Dart libraries.
- **Internal Utilites**: Formatting, text measurement, and specialized date
  logic are centralized in [PortalUtils](lib/src/common/portal_utils.dart) to
  avoid external packages like `intl`.
- **Custom Design System**: Icons and typography leverage system defaults and
  Material Design standards, removing the need for `google_fonts` or third-party
  icon sets.
- **Native Animation Engine**: Complex physics and mechanical transitions (e.g.,
  3D flips, magnetic snapping) are implemented using standard
  `AnimationController` and `Tween` sequences.

This strategy makes every component **instantly portable**—allowing developers
to integrate the full library or copy individual source files without managing
external versioning conflicts.

## Component Library

| #  | Component                                                                       | Description                                                                                                                      | Technical Scope | Location                                                                             |
| :- | :------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------- | :-------------- | :----------------------------------------------------------------------------------- |
| 1  | **[Reveal &amp; Copy](docs/components/reveal_and_copy.md)**                     | Secure data masking with scramble reveal and clipboard animation.                                                                | Interaction     | **[lib/src/reveal_and_copy](lib/src/reveal_and_copy)**                               |
| 2  | **[Modern Weight Picker](docs/components/modern_weight_picker.md)**             | Precision scrollable ruler with magnetic snapping and haptic feedback.                                                           | Numeric Input   | **[lib/src/weight_picker](lib/src/weight_picker)**                                   |
| 3  | **[Premium Choice Chips](docs/components/premium_choice_chips.md)**             | Animated multi-selection system with flying media transitions.                                                                   | Selection       | **[lib/src/premium_choice_chips](lib/src/premium_choice_chips)**                     |
| 4  | **[Journal Navigation](docs/components/journal_navigation.md)**                 | Vertical date-based navigation with 3D flip counters and snapping transitions.                                                   | Navigation      | **[lib/src/journal_navigation](lib/src/journal_navigation)**                         |
| 5  | **[Card Splitting Accordion](docs/components/card_splitting_accordion.md)**     | Dynamic grouping interaction with physical splitting and variable corner radii.                                                  | Layout          | **[lib/src/card_splitting_accordion](lib/src/card_splitting_accordion)**             |
| 6  | **[Adaptive Slider](docs/components/adaptive_slider.md)**                       | Value-aware gradient slider with real-time color morphing.                                                                       | Interaction     | **[lib/src/adaptive_slider_interaction](lib/src/adaptive_slider_interaction)**       |
| 7  | **[Range Selection Slider](docs/components/range_selection_slider.md)**         | Premium bi-directional range selector with mechanical Odometer-style counters and manual input support.                          | Selection       | **[lib/src/range_selection_slider](lib/src/range_selection_slider)**                 |
| 8  | **[Subscription Picker](docs/components/subscription_picker.md)**               | High-fidelity pricing selector with minimalist monthly/yearly toggle logic.                                                      | Selection       | **[lib/src/subscription_pricing_picker](lib/src/subscription_pricing_picker)**       |
| 9  | **[Media Collapsible View](docs/components/media_collapsible_view.md)**         | Reels-inspired video background with dynamic collapsible interactive sheet.                                                      | Interaction     | **[lib/src/media_collapsible_view](lib/src/media_collapsible_view)**                 |
| 10 | **[High-Fidelity Knob Slider](docs/components/high_fidelity_knob_slider.md)**   | Premium tactile knob with mathematical delta tracking and mechanical reel digits.                                                | Interaction     | **[lib/src/knob_slider](lib/src/knob_slider)**                                       |
| 11 | **[Card Stack Interaction](docs/components/card_stack_interaction.md)**         | Premium chronological card stack with symmetric expansion and high-fidelity transitions.                                         | Interaction     | **[lib/src/card_stack_interaction](lib/src/card_stack_interaction)**                 |
| 12 | **[Discrete Tabs](docs/components/discrete_tabs.md)**                           | Minimalist pill expanding tabs with aesthetic bounce, shimmer text, and managed state.                                           | Interaction     | **[lib/src/discrete_tabs](lib/src/discrete_tabs)**                                   |
| 13 | **[Split Button Interaction](docs/components/split_button_interaction.md)**     | Premium morphing action menu with synchronized action slide, elastic pop bounce, and motion blur emergence.                      | Navigation      | **[lib/src/split_button_interaction](lib/src/split_button_interaction)**             |
| 14 | **[Morphing Input Button](docs/components/morphing_input_button.md)**           | Premium button that morphs into a text input with a soft-focus reveal effect.                                                    | Interaction     | **[lib/src/morphing_input_button](lib/src/morphing_input_button)**                   |
| 15 | **[Scratch to Reveal](docs/components/scratch_to_reveal.md)**                   | High-fidelity physical scratching simulation to disclose hidden rewards.                                                         | Interaction     | **[lib/src/scratch_to_reveal](lib/src/scratch_to_reveal)**                           |
| 16 | **[Split to Edit](docs/components/split_to_edit.md)**                           | Premium duration picker that splits into editable segments with a bounce transition.                                             | Interaction     | **[lib/src/split_to_edit](lib/src/split_to_edit)**                                   |
| 17 | **[Modern Fractional Picker](docs/components/modern_fractional_picker.md)**     | Precision horizontal ruler for numeric input with support for integer/decimal steps and magnetic snapping.                       | Numeric Input   | **[lib/src/fractional_picker](lib/src/fractional_picker)**                           |
| 18 | **[Discovery Bar](docs/components/discovery_bar.md)**                           | Premium morphing search and discovery component with elastic containers and micro-scale interactions.                            | Interaction     | **[lib/src/discovery_bar](lib/src/discovery_bar)**                                   |
| 19 | **[Labeled Progress Indicator](docs/components/labeled_progress_indicator.md)** | Premium labeled progress indicator with tranquil transitions and customizable stages.                                            | Interaction     | **[lib/src/labeled_progress_indicator](lib/src/labeled_progress_indicator)**         |
| 20 | **[Quick Switcher](docs/components/quick_switcher.md)**                         | Premium togglable search bar with pulse animations and aesthetic input transitions.                                              | Interaction     | **[lib/src/quick_switcher](lib/src/quick_switcher)**                                 |
| 21 | **[Stacked Toast Interaction](docs/components/stacked_toast_interaction.md)**   | Premium chronological toast stack that appears from the top with high-fidelity transitions and symmetric stacking.               | Interaction     | **[lib/src/stacked_toast_interaction](lib/src/stacked_toast_interaction)**           |
| 22 | **[Disclosure Switch](docs/components/disclosure_switch.md)**                   | Premium switch that reveals additional nested content with a gradient track and smooth size animations.                          | Interaction     | **[lib/src/disclosure_switch](lib/src/disclosure_switch)**                           |
| 23 | **[Pinnable List](docs/components/pinnable_list.md)**                           | Premium dual-section list with Apple-style "flight" physics and dynamic self-measuring displacement animations.                  | Interaction     | **[lib/src/pinnable_list](lib/src/pinnable_list)**                                   |
| 24 | **[Todo List Interaction](docs/components/todo_list_interaction.md)**           | High-fidelity task management with concentric "Island" design and choreographed diagonal flight physics.                         | Interaction     | **[lib/src/todo_list_interaction](lib/src/todo_list_interaction)**                   |
| 25 | **[Slot Picker Interaction](docs/components/slot_picker_interaction.md)**       | Premium availability picker with spring physics, real-time collision detection, and smart validation.                            | Interaction     | **[lib/src/slot_picker_interaction](lib/src/slot_picker_interaction)**               |
| 26 | **[Tag Selection Interaction](docs/components/tag_selection_interaction.md)**   | Premium "Magic Move" tag selection with zero-dependency Apple-inspired spring physics and fluid wrapping.                        | Interaction     | **[lib/src/tag_selection_interaction](lib/src/tag_selection_interaction)**           |
| 27 | **[Collapsible Notify Panel](docs/components/collapsible_notify_panel.md)**     | Premium spring-based notification panel with staggered entry and header summaries.                                               | Layout          | **[lib/src/collapsible_notification_panel](lib/src/collapsible_notification_panel)** |
| 28 | **[Premium Stepper](docs/components/premium_stepper.md)**                       | Minimalist tactile stepper with mechanical flip animations and full layout customization.                                        | Numeric Input   | **[lib/src/premium_stepper](lib/src/premium_stepper)**                               |
| 29 | **[Premium Pagination](docs/components/premium_pagination.md)**                 | Tactile navigation with mechanical flip animations and automatic layout stability.                                               | Navigation      | **[lib/src/premium_pagination](lib/src/premium_pagination)**                         |
| 30 | **[Currency Swap](docs/components/currency_swap.md)**                           | Premium currency conversion interface with custom dropdowns and real-time flip counters.                                         | Interaction     | **[lib/src/currency_swap_interaction](lib/src/currency_swap_interaction)**           |
| 31 | **[Premium Progress Stepper](docs/components/premium_progress_stepper.md)**     | High-fidelity multi-step indicator with physics-based spring animations and tactile button feedback.                             | Interaction     | **[lib/src/premium_progress_stepper](lib/src/premium_progress_stepper)**             |
| 32 | **[Inline Delete Interaction](docs/components/inline_delete_interaction.md)**   | Premium interaction with inline destructive confirmation, glassmorphism, and staggered entrance.                                 | Interaction     | **[lib/src/inline_delete_interaction](lib/src/inline_delete_interaction)**           |
| 33 | **[Feedback Interaction](docs/components/feedback_interaction.md)**             | Premium physics-based feedback system with asymmetric spring morphing and liquid transitions.                                    | Interaction     | **[lib/src/feedback_interaction](lib/src/feedback_interaction)**                     |
| 34 | **[Loading Shapes](docs/components/loading_shapes.md)**                         | Premium physics-based loading indicator that morphs between organic and geometric shapes with subtle rotation.                   | Layout          | **[lib/src/loading_shapes](lib/src/loading_shapes)**                                 |
| 35 | **[Signature Draw Pad](docs/components/signature_draw_pad.md)**                 | Premium high-fidelity signature pad with playback animations, "Blur-Fade" transitions, and PNG export.                           | Interaction     | **[lib/src/signature_draw_pad](lib/src/signature_draw_pad)**                         |
| 36 | **[Sortable Grid](docs/components/sortable_grid.md)**                           | Physics-based reorderable grid with smooth layout transitions and haptic feedback.                                               | Layout          | **[lib/src/premium_sortable_grid](lib/src/premium_sortable_grid)**                   |
| 37 | **[Cinematic Text Transition](docs/components/cinematic_text_transition.md)**   | Sophisticated text transition with sequential character physics for premium headers.                                             | Interaction     | **[lib/src/cinematic_text_transition](lib/src/cinematic_text_transition)**           |
| 38 | **[Archive Folder](docs/components/archive_folder.md)**                         | Premium glassmorphic folder interaction with staggered item reveal and physics-based motion.                                     | Interaction     | **[lib/src/archive_folder](lib/src/archive_folder)**                                 |
| 39 | **[Folder Tabs](docs/components/folder_tabs.md)**                               | Physics-driven Manila file folder tab container with organic S-curves and dynamic proximity-based tab dissolving.                | Layout          | **[lib/src/folder_tabs](lib/src/folder_tabs)**                                       |
| 40 | **[Physics Collision Card](docs/components/physics_collision_card.md)**         | Interactive 2D physics simulation container. Drag and toss elements to collide elastically with boundaries.                      | Interaction     | **[lib/src/physics_collision_card](lib/src/physics_collision_card)**                 |
| 41 | **[Coverflow Carousel](docs/components/coverflow_carousel.md)**                 | Premium 3D Coverflow carousel with Y/X axis rotation, programmatic controllers, gestural controls, and dual-orientation support. | Interaction     | **[lib/src/coverflow_carousel](lib/src/coverflow_carousel)**                         |
| 42 | **[Stacked Cards](docs/components/stacked_cards.md)**                           | Premium gesture-driven stacked card carousel with horizontal swiping, spring snapping, and rotation.                             | Interaction     | **[lib/src/stacked_cards](lib/src/stacked_cards)**                                   |
| 43 | **[Quick Picker Interaction](docs/components/quick_picker_interaction.md)**     | Premium option selector dropdown with sliding segmented capsule, cinematic text sweep, and icon blur transitions.                | Interaction     | **[lib/src/quick_picker_interaction](lib/src/quick_picker_interaction)**             |
| 44 | **[Circular Color Picker](docs/components/circular_color_picker.md)**           | Premium circular color selector with spring-based center-bound sliding and smooth slide-back animations.                         | Interaction     | **[lib/src/circular_color_picker](lib/src/circular_color_picker)**                   |
| 45 | **[Slider Control](docs/components/slider_control.md)**                         | Premium vertical pill-shaped slider with a gradient fill, floating value badge, and snap mechanics.                              | Numeric Input   | **[lib/src/slider_control](lib/src/slider_control)**                                 |
| 46 | **[Score Gauge](docs/components/score_gauge.md)**                               | Animated semicircular gauge for credit/security scores with a sliding pointer and segmented strength indicator.                  | Status Display  | **[lib/src/score_gauge](lib/src/score_gauge)**                                       |

> 💡 **Tip:** Click on any component's name in the table above to view its live
> demonstration GIF, key features, and integration code snippet.

## Getting Started

Add `portal_labs` as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  portal_labs:
    path: ./ # Or your package location
```

Or run the following command:

```bash
flutter pub add portal_labs
```

---

## Contributing

Contributions focusing on performance optimization, new interaction patterns, or
accessibility improvements are welcome. Please ensure all submissions adhere to
the SDK-only dependency policy.
