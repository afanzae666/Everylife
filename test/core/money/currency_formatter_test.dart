
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/currency_formatter.dart';
import 'package:everylife/core/money/exchange_rate_snapshot.dart';
import 'package:everylife/core/money/money.dart';

void main() {
  group('CurrencyFormatter', () {
    test('omits unnecessary decimal zeroes for USD', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(100),
          currencyCode: 'USD',
        ),
        r'$1',
      );
    });

    test('preserves meaningful EUR fractional digits', () {
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

    test('groups thousands and omits unnecessary decimal zeroes', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(1234500),
          currencyCode: 'USD',
        ),
        r'$12,345',
      );
    });

    test('preserves meaningful fractional cents', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(1),
          currencyCode: 'USD',
        ),
        r'$0.01',
      );
    });

    test('formats compact values from one billion onward', () {
      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(100000000000),
          currencyCode: 'USD',
        ),
        r'$1B',
      );

      expect(
        CurrencyFormatter.format(
          const Money.fromMinorUnits(125000000000),
          currencyCode: 'USD',
        ),
        r'$1.25B',
      );
    });

    test('formats negative values and preserves fractional digits', () {
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
