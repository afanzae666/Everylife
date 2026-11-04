import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/fixed_exchange_rates.dart';
import 'package:everylife/core/money/game_currency.dart';
import 'package:everylife/domain/world/country_catalog.dart';

void main() {
  group('GameCurrency', () {
    test('keeps USD, EUR and GBP', () {
      expect(GameCurrency.forCountryCurrency('USD'), 'USD');
      expect(GameCurrency.forCountryCurrency('EUR'), 'EUR');
      expect(GameCurrency.forCountryCurrency('GBP'), 'GBP');
    });

    test('every other currency is shown as dollars', () {
      expect(GameCurrency.forCountryCurrency('IDR'), 'USD');
      expect(GameCurrency.forCountryCurrency('JPY'), 'USD');
      expect(GameCurrency.forCountryCurrency(null), 'USD');
      expect(GameCurrency.forCountryCurrency(''), 'USD');
    });

    test('every catalog country resolves to a displayable currency', () {
      for (final country in CountryCatalog.countries) {
        final code = GameCurrency.forCountryCurrency(country.currencyCode);
        expect(GameCurrency.supported, contains(code));
        expect(FixedExchangeRates.snapshot.rateFor(code), isNotNull);
      }
    });
  });
}
