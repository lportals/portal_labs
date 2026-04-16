# Changelog

## [0.10.0] - 2026-04-16

- New Component: **Pinnable List** — High-fidelity dual-section list with Apple-style "flight" physics and dynamic self-measuring displacement animations.
- Features: 
  - **Self-Measuring Layout**: Eradicated hardcoded heights; uses a persistent measurement engine to handle items of any size with pixel-perfect accuracy.
  - **Spring Flight Simulations**: Implemented physics-based trajectories for items moving between sections, including a subtle 1.02x elevation scale during "flight".
  - **Smart Z-Order Management**: Dynamic rendering stack that ensures the traveling item always maintains visual priority.
  - **Deeper Customization**: Expanded `PinnableListStyle` for card-specific aesthetics and added `itemBuilder` for 100% layout control.
  - **Intelligent Sorting**: Optional `itemComparator` to maintain logical order during cross-section transfers.

## [0.9.1] - 2026-04-16

## [0.9.0] - 2026-04-15

- New Component: **Disclosure Switch** — Premium high‑fidelity switch with an “Island” inset header, gradient track, and custom premium toggle.
- Features: Concentric rounded corners, animated border, shadow, and a spring‑based opening animation (elastic bounce) for revealing options.
- Integrated **_PremiumSwitch** and **_PremiumCheckbox** sub‑components, plus a custom `ClipRect` for clean overflow handling.
## [0.8.0] - 2024-04-13

- New Component: **Stacked Toast Interaction** — A premium, top-aligned notification system with 3D stacking physics.
- Features custom UI builders for total layout freedom.
- Integrated action callbacks (Retry, Undo, etc.) with configurable labels.
- Deep styling support for icons, typography (TextStyle), and background shapes.

## 0.7.0

- New Component: **QuickSwitcher** — High-fidelity AI/Search bar with tactile **Sink-and-Bounce** physics, atmospheric soft-focus blur transitions, and a glassmorphic **Quick-Select** menu for power users. Optimized for zero interaction latency and pure aesthetic transitions.

## 0.6.0

- New Component: **Labeled Progress Indicator** — Premium sequential loading flow with tranquil label transitions (Skew/Blur/Bounce), progress-aware stages, size-independent shimmer, and robust error state handling.

## 0.5.0

- New Component: **Discovery Bar** — Premium morphing search and discovery component with elastic containers, custom micro-bounce physics, and zero-overflow layout architecture.

## 0.4.0

- New Component: **Modern Fractional Picker** — Precision horizontal ruler for numeric input with support for integer/decimal steps, magnetic snapping, and a premium minimalist aesthetic.

## 0.3.0

- New Component: **Split to Edit** — Premium duration picker that morphs from a unified state into editable segments with elastic bounce transitions and integrated time validation.
- Upgrade: **Morphing Input Button** — Redesigned with a high-contrast premium palette (black/white) and fixed alpha-interpolation blinking for absolute fluidity in Light & Dark mode.

## 0.2.0

- New Component: **Scratch to Reveal** — High-fidelity physical scratching simulation with layered blend modes and diagonal grid textures.
- Maintenance: Fixed all `withValues` and `translate` deprecation warnings to ensure compatibility with Flutter 3.29.

## 0.1.0

- Initial release with 14 premium, zero-dependency UI components:
  - **Reveal & Copy** — Secure data masking with clipboard integration
  - **Modern Weight Picker** — High-fidelity ruler with intelligent haptics
  - **Premium Choice Chips** — Kinematic selections with flying media
  - **Journal Navigation** — Aesthetic daily entries with 3D flip architecture
  - **Card Splitting Accordion** — Magnetic merging behavior and split physics
  - **Adaptive Slider** — Morphing gradients and state-aware interactions
  - **Range Selection Slider** — Mechanical odometer-style counters with manual input
  - **Subscription Picker** — Minimalist pricing sheets with animated billing toggles
  - **Media Collapsible View** — Fluid Reels-style media expansion with interactive sheets
  - **Knob Slider** — Tactile hardware-inspired dial with continuous delta logic
  - **Card Stack Interaction** — Symmetrical center-point expansion for chronological items
  - **Discrete Tabs** — Minimalist pill tabs with bounce and text-slide shimmer
  - **Split Button Interaction** — High-performance morphing action menu with motion blur
  - **Morphing Input Button** — Call-to-action button that morphs into a soft-focus input field
