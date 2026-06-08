# Changelog

## [0.32.0] - 2026-06-05

- **New Component**: **Score Gauge & Segmented Strength Indicator** — A set of
  status visualization widgets consisting of a custom-painted semicircular score
  gauge and a segmented horizontal strength bar.
  - **Semicircular Arc Gauge**: Features a custom-painted gradient sweep track,
    outer tick marks, and an animated value pointer that slides smoothly along
    the arc's inner edge.
  - **Segmented Bar**: Draws a row of rounded, color-coded segments representing
    levels of strength or progress (e.g. for password strength evaluation) that
    animates with physics-based spring curves.
  - **Spring Physics Animations**: Driven by a custom harmonic oscillator curve
    (`PortalSpringCurve`) to animate value transitions smoothly and natively
    without lag.
  - **Tactile Haptics**: Integrates light impact haptic feedback
    (`HapticFeedback.lightImpact`) on score value updates.
  - **Typographic & Style Customization**: Fully customizable styling via
    `ScoreGaugeStyle` including thickness, colors, ticks, arrow sizing, gap
    margins, and segment counts.

## [0.31.0] - 2026-06-04

- **New Component**: **Slider Control** — A premium vertical pill-shaped slider
  widget with a dynamic gradient fill, floating value badge, and snap-to-step
  physics.
  - **Gradient Fill**: Features a smooth GPU-accelerated gradient fill
    (`CustomPainter`) morphing from cool colors at minimum to warm colors at
    maximum.
  - **Floating Value Badge**: A circular badge displaying the current value
    floats next to the pill, fading in during drag gestures and fading out after
    1.5 seconds of inactivity.
  - **Overdamped Spring snap**: Simulates physical snap-to-step mechanics via a
    custom harmonic oscillator curve (`_SpringSettle`) upon release.
  - **Tactile feedback & scale**: Integrates platform selection haptics
    (`HapticFeedback.selectionClick`) on step crossings and scales down the pill
    elastically on press.
  - **Proportional Scaling**: Ensures fonts, limit labels, tick lines, and
    indicator arrows automatically adjust in size and margins when scaling track
    and tick dimensions, avoiding overlapping.
  - **Capsule Rounding**: Defaulted track border radius to `999.0` to preserve
    the capsule aesthetic under large scale adjustments.
  - **Tap-to-seek gesture**: Added gesture support to instantly snap to the
    vertical value tapped along the track.
  - **Screen Reader Semantics**: Integrated Flutter `Semantics` tags
    representing slider control roles, custom value announcements, and semantic
    accessibility actions (increase/decrease values).
  - **Total Customization**: Customizable visual style via `SliderControlStyle`
    including badge anchor, tick marks, and customizable arrow indicator color
    (`arrowColor`).
  - **Release Callback (`onChangeEnd`)**: Added an optional `onChangeEnd`
    callback that fires with the final snapped value once the user releases the
    vertical drag gesture.

## [0.30.0] - 2026-06-03

- **New Component**: **Circular Color Picker** — An interactive, premium color
  picker arranged in a ring layout.
  - **Center-bound Spring Physics**: Selected colors slide to the center using a
    natural spring animation (`PortalSpringCurve`) and expand in size and border
    width.
  - **Circle-bound Smooth Slide**: Previously selected colors slide back to
    their slot on the outer ring with a smooth cubic easing transition
    (`Curves.easeInOutCubic`).
  - **Polar Layout**: Calculates item coordinate bounds dynamically using polar
    layout mathematics within the Stack to ensure correct hit-testing
    boundaries.
  - **Tactile Feedback**: Triggers lightweight system haptics
    (`HapticFeedback.lightImpact`) on selection changes.
  - **Showcase Integration**: Built a clean showcase example displaying the
    color picker and a dynamic "Finish & Save" button that updates its theme
    dynamically to match the user's selected color.

## [0.29.0] - 2026-05-29

- **New Component**: **Quick Picker Interaction** — A premium, high-fidelity
  option picker selector dropdown with a horizontal segmented capsule inside a
  floating bubble popover.
  - **Text Sweep Transition**: Seamless integration with the existing
    `CinematicTextTransition` library configured without elasticity to perform
    smooth linear character sweeps (without bounce).
  - **Icon Blur Transition**: An `AnimatedSwitcher` leveraging real-time
    Gaussian blurs (`ImageFilter.blur`) to dissolve and resolve icons upon value
    changes.
  - **Rotating Chevron Arrow**: Dynamically rotates the dropdown chevron 180
    degrees smoothly using `AnimatedRotation` when the picker is active.
  - **Popover Option Selector Overlay**: Precisely positions a segmented options
    capsule above the trigger button, featuring a dynamic sliding selection pill
    background and custom-painted pointer triangle.
  - **Tactile Haptic Feedback**: Triggers lightweight system haptic feedback on
    selector trigger taps and selection changes.
  - **Robust Testing Suite**: Created high-fidelity widget test coverage
    validating state-machine transitions, disabled states, outside tap
    dismissals, and semantics discovery.

## [0.28.4] - 2026-05-26

- **Documentation**: Updated the components list in `README.md` to convert
  plain-text folder locations into clickable hyperlinks pointing directly to the
  source code on GitHub.

## [0.28.3] - 2026-05-26

- **Maintenance**: Resolved `axisAlignment` deprecation warnings on newer
  Flutter versions (v3.41.0-1.0.pre+) while maintaining backwards compatibility
  with older versions (down to v3.29.0) using warning suppression.
- **Maintenance**: Fixed formatting issue
  (`curly_braces_in_flow_control_structures`) in `CoverflowCarousel` widget.

## [0.28.2] - 2026-05-26

- **Maintenance**: Standardized codebase formatting across all files using
  `dart format` to achieve perfect pub.dev scores.

## [0.28.1] - 2026-05-25

- **Documentation**: Modularized `README.md` by moving detailed component specs
  and showcase GIFs into individual files under `docs/components/` for faster
  page loading and improved SEO on GitHub and `pub.dev`.
- **Maintenance**: Resolved unused import warning in `StackedCards` widget.

## [0.28.0] - 2026-05-24

- **New Component**: **Stacked Cards** — A premium gesture-driven stacked card
  carousel with horizontal swiping, spring snapping physics, rotation effects,
  and page indicator dot animations.
  - **Kinetic Drag & Snap**: Smooth horizontal drag gestures tracking relative
    delta movements, paired with a custom spring curve (`PortalSpringCurve`) to
    snap cleanly onto card boundaries.
  - **Clockwise Fan Effect**: Optional rotational slanting of background cards
    (toggled via `rotationEnabled`) for an elegant physical deck feel.
  - **Dynamic Depth Layout**: Automates Z-ordering by rendering card lists in
    descending order, ensuring seamless layering during left/right swipes.
  - **Morphing Dot Indicator**: A custom-drawn page indicator where the active
    dot smoothly morphs its width and color into a capsule pill driven by the
    scroll offset.
  - **Settle-Limit Opacity Fading**: Background cards smoothly fade out as they
    get pushed past the configurable maximum visible card limit.
  - **Tactile Haptic Feedback**: Leverages system haptics to trigger light
    impact feedback as card boundaries are crossed.

## [0.27.1] - 2026-05-24

- **Bug Fix**: **Coverflow Carousel** — Resolved a double-tap wobble-back issue
  where quickly tapping a side card twice caused the carousel to snap to the
  target and immediately revert to the previous card.
  - **Root Cause (Part 1)**: While animating from card A → B, the card at index
    A becomes a visible "side card" mid-animation. A fast second tap on any card
    interrupted the in-flight spring animation by resetting `_scrollStartValue`
    to the current fractional offset, producing the characteristic wobble.
  - **Root Cause (Part 2)**: A post-animation race condition where the second
    tap of a quick double-click arrived just after animation settlement. Because
    the card layout shifts on completion, the same screen coordinate now points
    to a different card (typically the one just left), triggering a snap-back.
  - **Fix**: Introduced a `_tapNavigationLocked` flag with a **250ms
    post-animation cooldown**. The lock is engaged immediately when an animation
    starts and released 250ms after it settles, absorbing any late-arriving
    input events from the event queue. Drag/swipe navigation is unaffected.
  - **Testing**: Added widget test
    `Should not reset/restart animation when target card is tapped again while animating`
    to the `CoverflowCarousel` test suite.

## [0.27.0] - 2026-05-22

- **New Component**: **Coverflow Carousel** — A premium 3D Coverflow carousel
  widget inspired by the classic iPod/iTunes interface, displaying children in
  3D perspective rotated around the Y-axis (horizontal) or X-axis (vertical) and
  overlapping toward the center.
  - **Dual-Orientation Support**: Introduced seamless switching between
    horizontal and vertical layouts using the `scrollDirection` parameter.
  - **3D Perspective Projection**: Implements realistic 3D transformations with
    adjustable perspective factors, scale deltas, and maximum axis rotation
    angles.
  - **Left-Side Vertical Reflections**: Designed automatic layout adaptation to
    render reflections on the left side of cards in vertical mode, preventing
    overlap with the right-sided slider control.
  - **Clipping & Boundaries**: Integrated conditional `Clip.hardEdge` clipping
    and optimized fade limits (`maxVisibleDiff = 3.0`) in vertical mode to
    prevent cards from bleeding outside the widget boundaries.
  - **Symmetric Depth Sorting (Z-Ordering)**: Automatically sorts painting
    indices based on active center distance to keep foreground items on top of
    background cards.
  - **Interactive Slider Sync**: Integrates a gesturally interactive custom
    slider (placed below the carousel in horizontal mode, or on the right side
    in vertical mode) that stays perfectly synchronized with fractional scroll
    offsets.
  - **Programmatic Controller**: Supports external controller commands to
    trigger organic spring-settling animations or instant jumps to arbitrary
    cards.
  - **Tactile Haptic Feedback**: Leverages system haptics to trigger light
    impact feedback as card boundaries are crossed.
  - **Testing & Quality Assurance**: Created comprehensive widget test suites
    covering vertical drag gestures, vertical reflection placements,
    programmatic controls, and gesture swipe thresholds.

## [0.26.0] - 2026-05-19

- **New Component**: **Physics Collision Card** — An interactive 2D rigid-body
  physics simulation container for circular elements (avatars, badges, tech
  brand icons) that bounce elastically off walls and each other.
  - **Kinetic Vector Physics**: High-fidelity simulation of customizable gravity
    vectors, damping/friction coefficients, and bounciness (restitution).
  - **Tactile Drag & Throw**: Natural gesture tracking that integrates with
    platform velocity trackers for realistic throwing physics.
  - **Rate-Throttled Collision Haptics**: Integrated vibration triggers on
    high-energy collisions, optimized to prevent continuous buzzing.
  - **Smart Auto-Sleep Engine**: Intelligent sleep manager that pauses active
    tickers when objects come to rest, conserving CPU/battery.
  - **Total Customization**: Highly customizable styling via
    `PhysicsCollisionCardStyle` for card borders, item decoration, and physical
    coefficients.

## [0.25.0] - 2026-05-19

- **New Component**: **Folder Tabs** — A physics-driven Manila file folder tab
  container with organic S-curve custom bezier geometry, implicit height
  resizing, and dynamic proximity dissolve animations.
  - **Custom Bezier S-Curve Painter**: Draws identical, beautiful tab shapes
    that smoothly morph into the folder's corner roundings at the edges,
    clipping horizontal shelves.
  - **Filing Drawer Cabinet Depth**: Renders background static tab sheets with
    soft shadows to simulate a real nested drawer depth effect.
  - **Proximity-Based Dissolve**: Background tabs dynamically fade out and blend
    their colors as the active tab slides over them, preventing double-tab
    overlap artifacts.
  - **Implicit Vertical Resizing**: Uses dynamic layout measurements and
    `AnimatedSize` to smoothly grow and shrink the folder height based on
    content length.
  - **Interactive File Selection**: Supports hover/press states with native ink
    splashes, custom haptic feedback, and dynamic floating toast actions.
  - **Responsive Design**: Scales beautifully across dynamic tab counts (e.g. 3
    tabs, 4 tabs) and custom sizes on both mobile and desktop screens.

## [0.24.1] - 2026-05-14

- **Showcase**: Refined Archive Folder responsiveness and mobile centering.

## [0.24.0] - 2026-05-13

- **New Component**: **Archive Folder** — A premium glassmorphic folder
  interaction that reveals its contents with staggered, physics-based
  animations.
  - **Dual-Orientation Architecture**: Optimized for both vertical (upright) and
    horizontal (flat) layouts with intelligent hit-testing and coordinate-space
    adaptation.
  - **Glassmorphism Design**: High-fidelity `BackdropFilter` implementation with
    customizable blur and opacity.
  - **Staggered Reveal Engine**: Internal items animate out with independent
    delays and elastic bounce physics.
  - **Dynamic Z-Stacking**: Implemented a "Pop-to-Front" mechanism that brings
    tapped items to the foreground with spring-based scaling
    (`Curves.elasticOut`).
  - **ArchiveItem**: Introduced a standalone companion widget for archival-style
    item presentation (white frame + bottom label).
  - **Premium Haptics**: Integrated selection-click haptic feedback on item
    focus and light-impact on folder toggle.
- **Bug Fix**: Resolved 3D perspective (`Matrix4.setEntry`) instability causing
  dropped touch events on rotated item corners.
- **Documentation**: Updated README.md and Showcase with the new generic item
  architecture and dual-orientation examples.

## [0.23.1] - 2026-05-12

- **Documentation**: Added high-fidelity showcase GIF for the
  `CinematicTextTransition` component in README.md.

## [0.23.0] - 2026-05-11

- **Testing Milestone**: Achieved 100% widget test coverage for all 37
  components in the library.
- **New Component**: **Cinematic Text Transition** — A sophisticated text
  transition with sequential character physics, elastic settling, and layout
  stability.
- **Component Standardization**: Finalized the premium migration of
  `Reveal & Copy`, `Media Collapsible View`, `Knob Slider`, and 10+ others.
- **Improved Stability**: Refactored `RevealCopyInteraction` for more robust
  hit-testing and reliable asynchronous state transitions.
- **Housekeeping**: Optimized `dart analyze` to eliminate all redundant argument
  lints across the codebase.

## [0.22.1] - 2026-05-08

- **Pub Score Optimization**: Resolved all `dart analyze` warnings and info
  messages to achieve a perfect health score.
- **Housekeeping**: Cleaned up deprecated `onWillAccept` usage in
  `PremiumSortableGrid`.
- **Test Stability**: Updated semantic tests to use modern `SemanticsFlags`
  properties.
- **Documentation**: Added missing API documentation for the new Sortable Grid
  public members.

## [0.22.0] - 2026-05-08

- **New Component**: **Sortable Grid** — A premium, physics-based reorderable
  grid with smooth layout transitions and integrated haptic feedback.
  - **Physics-Based Reordering**: Intelligent item flow using
    `AnimatedPositioned` with customizable easing curves.
  - **Pulse-on-Hold Interaction**: Dedicated `AnimationController` manages a
    "lifting" pulse effect while holding an item before drag.
  - **Tactile Haptics**: Light-impact feedback on drag start and drop for a
    hardware-inspired feel.
  - **Dynamic Layout Stability**: Automatic height and dimension recalculation
    during grid density changes.
  - **Flexible Customization**: 10+ style properties including drag scale,
    opacity, and custom shadows via `PremiumSortableGridStyle`.

- **Standardization Milestone**:
  - **Physics Migration**: Standardized the entire library motion profile to use
    the new `PortalSpringCurve` for tactile, high-fidelity button interactions.
  - **Premium Component Standardization**: Successfully migrated
    `Currency Swap`, `Premium Pagination`, and `Premium Stepper` to the new
    physics-based mechanical standards.
  - **Accessibility & Semantics**: Integrated `Semantics` nodes across
    interactive surfaces to ensure platform accessibility and robust testing
    discovery.
  - **Test Coverage Expansion**: Added comprehensive test suites for
    `PremiumPagination`, `PremiumStepper`, and `CurrencySwapInteraction` to
    validate state-machine transitions and physics-based interactions.
  - **Architecture**: Refactored gesture handlers to be `null` when disabled,
    correctly propagating state to the accessibility tree.
  - **Enhancement**: Improved `PremiumFlipCounter` with explicit semantics and
    padding management for stable layouts.

## [0.21.1] - 2026-05-07

- Documentation: Fixed GIF reference paths in README.md and removed redundant
  .mov file.
- Fix: Standardized showcase assets to use absolute GitHub raw URLs for pub.dev
  compatibility.

## [0.21.0] - 2026-05-07

- New Component: **Signature Draw Pad** — A premium, high-fidelity signature
  drawing component with playback animations, fluid state transitions, and
  high-resolution PNG export.
- Features & Evolutions:
  - **Signature Playback**: Integrated playback engine that re-draws the
    signature with adjustable duration and shimmer effects.
  - **Off-Screen PNG Export**: Integrated `toImage()` engine in the controller
    for high-resolution, auto-centered, and scaled image generation.
  - **Document Integrity Lock**: Automatic canvas disabling and UI cleanup after
    confirmation to prevent post-sign tampering.
  - **Fluid State Transitions**: Premium hold-to-confirm button that morphs into
    a success state using smooth blur dissolves and spring physics.
  - **Customizable Color Palette**: Full control over the palette colors with
    reactive state propagation to all existing strokes.

## [0.20.0] - 2026-05-05

- New Component: **Loading Shapes** — A premium, physics-based loading indicator
  that morphs between organic and geometric shapes.
- Features & Evolutions:
  - **Momentum Rotation Engine**: Frame-perfect `Ticker` system for continuous,
    inertia-based motion without resets.
  - **Custom Geometry Engine**: Introduced `PortalShapeDefinition` for control
    over sides, inner radius, and smoothness.
  - **120-Point Path Morphing**: High-fidelity interpolation for perfectly fluid
    shape-shifting.
  - **Showcase Shell**: Unified documentation and code access for all new
    components.

## [0.19.0] - 2026-05-04

- New Component: **Feedback Interaction** — A premium interaction system for
  capturing user feedback with physics-based morphing and liquid transitions.
- New Component: **Inline Delete Interaction** — A premium action menu with an
  inline destructive confirmation flow that transitions vertically while
  maintaining modal stability.
- Features:
  - **Asymmetric Spring Physics**: Native `SpringSimulation` engine that handles
    opening and closing transitions with independent kinetic parameters.
  - **Geometric Harmony Architecture**: Synchronized morphing where interactive
    buttons and the container expand as a single cohesive unit.
  - **Zero-Latency Response**: Smart state management allows for immediate
    re-interaction during settling animations.
  - **Vertical Confirmation Flow**: Inline destructive action transforms while
    keeping the menu footprint stable.
  - **Total Design Freedom**: Fully customizable styles via
    `FeedbackInteractionStyle` and `InlineDeleteStyle`.
  - **Production-Ready Engineering**: Implemented origin-aware scaling,
    `ease-out` cubic curves, and tactile press-down feedback.

## [0.18.4] - 2026-04-30

- New Component: **Premium Progress Stepper** — A high-fidelity multi-step
  indicator with physics-based spring animations, tactile bounce buttons, and
  dynamic navigation logic.
- **Production-Ready**: Comprehensive quality audit, 100% API documentation
  coverage, and migration to modern Flutter standards.

## [0.18.0] - 2026-04-28

- **The Showcase Evolution**: Re-engineered the Example app with physics-based
  transitions, transparent System UI mastery, and global
  `BouncingScrollPhysics`.
- **New Component**: **Currency Swap Interaction** — A premium conversion
  interface with mechanical flip counters and tactile haptics.
- **Architectural Refinement**: Unified animation engine with the new
  `PortalSpringCurve` and forced accessibility/DX improvements.
- **Performance**: Integrated `RepaintBoundary` on high-frequency surfaces to
  isolate GPU layers.

## [0.17.1] - 2026-04-28

- Fix: Updated all README GIF image paths from relative to absolute GitHub raw
  URLs so they render correctly on pub.dev.

## [0.17.0] - 2026-04-27

- New Component: **Currency Swap Interaction** — A premium currency conversion
  interface with custom dropdowns and real-time flip counters.
- Features:
  - **Custom Dropdown Menu**: High-performance overlay menu with flag support
    and selection checkmarks.
  - **Mechanical Flip Counter**: Real-time conversion feedback using the
    `PremiumFlipCounter` engine for fluid numerical transitions.
  - **Tactile Feedback**: Proceed button with scale-down feedback (0.98x) and
    integrated light-impact haptics.
  - **Design Fidelity**: Strictly follows the provided light-themed design
    without unrequested variations.
  - **Total Design Freedom**: Fully customizable style including typography,
    colors, borders, and spacing via `CurrencySwapStyle`.

## [0.16.0] - 2026-04-25

- New Component: **Premium Pagination** — A minimalist, tactile navigation
  component with mechanical flip animations and layout stability controls.
- Features:
  - **Mechanical Flip Counter**: Integrated `PremiumFlipCounter` for fluid,
    odometer-style page transitions.
  - **Automatic Layout Stability**: Intelligent column width calculation based
    on total pages to prevent jumping.
  - **Tactile Feedback**: Interactive buttons with `0.95x` scale feedback and
    integrated light-impact haptics.
  - **Total Design Freedom**: Fully customizable style including
    `buttonBorderRadius`, `padding`, `borderWidth`, and arbitrary icons.
- Upgrade: **Premium Stepper** — Levelled up to the new premium standards with
  support for custom padding, border width, and button border radius
  (square/circular).

## [0.15.0] - 2026-04-23

- New Component: **Premium Stepper** — A minimalist tactile stepper component
  with mechanical flip animations and haptic feedback.
- Features:
  - **Premium Interaction Logic**: Integrated odometer-style page transitions
    for fluid numerical feedback.
  - **Tactile Buttons**: Circular action buttons with scale-down feedback.
  - **Haptic Integration**: Light-impact haptic feedback on value changes.
  - **Minimalist Design**: Pill-shaped container with clean typography.

## [0.14.0] - 2026-04-22

- New Component: **Collapsible Notification Panel** — A premium, highly
  interactive notification panel that can collapse into a summary header and
  expand to show a list of activities with spring-based animations and staggered
  entry effects.
- Features:
  - **Spring Physics Engine**: Uses `SpringSimulation` for a natural,
    momentum-based expansion and collapse feel that matches premium OS
    interactions.
  - **Staggered Child Animations**: Intelligent sequencing of item entrance with
    independent opacity and Y-translation offsets for a polished, choreographed
    look.
  - **Header Summary Architecture**: Dual-state header that displays a clean
    activity count and subtitle summary when collapsed, with an animated 500ms
    bell shake.
  - **Premium Haptics & Feedback**: Integrated `AnimatedScale` on all
    interactive surfaces (0.97x press feedback) with elastic rotation for the
    expansion toggle.
  - **Zero Dependencies**: Built exclusively with vanilla Flutter components for
    maximum performance and portability.

## [0.13.0] - 2026-04-21

- New Component: **Tag Selection Interaction** — A premium, zero-dependency
  "Magic Move" tag selection component with 100% custom Apple-inspired spring
  physics and self-measuring Wrap layouts.
- Features:
  - **Dynamic Natural Sizing**: Fully responsive internal metrics that adapt
    perfectly to the font's baseline, scale, and system accessibility settings.
  - **Apple Spring Simulator**: Includes a custom damped harmonic oscillator
    (`_PortalSpringCurve`) to replicate premium native OS bounce and flight
    effects without external packages.
  - **Fluid Wrap Layout**: Manual layout engine computes relative positions in
    real-time, letting items fly logically between fluid `Wrap` states without
    clipping.
  - **Zero Dependencies**: Pure Vanilla Flutter architecture ensuring high
    performance, zero package conflicts, and long-term portability.

## [0.12.0] - 2026-04-20

- New Component: **Slot Picker Interaction** — Premium physics-based
  availability picker with spring simulations, real-time collision detection,
  and premium OS-inspired aesthetics.
- Features:
  - **Collision Detection Engine**: Real-time analysis of overlapping time
    ranges with non-disruptive visual warnings and subtle reddish tints.
  - **Smart Validation System**: Configurable `validationInterval` and
    auto-correcting logic to maintain time integrity across slots.
  - **Spring-Based Expansion**: High-fidelity item expansion using
    `SpringSimulation` for a tactile, hardware-inspired physical feel.
  - **Total Design Customization**: 15+ properties in `SlotPickerStyle` allowing
    control over every pixel (paddings, typography, action colors). and Android
    (Material) with sub-minute snapping.
  - **Dynamic Slot Management**: Seamlessly add, remove, and update time slots
    with synchronized state and reactive UI updates.

## [0.11.0] - 2026-04-17

- New Component: **Todo List Interaction** — High-fidelity task management
  featuring a sophisticated "concentric island" design and choreographed
  diagonal "flight" animations.
- Features:
  - **Diagonal Flight Physics**: Tri-stage completion interaction (lateral
    shift, state toggle, and diagonal landing) with independent simulation
    cycles per task.
  - **Concentric Island Design**: Layered interface architecture with centered
    date headers and strictly contained white interactive cards.
  - **Morphing Segmented Control**: Sliding spring-driven tab system with
    elastic indicator resizing for perfect text alignment.
  - **Concurrent Animation Support**: Robust state management using Set-based
    tracking to allow multiple flight animations to run simultaneously without
    interference.
  - **Production-Ready Theming**: 100% themeable via `TodoListStyle`, including
    logic for custom filter labels and spring physics parameters.

## [0.10.0] - 2026-04-16

- New Component: **Pinnable List** — High-fidelity dual-section list with
  premium OS-style "flight" physics and dynamic self-measuring displacement
  animations.
- Features:
  - **Self-Measuring Layout**: Eradicated hardcoded heights; uses a persistent
    measurement engine to handle items of any size with pixel-perfect accuracy.
  - **Spring Flight Simulations**: Implemented physics-based trajectories for
    items moving between sections, including a subtle 1.02x elevation scale
    during "flight".
  - **Smart Z-Order Management**: Dynamic rendering stack that ensures the
    traveling item always maintains visual priority.
  - **Deeper Customization**: Expanded `PinnableListStyle` for card-specific
    aesthetics and added `itemBuilder` for 100% layout control.
  - **Intelligent Sorting**: Optional `itemComparator` to maintain logical order
    during cross-section transfers.

## [0.9.0] - 2026-04-15

- New Component: **Disclosure Switch** — Premium high‑fidelity switch with an
  “Island” inset header, gradient track, and custom premium toggle.
- Features: Concentric rounded corners, animated border, shadow, and a
  spring‑based opening animation (elastic bounce) for revealing options.
- Integrated **_PremiumSwitch** and **_PremiumCheckbox** sub‑components, plus a
  custom `ClipRect` for clean overflow handling.

## [0.8.0] - 2024-04-13

- New Component: **Stacked Toast Interaction** — A premium, top-aligned
  notification system with 3D stacking physics.
- Features custom UI builders for total layout freedom.
- Integrated action callbacks (Retry, Undo, etc.) with configurable labels.
- Deep styling support for icons, typography (TextStyle), and background shapes.

## [0.7.0] - 2026-04-10

- New Component: **QuickSwitcher** — High-fidelity AI/Search bar with tactile
  **Sink-and-Bounce** physics, atmospheric soft-focus blur transitions, and a
  glassmorphic **Quick-Select** menu for power users. Optimized for zero
  interaction latency and pure aesthetic transitions.

## [0.6.0] - 2026-04-08

- New Component: **Labeled Progress Indicator** — Premium sequential loading
  flow with tranquil label transitions (Skew/Blur/Bounce), progress-aware
  stages, size-independent shimmer, and robust error state handling.

## [0.5.0] - 2026-04-05

- New Component: **Discovery Bar** — Premium morphing search and discovery
  component with elastic containers, custom micro-bounce physics, and
  zero-overflow layout architecture.

## [0.4.0] - 2026-04-03

- New Component: **Modern Fractional Picker** — Precision horizontal ruler for
  numeric input with support for integer/decimal steps, magnetic snapping, and a
  premium minimalist aesthetic.

## [0.3.0] - 2026-03-30

- New Component: **Split to Edit** — Premium duration picker that morphs from a
  unified state into editable segments with elastic bounce transitions and
  integrated time validation.
- Upgrade: **Morphing Input Button** — Redesigned with a high-contrast premium
  palette (black/white) and fixed alpha-interpolation blinking for absolute
  fluidity in Light & Dark mode.

## [0.2.0] - 2026-03-25

- New Component: **Scratch to Reveal** — High-fidelity physical scratching
  simulation with layered blend modes and diagonal grid textures.
- Maintenance: Fixed all `withValues` and `translate` deprecation warnings to
  ensure compatibility with Flutter 3.29.

## [0.1.0] - 2026-03-20

- Initial release with 14 premium, zero-dependency UI components:
  - **Reveal & Copy** — Secure data masking with clipboard integration
  - **Modern Weight Picker** — High-fidelity ruler with intelligent haptics
  - **Premium Choice Chips** — Kinematic selections with flying media
  - **Journal Navigation** — Aesthetic daily entries with 3D flip architecture
  - **Card Splitting Accordion** — Magnetic merging behavior and split physics
  - **Adaptive Slider** — Morphing gradients and state-aware interactions
  - **Range Selection Slider** — Mechanical odometer-style counters with manual
    input
  - **Subscription Picker** — Minimalist pricing sheets with animated billing
    toggles
  - **Media Collapsible View** — Fluid Reels-style media expansion with
    interactive sheets
  - **Knob Slider** — Tactile hardware-inspired dial with continuous delta logic
  - **Card Stack Interaction** — Symmetrical center-point expansion for
    chronological items
  - **Discrete Tabs** — Minimalist pill tabs with bounce and text-slide shimmer
  - **Split Button Interaction** — High-performance morphing action menu with
    motion blur
  - **Morphing Input Button** — Call-to-action button that morphs into a
    soft-focus input field
