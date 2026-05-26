# Currency Swap

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
