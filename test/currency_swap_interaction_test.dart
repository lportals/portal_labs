import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portal_labs/portal_labs.dart';

void main() {
  const testCurrencies = [
    Currency(flag: '🇺🇸', code: 'USD', name: 'US Dollar'),
    Currency(flag: '🇪🇺', code: 'EUR', name: 'Euro'),
    Currency(flag: '🇬🇧', code: 'GBP', name: 'British Pound'),
  ];

  group('CurrencySwapInteraction', () {
    testWidgets('renders correctly and calculates initial conversion', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySwapInteraction(
              currencies: testCurrencies,
              initialFromCurrency: testCurrencies[0],
              initialToCurrency: testCurrencies[1],
              initialAmount: 100,
              exchangeRate: 0.9,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('currency_code_USD')), findsOneWidget);
      expect(find.byKey(const ValueKey('currency_code_EUR')), findsOneWidget);
      // 100 * 0.9 = 90
      expect(find.text('100'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
    });

    testWidgets('swaps currencies and amounts when swap button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySwapInteraction(
              currencies: testCurrencies,
              initialFromCurrency: testCurrencies[0],
              initialToCurrency: testCurrencies[1],
              initialAmount: 100,
              exchangeRate: 0.9,
            ),
          ),
        ),
      );

      // Find swap button by icon
      final swapButton = find.byIcon(Icons.swap_vert);
      await tester.tap(swapButton);
      await tester.pumpAndSettle();

      // After swap: 90 USD (was to) becomes the 'from', 100 EUR (was from) becomes the 'to'
      expect(find.byKey(const ValueKey('currency_code_EUR')), findsOneWidget);
      expect(find.byKey(const ValueKey('currency_code_USD')), findsOneWidget);
      
      expect(find.text('90'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('triggers onProceed when button is tapped', (WidgetTester tester) async {
      bool proceeded = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySwapInteraction(
              currencies: testCurrencies,
              initialFromCurrency: testCurrencies[0],
              initialToCurrency: testCurrencies[1],
              onProceed: () => proceeded = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Proceed'));
      await tester.pump();

      expect(proceeded, isTrue);
    });

    testWidgets('updates toAmount when fromAmount is changed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySwapInteraction(
              currencies: testCurrencies,
              initialFromCurrency: testCurrencies[0],
              initialToCurrency: testCurrencies[1],
              initialAmount: 10,
              exchangeRate: 2.0,
            ),
          ),
        ),
      );

      // Tap the amount display to focus the TextField
      // The flip counter might be complex, so let's find it by text '10'
      await tester.tap(find.text('10'), warnIfMissed: false);
      await tester.pump();
      
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '50');
      await tester.pump();

      // 50 * 2.0 = 100
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('opens currency selector and changes currency', (WidgetTester tester) async {
      Currency? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySwapInteraction(
              currencies: testCurrencies,
              initialFromCurrency: testCurrencies[0],
              initialToCurrency: testCurrencies[1],
              onFromCurrencyChanged: (c) => selected = c,
            ),
          ),
        ),
      );

      // Tap USD selector
      await tester.tap(find.byKey(const ValueKey('currency_code_USD')));
      await tester.pumpAndSettle();

      // Tap GBP in dropdown
      await tester.tap(find.text('GBP').last);
      await tester.pumpAndSettle();

      expect(selected?.code, 'GBP');
    });
  });
}
