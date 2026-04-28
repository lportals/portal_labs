import 'package:flutter/material.dart';
import 'package:portal_labs/portal_labs.dart';
import '../showcase_shell.dart';

class CurrencySwapShowcase extends StatefulWidget {
  const CurrencySwapShowcase({super.key});

  @override
  State<CurrencySwapShowcase> createState() => _CurrencySwapShowcaseState();
}

class _CurrencySwapShowcaseState extends State<CurrencySwapShowcase> {
  final List<Currency> _currencies = const [
    Currency(code: 'USD', flag: '🇺🇸', name: 'US Dollar'),
    Currency(code: 'EUR', flag: '🇪🇺', name: 'Euro'),
    Currency(code: 'GBP', flag: '🇬🇧', name: 'British Pound'),
    Currency(code: 'JPY', flag: '🇯🇵', name: 'Japanese Yen'),
    Currency(code: 'CHF', flag: '🇨🇭', name: 'Swiss Franc'),
  ];

  late Currency _fromCurrency;
  late Currency _toCurrency;
  double _currentRate = 0.85;

  final Map<String, double> _usdRates = {
    'USD': 1.0,
    'EUR': 0.85,
    'GBP': 0.74,
    'JPY': 159.36,
    'CHF': 0.79,
  };

  @override
  void initState() {
    super.initState();
    _fromCurrency = _currencies[0];
    _toCurrency = _currencies[1];
    _updateRate(_fromCurrency, _toCurrency);
  }

  void _updateRate(Currency from, Currency to) {
    setState(() {
      _fromCurrency = from;
      _toCurrency = to;
      final fromRate = _usdRates[from.code] ?? 1.0;
      final toRate = _usdRates[to.code] ?? 1.0;
      _currentRate = (1.0 / fromRate) * toRate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Currency Swap',
      backgroundColor: const Color(0xFFF0F2F5),
      description:
          'Premium currency conversion interface with custom flag dropdowns and '
          'real-time mechanical flip counters. High-performance overlay menu with '
          'zero layout jank and fully customizable style.',
      codeSnippet: '''CurrencySwapInteraction(
  currencies: _currencies,
  initialFromCurrency: _fromCurrency,
  initialToCurrency: _toCurrency,
  exchangeRate: _rate,
  onFromCurrencyChanged: (c) => _updateRate(c, _toCurrency),
  onToCurrencyChanged: (c) => _updateRate(_fromCurrency, c),
  onProceed: () => print('Processing...'),
)''',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: CurrencySwapInteraction(
              currencies: _currencies,
              initialFromCurrency: _fromCurrency,
              initialToCurrency: _toCurrency,
              exchangeRate: _currentRate,
              onFromCurrencyChanged: (c) => _updateRate(c, _toCurrency),
              onToCurrencyChanged: (c) => _updateRate(_fromCurrency, c),
              onProceed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing conversion...')),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
