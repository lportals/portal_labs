# 🧪 Portal Labs

A curated collection of **premium, zero-dependency** Flutter UI components and experimental interactions. Built with 100% vanilla Flutter/Dart.

## 🚀 The "Zero-Dependency" Promise

Every component in this repository is built using only the core Flutter and Dart libraries. 
- **No `intl`**: Manual date logic and formatting centralized in `PortalUtils`.
- **No `lucide_icons` or `font_awesome`**: Uses standard Material Design rounded icons.
- **No `google_fonts`**: Uses system default fonts for zero-latency, native performance.
- **No `animations` package**: All physics and transitions are built with `AnimationController` and `Tween`s.

To maintain scalability without external bloat, we use [PortalUtils](/lib/components/common/portal_utils.dart), a lightweight internal utility for text measurement, date formatting, and spacing.

This makes every component **instantly copy-pasteable** into any Flutter project without adding bloat or versioning conflicts.

## 📖 Component Library

This repository acts as a mono-repo for different premium UI components. Each component is designed to be copy-paste ready into your own projects. 

| Component | Description | Complexity | Location |
|-----------|-------------|------------|----------|
| **[Reveal & Copy](#-reveal--copy)** | Secure scramble reveal for sensitive data with copy-to-clipboard animation. | Low | `/lib/components/reveal_and_copy/` |
| **[Modern Weight Picker](#-modern-weight-picker)** | Precision scrollable ruler with haptic feedback and magnetic snapping. | Low-Mid | `/lib/components/weight_picker/` |
| **[Premium Choice Chips](#-premium-choice-chips)** | Animated selection with flip counter and flying media transitions. | Mid | `/lib/components/premium_choice_chips/` |
| **[Journal Navigation](#-journal-navigation)** | Aesthetic daily entries with a vertical scroller, 3D flip counter, and snapping. | Mid-High | `/lib/components/journal_navigation/` |
| **[Card Splitting Accordion](#-card-splitting-accordion)** | Magnetic grouping interaction where items split into standalone cards. | High | `/lib/components/card_splitting_accordion/` |

---

### 🔒 Reveal & Copy

![Reveal & Copy Showcase](./assets/reveal_and_copy.gif)

A premium interaction designed for safely displaying and copying sensitive information like credit card numbers, passwords, or API keys. 

#### Features
- **Secure by Default:** Values are masked with a custom character (defaults to '×').
- **Elegant Animations:** Smooth scramble reveal effect and a premium shimmer pass upon revealing.
- **Auto-Hide:** Automatically reverts to a masked state after a configurable duration.
- **Micro-interactions:** Integrated copy-to-clipboard functionality with animated visual feedback.

#### Usage

1. Copy `lib/components/reveal_and_copy/reveal_copy_interaction.dart` into your project.
2. Use the widget:

```dart
import 'path/to/reveal_copy_interaction.dart';

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

![Weight Picker Showcase](./assets/weight_picker.gif)

A sleek, precision-focused ruler input for numeric values, perfect for fitness apps or physical measurements.

#### Features
- **Precision Ruler:** Custom-painted interactive ruler with major and minor increments.
- **Magnetic Snapping:** Smooth snapping to the nearest value for a tactile feel.
- **Dynamic Feedback:** Real-time value updates as the user scrolls.
- **Premium Styling:** Gradient-based highlighting and modern typography.

#### Usage

1. Copy the contents of `lib/components/weight_picker/` into your project.
2. Use the widget:

```dart
import 'path/to/weight_picker.dart';

ModernWeightPicker(
  initialValue: 75.0,
  onValueChanged: (weight) {
    print('Current weight: $weight');
  },
)
```

---

### 🎨 Premium Choice Chips

![Premium Choice Chips Showcase](./assets/premium_choice_chips.gif)

A playful and engaging interaction component for selections, featuring high-end animations and multi-media support (Emojis, Icons, and Images).

#### Features
- **Multi-media Support:** Use text emojis, Flutter icons, or network/asset images as items.
- **Flying Media Animation:** When an item is selected, a pyramid of 3 media elements (emoji/icon/image) flies up and "lands" in the counter.
- **3D Flip Counter:** An odometer-style flip animation for counting selections.
- **Customizable Labels:** Easily change button labels (e.g., "Interest" vs "Interests").

#### Usage

1. Copy the contents of `lib/components/choice_chips/` and the shared utilities in `lib/components/common/` into your project.
2. Use the widget:

```dart
import 'path/to/premium_choice_chips.dart';
import 'path/to/models/choice_item.dart';

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

![Journal Navigation Showcase](./assets/journal_navigation.gif)

A premium, aesthetic interaction designed for daily logging or historical views. Features a vertical date slider on the left and a content area on the right with smooth animations and transitions.

#### Features
- **Vertical Date Scroller:** A minimal white-pill scroller with infinite support for months and days.
- **Magnetic Snapping:** Smooth snapping physics that centers the selected date automatically.
- **3D Flip Counter:** An odometer-style flip animation for the day number, indicating direction (past/future).
- **Custom Child Support:** Replace the default title/content with any complex widget (Images, Charts, Videos).
- **Style Injection:** Fully customizable via `JournalStyle` (colors, borders, shadows, typography).
- **Smooth Content Transitions:** Fade and slide animations when switching journal entries.

#### Usage

1. Copy `lib/components/journal_navigation/` and the shared utilities in `lib/components/common/` into your project.
2. Use the widget:

```dart
import 'path/to/journal_navigation.dart';
import 'path/to/models/journal_item.dart';

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

![Card Splitting Accordion Showcase](./assets/card_splitting_accordion.gif)

A high-end interaction component where collapsed items form cohesive blocks and "split" into individual floating cards when expanded. Designed for premium information hierarchies and learning modules.

#### Features
- **Magnetic Splitting:** Cards physically separate and group dynamically based on the current expansion state.
- **Phase-Shifted Rounding:** Corner radii animate faster than the displacement for a perfectly organic, "liquid" feeling.
- **Context-Aware Grouping:** Items automatically adjust their borders and rounding to form solid blocks when adjacent.
- **Fully Themeable:** Easily customize colors, radii, spacing, and animation curves via a dedicated style class.

#### Usage

1. Copy the contents of `lib/components/card_splitting_accordion/` into your project.
2. Use the widget:

```dart
import 'path/to/card_splitting_accordion.dart';

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

## 🤝 Contributing

Feel free to open issues or submit pull requests if you have ideas for new interactions or improvements to existing ones!
