# 🧪 Portal Labs

A curated collection of **premium, zero-dependency** Flutter UI components and experimental interactions. Built with 100% vanilla Flutter/Dart.

## 🚀 The "Zero-Dependency" Promise

Every component in this repository is built using only the core Flutter and Dart libraries. 
- **No `intl`**: Manual date logic and formatting centralized in `PortalUtils`.
- **No `lucide_icons` or `font_awesome`**: Uses standard Material Design rounded icons.
- **No `google_fonts`**: Uses system default fonts for zero-latency, native performance.
- **No `animations` package**: All physics and transitions are built with `AnimationController` and `Tween`s.

To maintain scalability without external bloat, we use [PortalUtils](/lib/src/common/portal_utils.dart), a lightweight internal utility for text measurement, date formatting, and spacing.

This makes every component **instantly copy-pasteable** into any Flutter project without adding bloat or versioning conflicts.

## 📖 Component Library

A pub.dev-ready package of premium UI components. Install via `flutter pub add portal_labs` or copy individual components into your project.

| Component | Description | Complexity | Location |
|-----------|-------------|------------|----------|
| **[Reveal & Copy](#-reveal--copy)** | Secure scramble reveal for sensitive data with copy-to-clipboard animation. | Low | `/lib/src/reveal_and_copy/` |
| **[Modern Weight Picker](#-modern-weight-picker)** | Precision scrollable ruler with haptic feedback and magnetic snapping. | Low-Mid | `/lib/src/weight_picker/` |
| **[Premium Choice Chips](#-premium-choice-chips)** | Animated selection with flip counter and flying media transitions. | Mid | `/lib/src/premium_choice_chips/` |
| **[Journal Navigation](#-journal-navigation)** | Aesthetic daily entries with a vertical scroller, 3D flip counter, and snapping. | Mid-High | `/lib/src/journal_navigation/` |
| **[Card Splitting Accordion](#-card-splitting-accordion)** | Magnetic grouping interaction where items split into standalone cards. | High | `/lib/src/card_splitting_accordion/` |
| **[Adaptive Slider](#-adaptive-slider)** | Dynamic gradient slider with real-time value morphing and adaptive track. | Mid | `/lib/src/adaptive_slider_interaction/` |

---

### 🔒 Reveal & Copy

![Reveal & Copy Showcase](./docs/gifs/reveal_and_copy.gif)

A premium interaction designed for safely displaying and copying sensitive information like credit card numbers, passwords, or API keys. 

#### Features
- **Secure by Default:** Values are masked with a custom character (defaults to '×').
- **Elegant Animations:** Smooth scramble reveal effect and a premium shimmer pass upon revealing.
- **Auto-Hide:** Automatically reverts to a masked state after a configurable duration.
- **Micro-interactions:** Integrated copy-to-clipboard functionality with animated visual feedback.

#### Usage

1. Add the package: `flutter pub add portal_labs`
2. Use the widget:

```dart
import 'package:portal_labs/portal_labs.dart';

RevealCopyInteraction(
  value: '4485 2291 0034 7516',
  onCopied: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied successfully!')),
    );
  },
)
```

---

### ⚖️ Modern Weight Picker

![Weight Picker Showcase](./docs/gifs/weight_picker.gif)

A sleek, precision-focused ruler input for numeric values, perfect for fitness apps or physical measurements.

#### Features
- **Precision Ruler:** Custom-painted interactive ruler with major and minor increments.
- **Magnetic Snapping:** Smooth snapping to the nearest value for a tactile feel.
- **Dynamic Feedback:** Real-time value updates as the user scrolls.
- **Premium Styling:** Gradient-based highlighting and modern typography.

#### Usage

1. Add the package: `flutter pub add portal_labs`
2. Use the widget:

```dart
import 'package:portal_labs/portal_labs.dart';

ModernWeightPicker(
  initialValue: 75.0,
  onValueChanged: (weight) {
    print('Current weight: $weight');
  },
)
```

---

### 🎨 Premium Choice Chips

![Premium Choice Chips Showcase](./docs/gifs/premium_choice_chips.gif)

A playful and engaging interaction component for selections, featuring high-end animations and multi-media support (Emojis, Icons, and Images).

#### Features
- **Multi-media Support:** Use text emojis, Flutter icons, or network/asset images as items.
- **Flying Media Animation:** When an item is selected, a pyramid of 3 media elements (emoji/icon/image) flies up and "lands" in the counter.
- **3D Flip Counter:** An odometer-style flip animation for counting selections.
- **Customizable Labels:** Easily change button labels (e.g., "Interest" vs "Interests").

#### Usage

1. Add the package: `flutter pub add portal_labs`
2. Use the widget:

```dart
import 'package:portal_labs/portal_labs.dart';

PremiumChoiceChips(
  items: [
    ChoiceItem(label: 'Design', icon: Icons.palette_outlined), // Material support
    ChoiceItem(label: 'Coffee', emoji: '☕'),               // Emoji support
  ],
  onSelectionChanged: (selected) {
    print('Selected: ${selected.length} items');
  },
)
```

---

### 📔 Journal Navigation

![Journal Navigation Showcase](./docs/gifs/journal_navigation.gif)

A premium, aesthetic interaction designed for daily logging or historical views. Features a vertical date slider on the left and a content area on the right with smooth animations and transitions.

#### Features
- **Vertical Date Scroller:** A minimal white-pill scroller with infinite support for months and days.
- **Magnetic Snapping:** Smooth snapping physics that centers the selected date automatically.
- **3D Flip Counter:** An odometer-style flip animation for the day number, indicating direction (past/future).
- **Custom Child Support:** Replace the default title/content with any complex widget (Images, Charts, Videos).
- **Style Injection:** Fully customizable via `JournalStyle` (colors, borders, shadows, typography).
- **Smooth Content Transitions:** Fade and slide animations when switching journal entries.

#### Usage

1. Add the package: `flutter pub add portal_labs`
2. Use the widget:

```dart
import 'package:portal_labs/portal_labs.dart';

JournalNavigation(
  items: [
    // Standard text entry
    JournalItem(
      date: DateTime.now(),
      title: 'A day for deep focus 🧠',
      content: 'Taking long walks and letting my mind wander.',
    ),
    // Custom widget entry
    JournalItem(
      date: DateTime.now().add(const Duration(days: 1)),
      child: Column(
        children: [
          Image.network('https://...'),
          const Text('Custom Media Day'),
        ],
      ),
    ),
  ],
  initialDate: DateTime.now(),
  onDateChanged: (item) => print("Selected: ${item.title}"),
)
```

---

### 🗂️ Card Splitting Accordion

![Card Splitting Accordion Showcase](./docs/gifs/card_splitting_accordion.gif)

A high-end interaction component where collapsed items form cohesive blocks and "split" into individual floating cards when expanded. Designed for premium information hierarchies and learning modules.

#### Features
- **Magnetic Splitting:** Cards physically separate and group dynamically based on the current expansion state.
- **Phase-Shifted Rounding:** Corner radii animate faster than the displacement for a perfectly organic, "liquid" feeling.
- **Context-Aware Grouping:** Items automatically adjust their borders and rounding to form solid blocks when adjacent.
- **Fully Themeable:** Easily customize colors, radii, spacing, and animation curves via a dedicated style class.

#### Usage

1. Add the package: `flutter pub add portal_labs`
2. Use the widget:

```dart
import 'package:portal_labs/portal_labs.dart';

CardSplittingAccordion(
  style: AccordionStyle(
    borderRadius: 22.0,
    spacing: 16.0,
  ),
  items: [
    AccordionItem(
      title: 'UX Strategy',
      content: 'Defining the vision and roadmap for user-centered products.',
      icon: Icons.mouse_rounded,
    ),
    AccordionItem(
      title: 'Visual Identity',
      content: 'Crafting unique brand languages and design systems.',
      icon: Icons.palette_outlined,
    ),
  ],
)
```

---

### 🎚️ Adaptive Slider

![Adaptive Slider Showcase](./assets/adaptive_slider.gif)

A premium, custom-painted slider component where the entire visual identity (gradients, values, and thumb) morphs dynamically based on the current value. Perfect for health, fitness, or smart-home applications.

#### Features
- **Morphing Gradients:** Linear interpolation between custom color steps as you drag.
- **Visual Context Dots:** Interactive indicator dots that change color based on the slider's progress.
- **Haptic-Ready Logic:** Built-in hooks for adding haptic feedback at major value thresholds.
- **Style Injection:** Fully customizable via `AdaptiveSliderStyle` (track height, thumb size, and color steps).
- **Gradient Value Display:** The numeric label uses the same adaptive gradient as the slider track.

#### Usage

1. Add the package: `flutter pub add portal_labs`
2. Use the widget:

```dart
import 'package:portal_labs/portal_labs.dart';

AdaptiveSliderInteraction(
  value: _currentValue,
  min: 0,
  max: 100,
  title: 'Intensity',
  unit: '%',
  onChanged: (val) => setState(() => _currentValue = val),
  style: AdaptiveSliderStyle(
    colorSteps: [
      AdaptiveColorStep(threshold: 0.0, colors: [Colors.green, Colors.teal]),
      AdaptiveColorStep(threshold: 1.0, colors: [Colors.orange, Colors.red]),
    ],
  ),
)
```

---

## 🤝 Contributing

Feel free to open issues or submit pull requests if you have ideas for new interactions or improvements to existing ones!
