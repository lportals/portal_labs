# Subscription Picker

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
