# Score Gauge

A premium animated semicircular gauge for displaying score status (e.g. credit score or security level) with a sliding center-aligned pointer, rotating ticks, and an odometer-style rolling digit counter.

![Score Gauge Showcase](https://raw.githubusercontent.com/lportals/portal_labs/main/docs/gifs/score_gauge.gif)

#### Key Features

- **Always-Filled Dynamic Shifting Color**: The track remains 100% filled at all times, with its entire GPU-accelerated gradient color shifting dynamically. Instead of hardcoded values, the painter mathematically interpolates across any custom list of colors specified in `style.trackGradientColors` (supporting monochromatic, branded, or multi-color spectrums of any length).
- **Magnetic Rotating Ticks**: Alternating tick marks rotate dynamically during calculations and align magnetically (a long tick snaps to the 12 o'clock center pointer) upon settling.
- **Enlarged Rounded Arrow**: A modern, mathematically calculated rounded triangle indicator that slides up and fades in with a delay once the calculation settles.
- **Odometer Digit Counter**: A premium odometer flip roll effect for score digits, featuring top and bottom feathered opacity gradients to fade numbers smoothly out of view.
- **Pulsing Loading State**: A gentle looping opacity pulse on the calculation text (e.g. `"CALCULATING..."`) providing active feedback during calculations.
- **Concentric Dynamic Scaling**: All visual elements (track thickness, arrow size, tick lengths, gaps, and typography) scale proportionally relative to the widget's constraints, maintaining perfect concentric balance at any size.
- **Tactile Haptics**: Integrates light platform haptic feedback (`HapticFeedback.lightImpact`) triggered on score value changes.
- **Fully Customizable Style**: Exposes control over track thickness, sweep angle, ticks counts/sizes, arrow sizes, gap distances, and typographic styles through `ScoreGaugeStyle`.
- **Customizable & Localizable Labels**: Completely customizable settled labels and calculating labels (`calculatingLabel`), allowing for easy localization (e.g. `"CALCULANDO..."`).
- **VoiceOver & Accessibility**: Leverages Flutter `Semantics` to announce the score value and qualitative category to screen readers.

#### Integration

```dart
import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';

// 1. Define a helper method to map score values to qualitative labels
String getScoreLabel(double score) {
  if (score < 400) return 'POOR';
  if (score < 600) return 'FAIR';
  if (score < 750) return 'GOOD';
  if (score < 880) return 'VERY GOOD';
  return 'EXCELLENT';
}

// 2. Pass the dynamic label to the ScoreGauge widget
ScoreGauge(
  value: _score, // e.g. 750.0
  min: 300.0,
  max: 850.0,
  label: getScoreLabel(_score),
  calculatingLabel: 'CALCULATING...', // Optional custom loading text
  style: const ScoreGaugeStyle(
    trackThickness: 28.0,
    // Customize colors dynamically (supports any list length)
    trackGradientColors: [
      Color(0xFFFF3B30), // Red
      Color(0xFFFF9500), // Orange
      Color(0xFFFFCC00), // Yellow
      Color(0xFF34C759), // Green
      Color(0xFF5AC8FA), // Blue
    ],
    showTicks: true,
    tickCount: 19,
    labelGap: 8.0,
    animationDuration: Duration(milliseconds: 1400),
  ),
)
```
