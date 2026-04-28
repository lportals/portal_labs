# Changelog

## [0.17.0] - 2026-04-27

- New Component: **Currency Swap Interaction** — A premium currency conversion interface with custom dropdowns and real-time flip counters.
- Features:
  - **Custom Dropdown Menu**: High-performance overlay menu with flag support and selection checkmarks.
  - **Mechanical Flip Counter**: Real-time conversion feedback using the `PremiumFlipCounter` engine for fluid numerical transitions.
  - **Tactile Feedback**: Proceed button with scale-down feedback (0.98x) and integrated light-impact haptics.
  - **Design Fidelity**: Strictly follows the provided light-themed design without unrequested variations.
  - **Total Design Freedom**: Fully customizable style including typography, colors, borders, and spacing via `CurrencySwapStyle`.


## [0.16.0] - 2026-04-25

- New Component: **Premium Pagination** — A minimalist, tactile navigation component with mechanical flip animations and layout stability controls.
- Features:
  - **Mechanical Flip Counter**: Integrated `PremiumFlipCounter` for fluid, odometer-style page transitions.
  - **Automatic Layout Stability**: Intelligent column width calculation based on total pages to prevent jumping.
  - **Tactile Feedback**: Interactive buttons with `0.95x` scale feedback and integrated light-impact haptics.
  - **Total Design Freedom**: Fully customizable style including `buttonBorderRadius`, `padding`, `borderWidth`, and arbitrary icons.
- Upgrade: **Premium Stepper** — Levelled up to the new premium standards with support for custom padding, border width, and button border radius (square/circular).

## [0.15.0] - 2026-04-23

- New Component: **Premium Stepper** — A minimalist tactile stepper component with mechanical flip animations and haptic feedback.
- Features:
  - **Mechanical Flip Counter**: Integrated `PremiumFlipCounter` for fluid numerical transitions.
  - **Tactile Buttons**: Circular action buttons with scale-down feedback.
  - **Haptic Integration**: Light-impact haptic feedback on value changes.
  - **Minimalist Design**: Pill-shaped container with clean typography.

## [0.14.0] - 2026-04-22

- New Component: **Collapsible Notification Panel** — A premium, highly interactive notification panel that can collapse into a summary header and expand to show a list of activities with spring-based animations and staggered entry effects.
- Features:
  - **Spring Physics Engine**: Uses `SpringSimulation` for a natural, momentum-based expansion and collapse feel that matches premium OS interactions.
  - **Staggered Child Animations**: Intelligent sequencing of item entrance with independent opacity and Y-translation offsets for a polished, choreographed look.
  - **Header Summary Architecture**: Dual-state header that displays a clean activity count and subtitle summary when collapsed, with an animated 500ms bell shake.
  - **Premium Haptics & Feedback**: Integrated `AnimatedScale` on all interactive surfaces (0.97x press feedback) with elastic rotation for the expansion toggle.
  - **Zero Dependencies**: Built exclusively with vanilla Flutter components for maximum performance and portability.

## [0.13.0] - 2026-04-21

- New Component: **Tag Selection Interaction** — A premium, zero-dependency "Magic Move" tag selection component with 100% custom Apple-inspired spring physics and self-measuring Wrap layouts.
- Features:
  - **Dynamic Natural Sizing**: Fully responsive internal metrics that adapt perfectly to the font's baseline, scale, and system accessibility settings.
  - **Apple Spring Simulator**: Includes a custom damped harmonic oscillator (`_AppleSpringCurve`) to replicate premium native OS bounce and flight effects without external packages.
  - **Fluid Wrap Layout**: Manual layout engine computes relative positions in real-time, letting items fly logically between fluid `Wrap` states without clipping.
  - **Zero Dependencies**: Pure Vanilla Flutter architecture ensuring high performance, zero package conflicts, and long-term portability.

## [0.12.0] - 2026-04-20

- New Component: **Slot Picker Interaction** — Premium physics-based availability picker with spring simulations, real-time collision detection, and Apple-inspired aesthetics.
- Features:
  - **Collision Detection Engine**: Real-time analysis of overlapping time ranges with non-disruptive visual warnings and subtle reddish tints.
  - **Smart Validation System**: Configurable `validationInterval` and auto-correcting logic to maintain time integrity across slots.
  - **Spring-Based Expansion**: High-fidelity item expansion using `SpringSimulation` for a tactile, hardware-inspired physical feel.
  - **Total Design Customization**: 15+ properties in `SlotPickerStyle` allowing control over every pixel (paddings, typography, action colors).
  - **Adaptive Time Pickers**: Native-feeling selection for both iOS (Cupertino) and Android (Material) with sub-minute snapping.
  - **Dynamic Slot Management**: Seamlessly add, remove, and update time slots with synchronized state and reactive UI updates.

## [0.11.0] - 2026-04-17

- New Component: **Todo List Interaction** — High-fidelity task management featuring a sophisticated "concentric island" design and choreographed diagonal "flight" animations.
- Features:
  - **Diagonal Flight Physics**: Tri-stage completion interaction (lateral shift, state toggle, and diagonal landing) with independent simulation cycles per task.
  - **Concentric Island Design**: Layered interface architecture with centered date headers and strictly contained white interactive cards.
  - **Morphing Segmented Control**: Sliding spring-driven tab system with elastic indicator resizing for perfect text alignment.
  - **Concurrent Animation Support**: Robust state management using Set-based tracking to allow multiple flight animations to run simultaneously without interference.
  - **Production-Ready Theming**: 100% themeable via `TodoListStyle`, including logic for custom filter labels and spring physics parameters.

## [0.10.0] - 2026-04-16

- New Component: **Pinnable List** — High-fidelity dual-section list with Apple-style "flight" physics and dynamic self-measuring displacement animations.
- Features:
  - **Self-Measuring Layout**: Eradicated hardcoded heights; uses a persistent measurement engine to handle items of any size with pixel-perfect accuracy.
  - **Spring Flight Simulations**: Implemented physics-based trajectories for items moving between sections, including a subtle 1.02x elevation scale during "flight".
  - **Smart Z-Order Management**: Dynamic rendering stack that ensures the traveling item always maintains visual priority.
  - **Deeper Customization**: Expanded `PinnableListStyle` for card-specific aesthetics and added `itemBuilder` for 100% layout control.
  - **Intelligent Sorting**: Optional `itemComparator` to maintain logical order during cross-section transfers.

## [0.9.0] - 2026-04-15

- New Component: **Disclosure Switch** — Premium high‑fidelity switch with an “Island” inset header, gradient track, and custom premium toggle.
- Features: Concentric rounded corners, animated border, shadow, and a spring‑based opening animation (elastic bounce) for revealing options.
- Integrated **_PremiumSwitch** and **_PremiumCheckbox** sub‑components, plus a custom `ClipRect` for clean overflow handling.

## [0.8.0] - 2024-04-13

- New Component: **Stacked Toast Interaction** — A premium, top-aligned notification system with 3D stacking physics.
- Features custom UI builders for total layout freedom.
- Integrated action callbacks (Retry, Undo, etc.) with configurable labels.
- Deep styling support for icons, typography (TextStyle), and background shapes.

## [0.7.0] - 2026-04-10

- New Component: **QuickSwitcher** — High-fidelity AI/Search bar with tactile **Sink-and-Bounce** physics, atmospheric soft-focus blur transitions, and a glassmorphic **Quick-Select** menu for power users. Optimized for zero interaction latency and pure aesthetic transitions.

## [0.6.0] - 2026-04-08

- New Component: **Labeled Progress Indicator** — Premium sequential loading flow with tranquil label transitions (Skew/Blur/Bounce), progress-aware stages, size-independent shimmer, and robust error state handling.

## [0.5.0] - 2026-04-05

- New Component: **Discovery Bar** — Premium morphing search and discovery component with elastic containers, custom micro-bounce physics, and zero-overflow layout architecture.

## [0.4.0] - 2026-04-03

- New Component: **Modern Fractional Picker** — Precision horizontal ruler for numeric input with support for integer/decimal steps, magnetic snapping, and a premium minimalist aesthetic.

## [0.3.0] - 2026-03-30

- New Component: **Split to Edit** — Premium duration picker that morphs from a unified state into editable segments with elastic bounce transitions and integrated time validation.
- Upgrade: **Morphing Input Button** — Redesigned with a high-contrast premium palette (black/white) and fixed alpha-interpolation blinking for absolute fluidity in Light & Dark mode.

## [0.2.0] - 2026-03-25

- New Component: **Scratch to Reveal** — High-fidelity physical scratching simulation with layered blend modes and diagonal grid textures.
- Maintenance: Fixed all `withValues` and `translate` deprecation warnings to ensure compatibility with Flutter 3.29.

## [0.1.0] - 2026-03-20

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
