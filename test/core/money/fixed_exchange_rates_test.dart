
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/currency_catalog.dart';
import 'package:everylife/core/money/fixed_exchange_rates.dart';
import 'package:everylife/domain/world/country_catalog.dart';

void main() {
  group('FixedExchangeRates', () {
    final snapshot = FixedExchangeRates.snapshot;

    test('provides valid fixed rate data', () {
      expect(snapshot.hasValidData, isTrue);
      expect(snapshot.asOfDate, DateTime.utc(2026, 10, 16));
      expect(snapshot.source, isNotEmpty);
    });

    test('includes every currency in CurrencyCatalog', () {
      final catalogCodes = CurrencyCatalog.currencies
          .map((currency) => currency.code)
          .toSet();

      expect(
        snapshot.minorUnitsPerUsd.keys.toSet(),
        equals(catalogCodes),
      );
    });

    test('includes a rate for every country currency', () {
      for (final country in CountryCatalog.countries) {
        expect(
          snapshot.rateFor(country.currencyCode),
          isNotNull,
          reason:
              '${country.name} (${country.code}) has no fixed rate '
              'for ${country.currencyCode}.',
        );
      }
    });

    test('uses USD as the internal baseline', () {
      expect(snapshot.rateFor('USD'), 100);
    });

    test('contains the expected fixed example rates', () {
      expect(snapshot.rateFor('EUR'), 89);
      expect(snapshot.rateFor('IDR'), 18073);
      expect(snapshot.rateFor('JPY'), 158);
    });

    test('converts USD cents into local currency minor units', () {
      expect(
        snapshot.toLocalMinorUnits(
          usdMinorUnits: 100,
          currencyCode: 'EUR',
        ),
        89,
      );

      expect(
        snapshot.toLocalMinorUnits(
          usdMinorUnits: 100,
          currencyCode: 'IDR',
        ),
        18073,
      );
    });

    test('converts local currency minor units back to USD cents', () {
      expect(
        snapshot.toUsdMinorUnits(
          localMinorUnits: 89,
          currencyCode: 'EUR',
        ),
        100,
      );

      expect(
        snapshot.toUsdMinorUnits(
          localMinorUnits: 18073,
          currencyCode: 'IDR',
        ),
        100,
      );
    });

    test('reuses the same fixed snapshot', () {
      expect(FixedExchangeRates.snapshot, same(snapshot));
    });
  });
}
