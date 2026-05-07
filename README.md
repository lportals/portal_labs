# Portal Labs

A specialized collection of **high-performance, dependency-free** Flutter UI
components and advanced interactions. Built exclusively with vanilla Flutter and
Dart to ensure maximum portability and long-term stability.

[**🌐 Live Demo**](https://luisportal.com/labs)

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
  logic are centralized in [PortalUtils](/lib/src/common/portal_utils.dart) to
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

| #  | Component                                                     | Description                                                                                                        | Technical Scope | Location                                   |
| :- | :------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------- | :-------------- | :----------------------------------------- |
| 1  | **[Reveal &amp; Copy](#reveal--copy)**                        | Secure data masking with scramble reveal and clipboard animation.                                                  | Interaction     | `/lib/src/reveal_and_copy/`                |
| 2  | **[Modern Weight Picker](#modern-weight-picker)**             | Precision scrollable ruler with magnetic snapping and haptic feedback.                                             | Numeric Input   | `/lib/src/weight_picker/`                  |
| 3  | **[Premium Choice Chips](#premium-choice-chips)**             | Animated multi-selection system with flying media transitions.                                                     | Selection       | `/lib/src/premium_choice_chips/`           |
| 4  | **[Journal Navigation](#journal-navigation)**                 | Vertical date-based navigation with 3D flip counters and snapping transitions.                                     | Navigation      | `/lib/src/journal_navigation/`             |
| 5  | **[Card Splitting Accordion](#card-splitting-accordion)**     | Dynamic grouping interaction with physical splitting and variable corner radii.                                    | Layout          | `/lib/src/card_splitting_accordion/`       |
| 6  | **[Adaptive Slider](#adaptive-slider)**                       | Value-aware gradient slider with real-time color morphing.                                                         | Interaction     | `/lib/src/adaptive_slider_interaction/`    |
| 7  | **[Range Selection Slider](#range-selection-slider)**         | Premium bi-directional range selector with mechanical Odometer-style counters and manual input support.            | Selection       | `/lib/src/range_selection_slider/`         |
| 8  | **[Subscription Picker](#subscription-picker)**               | High-fidelity pricing selector with minimalist monthly/yearly toggle logic.                                        | Selection       | `/lib/src/subscription_pricing_picker/`    |
| 9  | **[Media Collapsible View](#media-collapsible-view)**         | Reels-inspired video background with dynamic collapsible interactive sheet.                                        | Interaction     | `/lib/src/media_collapsible_view/`         |
| 10 | **[High-Fidelity Knob Slider](#high-fidelity-knob-slider)**   | Premium tactile knob with mathematical delta tracking and mechanical reel digits.                                  | Interaction     | `/lib/src/knob_slider/`                    |
| 11 | **[Card Stack Interaction](#card-stack-interaction)**         | Premium chronological card stack with symmetric expansion and high-fidelity transitions.                           | Interaction     | `/lib/src/card_stack_interaction/`         |
| 12 | **[Discrete Tabs](#discrete-tabs)**                           | Minimalist pill expanding tabs with aesthetic bounce, shimmer text, and managed state.                             | Interaction     | `/lib/src/discrete_tabs/`                  |
| 13 | **[Split Button Interaction](#split-button-interaction)**     | Premium morphing action menu with synchronized action slide, elastic pop bounce, and motion blur emergence.        | Navigation      | `/lib/src/split_button_interaction/`       |
| 14 | **[Morphing Input Button](#morphing-input-button)**           | Premium button that morphs into a text input with a soft-focus reveal effect.                                      | Interaction     | `/lib/src/morphing_input_button/`          |
| 15 | **[Scratch to Reveal](#scratch-to-reveal)**                   | High-fidelity physical scratching simulation to disclose hidden rewards.                                           | Interaction     | `/lib/src/scratch_to_reveal/`              |
| 16 | **[Split to Edit](#split-to-edit)**                           | Premium duration picker that splits into editable segments with a bounce transition.                               | Interaction     | `/lib/src/split_to_edit/`                  |
| 17 | **[Modern Fractional Picker](#modern-fractional-picker)**     | Precision horizontal ruler for numeric input with support for integer/decimal steps and magnetic snapping.         | Numeric Input   | `/lib/src/fractional_picker/`              |
| 18 | **[Discovery Bar](#discovery-bar)**                           | Premium morphing search and discovery component with elastic containers and micro-scale interactions.              | Interaction     | `/lib/src/discovery_bar/`                  |
| 19 | **[Labeled Progress Indicator](#labeled-progress-indicator)** | Premium labeled progress indicator with tranquil transitions and customizable stages.                              | Interaction     | `/lib/src/labeled_progress_indicator/`     |
| 20 | **[Quick Switcher](#quick-switcher)**                         | Premium togglable search bar with pulse animations and aesthetic input transitions.                                | Interaction     | `/lib/src/quick_switcher/`                 |
| 21 | **[Stacked Toast Interaction](#stacked-toast-interaction)**   | Premium chronological toast stack that appears from the top with high-fidelity transitions and symmetric stacking. | Interaction     | `/lib/src/stacked_toast_interaction/`      |
| 22 | **[Disclosure Switch](#disclosure-switch)**                   | Premium switch that reveals additional nested content with a gradient track and smooth size animations.            | Interaction     | `/lib/src/disclosure_switch/`              |
| 23 | **[Pinnable List](#pinnable-list)**                           | Premium dual-section list with Apple-style "flight" physics and dynamic self-measuring displacement animations.    | Interaction     | `/lib/src/pinnable_list/`                  |
| 24 | **[Todo List Interaction](#todo-list-interaction)**           | High-fidelity task management with concentric "Island" design and choreographed diagonal flight physics.           | Interaction     | `/lib/src/todo_list_interaction/`          |
| 25 | **[Slot Picker Interaction](#slot-picker-interaction)**       | Premium availability picker with spring physics, real-time collision detection, and smart validation.              | Interaction     | `/lib/src/slot_picker_interaction/`        |
| 26 | **[Tag Selection Interaction](#tag-selection-interaction)**   | Premium "Magic Move" tag selection with zero-dependency Apple-inspired spring physics and fluid wrapping.          | Interaction     | `/lib/src/tag_selection_interaction/`      |
| 27 | **[Collapsible Notify Panel](#collapsible-notify-panel)**     | Premium spring-based notification panel with staggered entry and header summaries.                                 | Layout          | `/lib/src/collapsible_notification_panel/` |
| 28 | **[Premium Stepper](#premium-stepper)**                       | Minimalist tactile stepper with mechanical flip animations and full layout customization.                          | Numeric Input   | `/lib/src/premium_stepper/`                |
| 29 | **[Premium Pagination](#premium-pagination)**                 | Tactile navigation with mechanical flip animations and automatic layout stability.                                 | Navigation      | `/lib/src/premium_pagination/`             |
| 30 | **[Currency Swap](#currency-swap)**                           | Premium currency conversion interface with custom dropdowns and real-time flip counters.                           | Interaction     | `/lib/src/currency_swap_interaction/`      |
| 31 | **[Premium Progress Stepper](#premium-progress-stepper)**     | High-fidelity multi-step indicator with physics-based spring animations and tactile button feedback.               | Interaction     | `/lib/src/premium_progress_stepper/`       |
| 32 | **[Inline Delete Interaction](#inline-delete-interaction)** | Premium interaction with inline destructive confirmation, glassmorphism, and staggered entrance. | Interaction | `/lib/src/inline_delete_interaction/` |
| 33 | **[Feedback Interaction](#feedback-interaction)** | Premium physics-based feedback system with asymmetric spring morphing and liquid transitions. | Interaction | `/lib/src/feedback_interaction/` |
| 34 | **[Loading Shapes](#loading-shapes)** | Premium physics-based loading indicator that morphs between organic and geometric shapes with subtle rotation. | Layout | `/lib/src/loading_shapes/` |
| 35 | **[Signature Draw Pad](#signature-draw-pad)** | Premium high-fidelity signature pad with playback animations, "Blur-Fade" transitions, and PNG export. | Interaction | `/lib/src/signature_draw_pad/` |

---

### Reveal & Copy

![Reveal & Copy Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/reveal_and_copy.gif)

A specialized interaction designed for the secure presentation and acquisition
of sensitive data (e.g., credentials, financial accounts).

#### Key Features

- **Secure Masking**: Configurable character masking with an automated shimmer
  reveal effect.
- **Timed Visibility**: Automatic reversion to masked state after a defined
  duration for enhanced security.
- **Integrated Micro-interactions**: Smooth clipboard integration with visual
  feedback.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

RevealCopyInteraction(
  value: '4485 2291 0034 7516',
  onCopied: () => print('Data copied to clipboard'),
)
```

---

### Modern Weight Picker

![Weight Picker Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/weight_picker.gif)

A precision-engineered ruler interface for numeric input, optimized for tactile
feedback and high-accuracy selection.

#### Key Features

- **Custom-Painted Ruler**: High-resolution track with distinct major/minor
  increments.
- **Magnetic Snapping**: Centered alignment logic that snaps to the nearest
  precision point.
- **Low-Latency Feedback**: Real-time value synchronization optimized for 60fps
  interaction.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

ModernWeightPicker(
  initialValue: 75.0,
  onValueChanged: (weight) => print('Selection: $weight'),
)
```

---

### Premium Choice Chips

![Premium Choice Chips Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/premium_choice_chips.gif)

An engaging multi-selection component supporting diverse media types and dynamic
animated transitions.

#### Key Features

- **Media Agnostic**: Native support for Unicode emojis, Material icons, and
  custom images.
- **Kinetic Transitions**: Selection events trigger a "landing" animation with
  flying media particles.
- **Directional Counter**: Integrated Odometer-style counter for real-time
  selection tracking.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumChoiceChips(
  items: [
    ChoiceItem(label: 'Design', icon: Icons.palette_outlined),
    ChoiceItem(label: 'Coffee', emoji: '☕'),
  ],
  onSelectionChanged: (selected) => print('Selected count: ${selected.length}'),
)
```

---

### Journal Navigation

![Journal Navigation Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/journal_navigation.gif)

An aesthetic vertical navigation system designed for chronological content
exploration and high-end journal applications.

#### Key Features

- **Infinite Vertical Scroll**: Efficient scrolling logic supporting seamless
  date transitions.
- **Direction-Aware Flips**: 3D flip animations that indicate the scroll
  direction (past/future).
- **Modular Content Display**: Decoupled navigation logic allowing for any
  custom widget as the journal entry.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

JournalNavigation(
  items: [
    JournalItem(
      date: DateTime.now(),
      title: 'Project Inception',
      content: 'Core architecture finalized.',
    ),
  ],
  onDateChanged: (item) => print("Current view: ${item.title}"),
)
```

---

### Card Splitting Accordion

![Card Splitting Accordion Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/card_splitting_accordion.gif)

A sophisticated layout component where cards dynamically merge and separate
based on their expansion state.

#### Key Features

- **Physical Splitting Logic**: Cards appear to physically separate from a
  cohesive block into standalone units.
- **Phase-Shifted Rounding**: Independent interpolation of corner radii and
  displacement for a natural feel.
- **Adaptive Theme System**: Comprehensive style injection via the
  `AccordionStyle` configuration.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

CardSplittingAccordion(
  items: [
    AccordionItem(
      title: 'UX Strategy',
      content: 'Finalizing the vision for user-centered design systems.',
      icon: Icons.mouse_rounded,
    ),
  ],
)
```

---

### Adaptive Slider

![Adaptive Slider Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/adaptive_slider.gif)

A value-aware interaction component where the visual state adaptively morphs
based on input thresholds.

#### Key Features

- **Morphing Gradients**: Linear color interpolation across the track based on
  defined thresholds.
- **Contextual Indicators**: Dynamic indicator points that recalculate their
  state on every frame.
- **Gradient Typography**: Value labels share the adaptive gradient of the
  active track.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

AdaptiveSliderInteraction(
  value: _val,
  colorSteps: [
    AdaptiveColorStep(threshold: 0.0, colors: [Colors.blue, Colors.cyan]),
    AdaptiveColorStep(threshold: 1.0, colors: [Colors.red, Colors.orange]),
  ],
  onChanged: (val) => setState(() => _val = val),
)
```

---

### Range Selection Slider

![Range Selection Slider Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/range_slider.gif)

A high-end range selection component featuring a stylized slider and mechanical
3D counters with manual input support.

#### Key Features

- **Mechanical 3D Flip Counters**: Independent digit animations responding to
  range adjustments.
- **Manual Input Support**: Seamlessly transition from flip counters to manual
  text entry on tap.
- **Adaptive Formatting**: Built-in support for localized numeric formatting and
  currency symbols.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

RangeSelectionSlider(
  values: const RangeValues(640, 2380),
  onChanged: (values) => print("Range adjusted"),
)
```

---

### Subscription Picker

![Subscription Picker Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/subscription_picker.gif)

A high-fidelity pricing selection component designed for SaaS and modern
application subscription flows, fully integrated with the Portal Design System.

#### Key Features

- **Period Toggle**: Smooth, animated transition between billing periods (e.g.,
  Monthly/Yearly) using weighted physics.
- **Minimalist Cards**: Clean typography and selection states with animated
  toggles and premium border highlights.
- **Popular Badge & Haptics**: Built-in support for "Popular" badges and
  integrated haptic feedback for selection events.
- **Theme Aware**: Native support for light/dark modes via the `PortalTheme`
  system.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SubscriptionPricingPicker(
  monthlyPlans: [
    PricingPlan(id: 'free', title: 'Free', price: 0.0, periodText: 'month'),
    PricingPlan(id: 'starter', title: 'Starter', price: 9.99, periodText: 'month', isPopular: true),
  ],
  yearlyPlans: [
    PricingPlan(id: 'free_year', title: 'Free', price: 0.0, periodText: 'year'),
    PricingPlan(id: 'starter_year', title: 'Starter', price: 99.9, periodText: 'year', isPopular: true),
  ],
  onSelect: (plan, period) => print("Selected ${plan.title}"),
)
```

---

### Media Collapsible View

![Media Collapsible View Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/media_collapsible_view.gif)

A high-fidelity, Reels-inspired interaction component that transitions between a
full-screen media view and a detailed, gesture-driven interactive comment sheet.

#### Key Features

- **Fluid Coordinate Scaling**: Mathematical transition between full-frame and
  scaled-down media layouts using a shared stack architecture.
- **Dual-Phase Gesture Handling**: Integrated gesture handover between
  bottom-sheet dragging and internal list scrolling for a seamless "hand-off"
  feel.
- **Dynamic Blur Layering**: High-performance background blur layering that
  simulates real-time color bleeding without GPU overhead.
- **Zero-Dependency Media Builder**: Decoupled architecture using `mediaBuilder`
  to inject any video or interaction engine without adding external library
  debt.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

MediaCollapsibleView(
  mediaUrl: 'https://luisportal.com/assets/thumbnail.jpg', // Used for background blur
  userAvatarUrl: 'https://luisportal.com/assets/user_avatar.jpg',
  comments: [
    MediaComment(
      id: '1', 
      userName: 'portal_dev', 
      text: 'This UI interaction is absolutely stunning!', 
      avatarUrl: 'https://luisportal.com/assets/avatar.jpg', 
      createdAt: DateTime.now()
    ),
  ],
  style: MediaViewStyle(
    accentColor: Colors.blueAccent,
    sheetBackgroundColor: Color(0xFF141416),
  ),
  onSendComment: (text) => print('Comment: $text'),
)
```

---

### High-Fidelity Knob Slider

![Knob Slider Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/knob_slider.gif)

A production-ready, interactive dial with a hardware-inspired aesthetic and a
mechanical odometer-style numeric display.

#### Key Features

- **Mechanical Reel Animated Counter**: Odometer-style vertical scrolling for
  numbers with dynamic motion blur that scales with rotation velocity.
- **Delta-Based Rotation Logic**: High-fidelity gesture tracking that calculates
  relative angular changes, eliminating the "dead-zone" jump common in standard
  circular sliders.
- **3D Depth Perception**: Digits fade and tilt as they "rotate" through the 3D
  window, creating a tactile depth effect without external assets.
- **Fully Customizable Style**: Every aspect of the knob—from tick frequency and
  thickness to shadow depth and ring colors—is configurable via
  `KnobSliderStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

KnobSlider(
  value: _currentValue,
  min: 0,
  max: 100,
  step: 1,
  onChanged: (val) => setState(() => _currentValue = val),
  style: KnobSliderStyle(
    activeTickColor: Colors.blueAccent,
    knobScale: 0.6,
    totalTicks: 60,
  ),
)
```

---

### Card Stack Interaction

![Card Stack Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/card_stack.gif)

A premium, interactive card stack designed for chronological content, featuring
a minimal "deck" aesthetic and a high-fidelity symmetric expansion animation.

#### Key Features

- **Symmetric Center Expansion**: Cards expand outwards from the center of the
  stack with an elastic `easeOutBack` curve for a tactile "pop" effect.
- **Layered Stacking Logic**: A specialized 3-level visual hierarchy that hides
  extra items behind the stack until expanded, maintaining a clean interface.
- **Synchronized Transitions**: Integrated `AnimatedCrossFade` and
  `AnimatedRotation` for the action button, ensuring smooth layout shifts and
  icon turns.
- **Fully Themeable**: Comprehensive style injection via `CardStackStyle`
  allowing complete control over card dimensions, spacing, offsets, and colors.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

CardStackInteraction(
  items: [
    CardStackItem(
      title: 'Camping',
      subtitle: 'Yosemite Park',
      date: '5 August',
      icon: Icons.terrain_rounded,
    ),
    CardStackItem(
      title: 'Boating',
      subtitle: 'Lake Tahoe Park',
      date: '2 August',
      icon: Icons.directions_boat_rounded,
    ),
  ],
  style: CardStackStyle(
    cardHeight: 90.0,
    cardSpacing: 16.0,
    buttonBackgroundColor: Colors.white,
  ),
  onExpansionChanged: (isExpanded) => print('Stack is $isExpanded'),
)
```

---

### Discrete Tabs

![Discrete Tabs Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/discrete_tabs.gif)

A premium, zero-dependency minimalist navigation widget that expands like a pill
and features a subtle shimmer and slide effect on selection.

#### Key Features

- **Aesthetic Expansion**: High-fidelity bounce expansion curves transitioning
  seamlessly from a compact circle into a detailed pill.
- **Slide & Fade Shimmer**: Smooth linear gradient shimmer and sub-pixel slide
  interpolation that triggers elegantly across the label upon tab selection.
- **Controlled State**: Built with robust architecture offering both internal
  state for quick implementation and an external `currentIndex` for complete
  synchronization with other views.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

DiscreteTabs(
  currentIndex: _selectedPage, // Optional: for external control
  tabs: [
    DiscreteTab(
      label: 'Inbox',
      icon: Icons.mark_email_unread_rounded,
      activeColor: Color(0xFF007AFF),
    ),
    DiscreteTab(
      label: 'Planner',
      icon: Icons.grid_view_rounded,
      activeColor: Color(0xFFFF2D55),
    ),
  ],
  onSelect: (index) => setState(() => _selectedPage = index),
)
```

---

### Split Button Interaction

![Split Button Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/nested_pill_menu.gif)

A high-fidelity, zero-dependency action menu that seamlessly morphs from a
primary button into a horizontal navigation pill with synchronized
micro-animations.

#### Key Features

- **Dynamic Morphing Transition**: High-performance transformation from a
  primary action label into a back-navigation icon with a fluid, symmetric
  expansion.
- **Synchronized Action Slide**: Supplemental action items slide out from behind
  the main button with coordinated opacity, blur, and width interpolation.
- **Elastic Pop Bounce**: Symmetrical bidirectional "pop" effect upon menu
  closure, providing a tactile, hardware-inspired physical interaction.
- **Sophisticated Text Emergence**: High-end motion blur and clarify effect as
  the main label reappears during the closing transition, preventing visual
  artifacts.
- **Managed Controller API**: Built-in `SplitButtonController` for programmatic
  expansion, collapse, and toggle events.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SplitButtonInteraction(
  initialLabel: 'New Project',
  onBack: () => print('Menu collapsed'),
  actions: [
    SplitAction(
      label: 'iOS',
      icon: Icons.apple_rounded,
      onTap: () => print('Creating iOS project'),
      closeOnTap: true,
    ),
    SplitAction(
      label: 'Web',
      icon: Icons.language_rounded,
      onTap: () => print('Creating Web project'),
    ),
  ],
)
```

---

### Morphing Input Button

![Morphing Input Button Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/morphing_input_button.gif)

A high-fidelity interaction where a call-to-action button (e.g., "Notify Me")
seamlessly morphs into a text input field, featuring a premium soft-focus reveal
effect.

#### Key Features

- **Soft-Focus Reveal**: During the transition, the input text and placeholder
  gently blur (peak 1.5 sigma) and then come into perfect focus for a dreamy,
  high-end feel.
- **Aesthetic Expansion Curve**: Uses a specialized `easeOutBack` spring
  animation for the button-to-input morph.
- **Premium Flat Design**: Minimalist and shadow-free architecture (flat UI)
  that fits perfectly into modern high-end applications and design systems.
- **Fully Theme-Aware**: Automatically inherits colors and text styles from your
  `ThemeData`, with granular overrides for background and button colors.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

MorphingInputButton(
  buttonText: 'Notify Me',
  placeholder: 'Enter your email...',
  icon: Icons.notifications_rounded,
  onSubmitted: (email) => print('Subscribed: $email'),
  initialWidth: 140.0,
  expandedWidth: 320.0,
)
```

---

### Scratch to Reveal

![Scratch to Reveal Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/scratch_to_reveal.gif)

A high-fidelity interaction that simulates the physical act of scratching a
surface to reveal hidden content, optimized for rewards programs and
"surprise-and-delight" features.

#### Key Features

- **Layered Blend Modes**: Uses advanced mathematical clearing of a
  custom-painted layer to reveal content in high-performance stacks.
- **Tactile Textures**: Features a procedurally generated diagonal grid pattern
  on the surface to mimic the appearance of physical scratch cards.
- **Intelligent Auto-Reveal**: Tracks scratch coverage and automatically fades
  out the remaining surface once a configurable success threshold is reached.
- **Integrated Action Header**: Includes a premium card layout with a brandable
  header and a smooth "Start again" reset mechanism.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

ScratchToReveal(
  title: 'Apple Credits',
  icon: Icons.apple_rounded,
  child: Center(
    child: Text(
      'You won \$24',
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    ),
  ),
  onCompleted: () => print('Reward revealed!'),
)
```

---

### Split to Edit

![Split to Edit Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/split_to_edit.gif)

A premium duration picker that "splits" from a unified view into separate
editable segments with a high-fidelity bounce transition.

#### Key Features

- **Bounce Split Transition**: Uses a specialized `ElasticOutCurve` to create a
  tactile "splitting" effect.
- **Segmented Morphing**: Backgrounds and corner radii dynamically interpolate
  between unified and standalone states.
- **Haptic Integration**: Subtle selection and impact haptics provide a premium
  "mechanical" feel.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SplitToEditDuration(
  hours: 1,
  minutes: 42,
  onChanged: (h, m) => print('New time: $h:$m'),
)
```

---

### Modern Fractional Picker

![Fractional Picker Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/fractional_picker.gif)

A high-fidelity horizontal ruler for precise numeric selection. Features
predictive magnetic snapping, customizable physics, and high-performance
rendering.

#### Key Features

- **Predictive Snap Landing**: Calculates the natural landing spot based on
  velocity and snaps to the nearest integer/decimal.
- **Customizable Physics**: Exposes `friction` and `snapStiffness` for a
  tailored tactile feel.
- **Performance Optimized**: Uses `AnimatedBuilder` and local painting cache for
  constant 60/120 FPS.
- **Haptic Precision**: Integrated selection haptics that fire exactly as the
  ruler crosses threshold points.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

ModernFractionalPicker(
  initialValue: 18.0,
  minValue: 0.0,
  maxValue: 100.0,
  decimalPlaces: 0,
  onValueChanged: (val) => print('Selected: $val'),
  style: FractionalPickerStyle(
    activeColor: Color(0xFF1D1D1F),
    friction: 0.22,
    snapStiffness: 100.0,
  ),
)
```

---

### Discovery Bar

![Discovery Bar Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/discovery_bar.gif)

A premium morphing search and discovery component that transitions between
discovery categories and a search input with fluid, elastic containers.

#### Key Features

- **Morphing Containers**: Dual containers that physically expand and shrink in
  place for a seamless transition.
- **Micro-Bounce Physics**: Custom-tuned cubic curves with 10% overshoot for a
  premium tactile feel.
- **Micro-Scale Interactions**: High-performance tap feedback on all text and
  icons for a "bouncy" experience.
- **Zero-Dependency Semantic Support**: Intelligent focus management and
  Material semantics without third-party debt.

#### Integration

```dart
DiscoveryBar(
  options: const [
    DiscoveryOption(label: 'Popular', icon: Icons.local_fire_department_rounded),
    DiscoveryOption(label: 'Favorites', icon: Icons.favorite_rounded),
  ],
  onOptionSelected: (option) => print('Selected: ${option.label}'),
  onSearchSubmitted: (query) => print('Searching for: $query'),
)
```

---

### Labeled Progress Indicator

![Labeled Progress Indicator Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/labeled_progress_indicator.gif)

A production-ready, high-fidelity progress indicator designed for sequential
loading flows (onboarding, processing) with a focus on tranquil label
transitions.

#### Key Features

- **Dynamic Stage Management**: Support for `ProgressStage` objects allowing for
  non-uniform loading thresholds and custom labels.
- **Tranquil Transitions**: Labels enter/exit using a sophisticated combination
  of **Skew-X**, **Motion Blur**, and **Elastic Bounce** for a premium
  "air-focus" feel.
- **Size-Independent Shimmer**: A global-coordinate shimmer system that remains
  consistent in speed and scale regardless of the progress bar width.
- **Robust State Handling**: Integrated support for `onComplete` callbacks and
  customizable `isError` states with fallback labels.
- **Deep Customization**: Fully configurable typography, shimmer colors, height,
  and optional percentage display via `LabeledProgressIndicatorStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

LabeledProgressIndicator(
  progress: _currentProgress,
  stages: [
    ProgressStage(label: 'Consulting', endProgress: 0.1),
    ProgressStage(label: 'Processing', endProgress: 0.8),
    ProgressStage(label: 'Completed', endProgress: 1.0),
  ],
  onComplete: () => print('Done!'),
  isError: _hasFailed,
  errorLabel: 'Connection timed out',
  style: LabeledProgressIndicatorStyle(
    progressColor: Color(0xFF007AFF),
    shimmerColor: Color(0xFF00FBFF),
  ),
)
```

---

### Quick Switcher

![Quick Switcher Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/quick_switcher.gif)

A premium, high-fidelity switch component that toggles between different input
modes with a pulse animation and smooth decorative transitions.

#### Key Features

- **Pulse Animation Engine**: Generates a synchronized scale and opacity pulse
  on the switch trigger for tactical feedback.
- **Smooth Morph Transitions**: Uses high-performance `AnimatedSwitcher` for
  sub-pixel interpolation of icons and hint text.
- **Adaptive Theme System**: Supports both light and dark aesthetics via the
  `QuickSwitcherStyle` configuration.
- **Haptic Integration**: Built-in specialized haptics for a "mechanical" click
  feel.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

QuickSwitcher(
  options: [
    QuickSwitcherOption(
      label: 'Ask Anything',
      icon: Icons.auto_awesome_rounded,
      placeholder: 'Ask Anything',
    ),
    QuickSwitcherOption(
      label: 'Generate Image',
      icon: Icons.image_rounded,
      placeholder: 'Generate Image',
    ),
  ],
  onOptionChanged: (index) => print('Switched to: $index'),
  onSubmitted: (feedback) => print('Feedback: $feedback'),
)
```

---


### Stacked Toast Interaction

![Stacked Toast Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/interaction_toast.gif)

Individual toasts that arrive from the top and stack behind each other when
multiple notifications are active, featuring high-fidelity transitions and
professional aesthetics.

#### Key Features

- **Professional Top Arrival**: Toasts slide down from the top edge using a
  refined `easeOutCubic` curve for a native system-like feel.
- **Intelligent 3D Stacking**: Previous toasts are pushed back into a
  multi-layered stack with symmetric scaling and opacity to focus on the active
  alert.
- **Action Callbacks & Labels**: Support for interactive buttons with custom
  labels (`actionLabel`) and logic (`onAction`), supporting flows like "Retry"
  or "Undo".
- **Total UI Builder**: A `builder` property allows for 100% custom toast
  layouts while inheriting the physics and stacking logic.
- **Granular Customization**: Full control over icons, typography (`TextStyle`),
  colors, and shapes at both a global and individual level.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

// 1. Initialize the controller
final _toastController = StackedToastController();

// 2. Place the interaction widget (usually at the root Stack or Scaffold)
StackedToastInteraction(
  controller: _toastController,
  style: StackedToastStyle(
    topMargin: 10.0, // Precise alignment relative to the notch
  ),
)

// 3. Trigger a high-fidelity toast
_toastController.show(
  StackedToastItem(
    id: DateTime.now().toString(),
    title: 'New Suggestion',
    message: 'Optimization tips are available.',
    type: StackedToastType.info,
    actionLabel: 'View',
    onAction: () => print('Opening tips...'),
  ),
);
```

---

### Disclosure Switch

![Disclosure Switch Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/switch_disclosure.gif)

A premium, high-fidelity switch component that "discloses" or reveals additional
content when toggled on, featuring a unique "Island" design and an
elastic-bounce interaction pattern.

#### Key Features

- **Island Header Design**: The primary control is wrapped in a concentric grey
  inset card, separated by 2px from the main border for a high-end "layered"
  look.
- **Elastic Bounce Animation**: Uses `Curves.easeOutBack` to create a physical
  inertia effect where inner items slide and bounce into place independently of
  the container.
- **Context-Aware Geometry**: The main border and shadows are dynamic—appearing
  only when the section is active to maintain a clean, minimal UI in the idle
  state.
- **Pixel-Perfect Alignment**: Internal offsets are meticulously calculated to
  ensure sub-options (like checkboxes) align perfectly with the header icon's
  axis.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

DisclosureSwitch(
  title: 'Advanced Suggestions',
  value: _isAdvancedEnabled,
  onChanged: (val) => setState(() => _isAdvancedEnabled = val),
  icon: Icon(Icons.tune_rounded, color: Color(0xFF8E8E93)),
  revealedChild: Column(
    children: [
      _buildSubOption('Inline Suggestions', true),
      _buildSubOption('Auto-correct words', false),
      _buildSubOption('Smart Replies', true),
    ],
  ),
)
```

---

### Pinnable List

![Pinnable List Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/pinnable_list.gif)

A high-fidelity, zero-dependency list component that manages "Pinned" and "All"
sections with a seamless Apple-style displacement animation.

#### Key Features

- **Self-Measuring Architecture**: Automatically measures item heights for
  pixel-perfect coordinates without hardcoded constants.
- **Spring Flight Physics**: Items physically slide ("fly") across the whole
  list with authentic inertia and a subtle elevation scale effect.
- **Smart Section Hand-off**: Integrated logic that transitions items between
  sections while maintaining a persistent Z-index for the "traveling" card.
- **Customizable Style**: Granular control over section headers, count badges,
  spacing, and sorting criteria via `PinnableListStyle` and `itemComparator`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PinnableList(
  items: [
    PinnableItem(id: '1', title: 'Work', icon: Icons.work_rounded),
    PinnableItem(id: '2', title: 'Personal', icon: Icons.person_rounded),
  ],
  onPinChanged: (id, isPinned) => print('Item $id pin state: $isPinned'),
)
```

---

### Todo List Interaction

![Todo List Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/to_do_list_interaction.gif)

A high-fidelity task management component featuring a sophisticated "concentric
island" design, sliding spring segmented controls, and choreographed diagonal
"flight" animations for task completion.

#### Key Features

- **Concentric Island Aesthetic**: Multi-layered design with the date title
  perfectly centered in the outer container and tasks strictly contained within
  a white interactive island.
- **Choreographed Flight Physics**: Completing a task triggers a 3-stage visual
  event: (1) Lateral horizontal shift, (2) State toggle, and (3) Diagonal flight
  to its new position in the completed section.
- **Morphing Segmented Control**: A custom 3-tab filter (To-do, Completed,
  Pending) where the active bubble elastically morphs and slides using
  high-performance physics.
- **Independent Animation Cycles**: Supports rapid-fire user interactions;
  multiple tasks can fly simultaneously without interrupting each other's
  transition paths.
- **Fully Theme-Aware**: Every aspect including background colors, radii,
  spacing, localization filters, and spring stiffness is configurable via
  `TodoListStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

TodoListInteraction(
  dateString: 'Apr 17, Friday',
  categories: [
    TodoCategory(id: 'work', title: 'Work'),
  ],
  items: [
    TodoItem(id: '1', categoryId: 'work', title: 'Finish UI Component'),
    TodoItem(id: '2', categoryId: 'work', title: 'Code Review', isCompleted: true),
  ],
  onChanged: (updatedItems) => print('Task list updated'),
)
```

---

### Slot Picker Interaction

![Slot Picker Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/slot_picker_interaction.gif)

A premium, production- ready scheduling component that combines smooth spring
physics with a robust validation engine for professional availability
management.

#### Key Features

- **Collision Detection Engine**: Automatically identifies and highlights
  overlapping time slots with a subtle reddish background and border highlight,
  preventing data entry errors without breaking the flow.
- **Smart Validation**: Intelligent auto-correction that maintains logical
  ranges (e.g., automatically adjusting End Time when Start Time is moved beyond
  it) based on a configurable `validationInterval`.
- **Adaptive UI**: Context-aware time pickers that provide a native
  `CupertinoDatePicker` on iOS/macOS and a sleek Material `showTimePicker` on
  other platforms, both synchronized with the slot interval.
- **Physics-Based Motion**: High-fidelity expansion and removal animations using
  spring simulations for a tactile, "bouncy" feel that feels rooted in physical
  reality.
- **Total Customization**: 15+ style properties in `SlotPickerStyle` covering
  granular typography, specific action colors (delete button), and adjustable
  paddings for perfect layout balancing.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SlotPickerInteraction(
  items: [
    SlotPickerItem(title: 'Monday', slots: [
      SlotRange(startTime: TimeOfDay(hour: 9, 0), endTime: TimeOfDay(hour: 17, 0)),
    ]),
  ],
  validationInterval: Duration(minutes: 30),
  enableOverlapDetection: true,
  style: SlotPickerStyle(
    activeSwitchColor: Colors.deepPurple,
    borderRadius: BorderRadius.circular(18),
  ),
  onSlotChanged: (index, range) => print('Updated slot $index'),
)
```

---

### Tag Selection Interaction

![Tag Selection Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/tag_selection.gif)

A premium, zero-dependency "Magic Move" tag selection component that uses 100%
custom, Apple-inspired spring physics to animate tags seamlessly between
available and selected states.

#### Key Features

- **Apple Spring Simulator**: Replicates native IOS bounce and flight effects
  using a heavily damped harmonic oscillator (`_AppleSpringCurve`) without any
  external dependencies.
- **Fluid Wrap Engine**: Actively self-measures tags and calculates relative
  `Wrap` coordinates on-the-fly, allowing tags to physically fly between
  structured flowing layouts.
- **True Natural Sizing**: Bypasses conventional layout constraints by measuring
  system `TextScaler` rendering metrics to ensure pixel-perfect accessibility
  support without clipping.
- **High-Contrast Theming**: Beautiful dark/light active states featuring subtle
  drop shadows and premium typography transitions.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

TagSelectionInteraction(
  allTags: [
    TagModel(id: 'react', label: 'React'),
    TagModel(id: 'flutter', label: 'Flutter'),
  ],
  initialSelectedIds: const {'flutter'},
  onChanged: (selectedIds) => print('Selection updated: $selectedIds'),
  selectedTitle: 'YOUR STACK',
)
```

---

### Collapsible Notification Panel

![Collapsible Notification Panel Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/collapsible_notification.gif)

A premium, highly interactive notification panel that can collapse into a
summary header and expand to show a list of activities with spring-based
animations.

#### Key Features

- **Spring Physics Animation**: Natural, momentum-based expansion and collapse
  transitions.
- **Staggered Entry**: Each notification item animates in with a calculated
  delay for a high-end polished feel.
- **Header Summary**: Displays a clean "X New Activities" header with a subtitle
  when collapsed.
- **Interactive Haptics**: Responsive scale effects on all pressable elements
  (`scale(0.97)`).
- **Concentric 'Island' Design**: Premium structural layout with
  glassmorphism-inspired layering and refined typography.
- **Fully Themeable Architecture**: Complete control over colors, gradients,
  typography, and physics via the `CollapsibleNotificationPanelStyle` object.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

CollapsibleNotificationPanel(
  items: [
    NotificationItem(
      id: '1',
      title: 'Diego Sent a Message',
      description: '"Hey! Did you check the new spring animations?"',
      timestamp: 'Just Now',
      icon: Icons.chat_bubble_rounded,
    ),
    NotificationItem(
      id: '2',
      title: 'Upcoming Event',
      description: 'Daily Sync starts in 15 minutes.',
      timestamp: '15m ago',
      icon: Icons.calendar_month_rounded,
    ),
  ],
  onItemTap: (item) => print('Tapped: ${item.title}'),
)
```

---

### Premium Stepper

![Premium Stepper Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/stepper_interaction.gif)

A minimalist tactile stepper component utilizing mechanical flip animations and
haptic feedback.

#### Key Features

- **Mechanical Odometer Counter**: Integrated `PremiumFlipCounter` for fluid
  numerical transitions.
- **Tactile Buttons**: Circular action buttons with scale-down feedback.
- **Haptic Integration**: Light-impact haptic feedback on value changes.
- **Minimalist Design**: Pill-shaped container with clean typography.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumStepper(
  value: _count,
  onChanged: (val) => setState(() => _count = val),
)
```

---

### Premium Pagination

![Premium Pagination Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/pagination_interaction.gif)

A premium, highly customizable navigation component with mechanical flip
animations and automatic layout stability.

#### Key Features

- **Mechanical Flip Counter**: Integrated `PremiumFlipCounter` for fluid,
  odometer-style page transitions.
- **Automatic Layout Stability**: Intelligent column width calculation based on
  total pages to prevent jumping.
- **Tactile Feedback**: Interactive buttons with `0.95x` scale feedback and
  integrated light-impact haptics.
- **Total Design Freedom**: Fully customizable style including
  `buttonBorderRadius`, `padding`, `borderWidth`, and arbitrary icons.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumPagination(
  currentPage: _currentPage,
  totalPages: 10,
  onPageChanged: (page) => setState(() => _currentPage = page),
)
```

---

### Currency Swap

![Currency Swap Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/swap_currency.gif)

A premium currency conversion interface with custom dropdowns, real-time
conversion displays using mechanical flip counters, and high-fidelity
micro-interactions.

#### Key Features

- **Custom Dropdown Menu**: High-performance overlay menu with flag support and
  selection checkmarks.
- **Mechanical Flip Counter**: Real-time conversion feedback using the
  `PremiumFlipCounter` engine.
- **Tactile Feedback**: Proceed button with scale-down feedback (0.98x) and
  integrated light-impact haptics.
- **Design Fidelity**: Strictly follows the provided light-themed design without
  unrequested variations.
- **Total Design Freedom**: Fully customizable style including typography,
  colors, borders, and spacing via `CurrencySwapStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

final currencies = [
  Currency(code: 'USD', flag: '🇺🇸', name: 'US Dollar'),
  Currency(code: 'EUR', flag: '🇪🇺', name: 'Euro'),
];

CurrencySwapInteraction(
  currencies: currencies,
  initialFromCurrency: currencies[0],
  initialToCurrency: currencies[1],
  onProceed: () => print('Converting...'),
)
```

---

### Premium Progress Stepper

![Premium Progress Stepper Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/progress_step.gif)

A high-fidelity progress stepper designed for multi-step flows, featuring
physics-driven indicator animations and tactile button feedback.

#### Key Features

- **Spring-Driven Indicator**: A stretching pill animation that connects steps
  using real-world physics for a natural, "alive" feel.
- **Dynamic Navigation**: Automatically handles "Back" button visibility with a
  bounce entry after the first step.
- **Tactile Feedback**: Integrated button scale feedback and multi-level haptics
  for a premium mechanical sensation.
- **Dynamic Text States**: Smooth cross-fading of button labels (e.g.,
  "Continue" to "Finish") with synchronized icon transitions.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumProgressStepper(
  totalSteps: 3,
  currentStep: _currentStep,
  onStepChanged: (step) => setState(() => _currentStep = step),
  onFinish: () => print('Flow Completed!'),
  style: PremiumProgressStepperStyle(
    activeColor: Color(0xFF22C55E),
    primaryButtonColor: Color(0xFF007AFF),
  ),
)
```

---

### Inline Delete Interaction

![Inline Delete Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/inline_delete.gif)

A premium interaction component featuring a high-fidelity inline destructive confirmation flow that transitions vertically while maintaining structural stability.

#### Key Features

- **Inline Confirmation Flow**: A specialized interaction where a destructive action transforms vertically into a confirmation state using physics-based transitions.
- **Physics-Based Transitions**: Uses `SpringSimulation` to achieve a tactile, elastic "bounce" during confirmation flows.
- **Staggered Entry**: Built-in support for orchestrated item reveal animations via external controllers.
- **Geometric Harmony**: Automatically calculates concentric corner radii based on container padding for a premium, hardware-inspired aesthetic.
- **Flexible & Context-Agnostic**: Pure widget architecture that can be embedded in any container (modals, sheets, or inline lists) without managing complex overlays internally.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

InlineDeleteInteraction(
  title: 'More Options',
  onCloseRequested: () => Navigator.pop(context),
  items: [
    InlineAction(
      title: 'Edit',
      icon: Icons.edit_outlined,
      onTap: () => print('Edit action'),
    ),
    InlineAction(
      title: 'Delete',
      icon: Icons.delete_outline,
      isDestructive: true,
      confirmLabel: 'Delete Now',
      onTap: () => print('Delete confirmed'),
    ),
  ],
  style: InlineDeleteStyle(
    rowHeight: 52,
    enableHaptics: true,
  ),
)
```

---

### Feedback Interaction

![Feedback Interaction Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/feedback_interaction.gif)

A premium, high-fidelity feedback component that uses asymmetric spring physics to transition between selection states. Designed for high-fidelity tactile response and zero-latency interaction.

#### Key Features

- **Elastic Spring Physics**: Powered by a custom `SpringSimulation` engine that supports natural overshoots and interruptible motion.
- **Asymmetric Transitions**: Distinct physical parameters for opening and closing (Undo) states to provide a "magnetic" and stable return.
- **Geometric Harmony**: A specialized morphing architecture where buttons perfectly track the container's expansion, eliminating jitter and alignment drift.
- **Zero-Latency Reset**: Smart early-interactivity logic restores touch responsiveness before the physics fully settle.
- **Total Customization**: 15+ customizable properties via `FeedbackInteractionStyle`, including stiffness, damping, and blur intensity.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

FeedbackInteraction(
  message: 'Thanks for your feedback!',
  onPositive: () => print('Positive feedback'),
  onNegative: () => print('Negative feedback'),
  onUndo: () => print('Action undone'),
  style: FeedbackInteractionStyle(
    springStiffness: 240.0,
    springDamping: 18.0,
    enableHaptics: true,
  ),
)
```

### Loading Shapes

![Loading Shapes Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/loading_shapes.gif)

A premium loading indicator that morphs between organic and geometric shapes with subtle rotational transitions and high-fidelity path interpolation.

#### Key Features

- **Dynamic Path Morphing**: High-fidelity path interpolation engine using 120-point vertex arrays for perfectly fluid shape-shifting.
- **Organic & Geometric States**: Fully customizable shape sequences using `PortalShapeDefinition` to define sides, smoothness, and radius ratios.
- **Momentum Rotation Engine**: Frame-perfect `Ticker`-based rotation that adds a physical "kick" of speed during transitions, avoiding resets or jumps.
- **Total Design Freedom**: Fully customizable colors, sizes, transition speeds, and wait times via `LoadingShapesStyle`.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

LoadingShapes(
  isLoading: true,
  style: LoadingShapesStyle(
    size: 140.0,
    color: Color(0xFF1D1D1F),
    transitionDuration: Duration(milliseconds: 800),
    baseRotationSpeed: 0.007,
    boostRotationSpeed: 0.02,
    pauseDuration: Duration(milliseconds: 400),
    shapes: [
      PortalShapeDefinition(sides: 5, smoothness: 0.4),
      PortalShapeDefinition(sides: 8, innerRadiusRatio: 0.6),
    ],
  ),
)
```

#### Custom Shapes & Geometry

The `PortalShapeDefinition` allows you to programmatically define any geometric or organic state for the morphing sequence:

| Parameter          | Description                                                                                          | Visual Effect                                     |
| :----------------- | :--------------------------------------------------------------------------------------------------- | :------------------------------------------------ |
| `sides`            | The number of vertices or peaks.                                                                     | 3 = Triangle, 4 = Square, 1 = Teardrop.           |
| `innerRadiusRatio` | Ratio between inner and outer points (0.0 to 1.0).                                                   | 1.0 = Polygon, 0.5 = Sharp Star, 0.2 = Needle.    |
| `smoothness`       | Blending between rigid geometry and organic blobs (0.0 to 1.0).                                      | 0.0 = Sharp edges, 1.0 = Liquid/Organic flow.     |

**Pro Tip:** To create a perfect circle morph, use a high `sides` count (e.g., 60) with `smoothness: 1.0`.

---

### Signature Draw Pad

![Signature Draw Pad Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/signature.gif)

A high-fidelity signature drawing component designed for professional applications requiring document integrity and a premium interaction feel.

#### Key Features

- **Signature Playback**: Integrated playback engine that re-draws the signature with adjustable duration and shimmer effects.
- **Off-Screen Export Engine**: Programmatic high-resolution PNG generation with automatic centering and aspect-ratio scaling via the controller.
- **Document Integrity Lock**: Automatically disables the canvas and hides editing tools once confirmed to ensure signature integrity.
- **Fluid State Transitions**: High-end state transitions for the confirmation flow using smooth blur dissolves and spring physics.
- **Customizable Color Palette**: Full control over palette colors with reactive state management that updates all existing strokes.

#### Integration

```dart
import 'package:portal_labs/portal_labs.dart';

SignatureDrawPad(
  label: 'Authorize Transaction',
  onConfirm: () async {
    final image = await _controller.toImage(width: 800, height: 400);
    print('Signature captured as image');
  },
  style: SignatureDrawPadStyle(
    activeColor: Colors.black,
    confirmButtonText: 'MANTÉN PARA FIRMAR',
  ),
)
```

---

## Contributing

Contributions focusing on performance optimization, new interaction patterns, or
accessibility improvements are welcome. Please ensure all submissions adhere to
the SDK-only dependency policy.
