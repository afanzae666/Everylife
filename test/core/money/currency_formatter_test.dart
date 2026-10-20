
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/currency_formatter.dart';
import 'package:everylife/core/money/exchange_rate_snapshot.dart';
import 'package:everylife/core/money/money.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats USD using the internal baseline', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'USD',
        ),
        r'$1.00',
      );
    });

    test('formats EUR using the fixed exchange rate', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'EUR',
        ),
        '€0.89',
      );
    });

    test('formats Indonesian Rupiah without decimal digits', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'IDR',
        ),
        'Rp 18,073',
      );
    });

    test('formats Japanese Yen without decimal digits', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'JPY',
        ),
        '¥158',
      );
    });

    test('groups thousands and preserves fractional digits', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(1234500),
          currencyCode: 'USD',
        ),
        r'$12,345.00',
      );
    });

    test('formats negative values correctly', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(-100),
          currencyCode: 'EUR',
        ),
        '-€0.89',
      );

      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(-100),
          currencyCode: 'IDR',
        ),
        '-Rp 18,073',
      );
    });

    test('accepts lowercase currency codes', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'idr',
        ),
        'Rp 18,073',
      );
    });

    test('rejects an unknown currency code', () {
      expect(
        () => CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'ZZZ',
        ),
        throwsArgumentError,
      );
    });

    test('rejects a currency with no rate in the supplied snapshot', () {
      final snapshot = ExchangeRateSnapshot(
        asOfDate: DateTime.utc(2026, 10, 16),
        source: 'Formatter test',
        minorUnitsPerUsd: const {'USD': 100},
      );

      expect(
        () => CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'EUR',
          snapshot: snapshot,
        ),
        throwsArgumentError,
      );
    });

    test('does not modify the original Money value', () {
      const money = Money.fromMinorUnits(100);

      CurrencyFormatter.format(
        money,
        currencyCode: 'IDR',
      );

      expect(money.minorUnits, 100);
    });
  });
}
