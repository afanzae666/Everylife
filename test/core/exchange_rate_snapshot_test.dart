
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/exchange_rate_snapshot.dart';

void main() {
  ExchangeRateSnapshot createSnapshot({
    DateTime? asOfDate,
    String source = 'Test rates',
    Map<String, int>? rates,
  }) {
    return ExchangeRateSnapshot(
      asOfDate: asOfDate ?? DateTime.utc(2026, 10, 20),
      source: source,
      minorUnitsPerUsd: rates ??
          {
            'USD': 100,
            'EUR': 9200,
            'IDR': 17000,
          },
    );
  }

  group('ExchangeRateSnapshot', () {
    group('metadata and validation', () {
      test('normalizes the date to UTC midnight', () {
        final snapshot = createSnapshot(
          asOfDate: DateTime.parse('2026-10-20T15:30:00+07:00'),
        );

        expect(
          snapshot.asOfDate,
          DateTime.utc(2026, 10, 20),
        );
        expect(snapshot.asOfDate.isUtc, isTrue);
      });

      test('normalizes currency codes and source', () {
        final snapshot = createSnapshot(
          source: '  Test rates  ',
          rates: {
            'usd': 100,
            ' eur ': 9200,
          },
        );

        expect(snapshot.source, 'Test rates');
        expect(snapshot.rateFor('USD'), 100);
        expect(snapshot.rateFor(' eur '), 9200);
      });

      test('rejects empty currency codes', () {
        expect(
          () => createSnapshot(
            rates: {'': 100},
          ),
          throwsArgumentError,
        );
      });

      test('rejects duplicate codes after normalization', () {
        expect(
          () => createSnapshot(
            rates: {
              'USD': 100,
              ' usd ': 100,
            },
          ),
          throwsArgumentError,
        );
      });

      test('reports valid metadata and rates', () {
        expect(createSnapshot().hasValidData, isTrue);
      });

      test('rejects missing or invalid USD baseline', () {
        expect(
          createSnapshot(
            rates: {'EUR': 9200},
          ).hasValidData,
          isFalse,
        );

        expect(
          createSnapshot(
            rates: {
              'USD': 99,
              'EUR': 9200,
            },
          ).hasValidData,
          isFalse,
        );
      });

      test('rejects empty source and invalid rate values', () {
        expect(
          createSnapshot(source: '  ').hasValidData,
          isFalse,
        );

        expect(
          createSnapshot(
            rates: {
              'USD': 100,
              'EUR': 0,
            },
          ).hasValidData,
          isFalse,
        );

        expect(
          createSnapshot(
            rates: {
              'USD': 100,
              'EUR': -1,
            },
          ).hasValidData,
          isFalse,
        );
      });

      test('rejects currencies absent from the currency catalog', () {
        expect(
          createSnapshot(
            rates: {
              'USD': 100,
              'ZZZ': 500,
            },
          ).hasValidData,
          isFalse,
        );
      });

      test('exposes an immutable rate map', () {
        final snapshot = createSnapshot();

        expect(
          () => snapshot.minorUnitsPerUsd['EUR'] = 1,
          throwsUnsupportedError,
        );
      });
    });

    group('currency conversion', () {
      test('converts USD minor units to Indonesian Rupiah', () {
        final snapshot = createSnapshot();

        expect(
          snapshot.toLocalMinorUnits(
            usdMinorUnits: 100,
            currencyCode: 'IDR',
          ),
          17000,
        );

        expect(
          snapshot.toLocalMinorUnits(
            usdMinorUnits: 1000,
            currencyCode: 'IDR',
          ),
          170000,
        );
      });

      test('converts local minor units back to USD cents', () {
        final snapshot = createSnapshot();

        expect(
          snapshot.toUsdMinorUnits(
            localMinorUnits: 17000,
            currencyCode: 'IDR',
          ),
          100,
        );

        expect(
          snapshot.toUsdMinorUnits(
            localMinorUnits: 9200,
            currencyCode: 'EUR',
          ),
          100,
        );
      });

      test('accepts currency codes regardless of case', () {
        final snapshot = createSnapshot();

        expect(
          snapshot.toLocalMinorUnits(
            usdMinorUnits: 100,
            currencyCode: 'idr',
          ),
          17000,
        );
      });

      test('rounds conversions to the nearest minor unit', () {
        final snapshot = createSnapshot(
          rates: {
            'USD': 100,
            'EUR': 150,
          },
        );

        expect(
          snapshot.toLocalMinorUnits(
            usdMinorUnits: 1,
            currencyCode: 'EUR',
          ),
          2,
        );

        expect(
          snapshot.toLocalMinorUnits(
            usdMinorUnits: -1,
            currencyCode: 'EUR',
          ),
          -2,
        );
      });

      test('preserves negative conversion values', () {
        final snapshot = createSnapshot();

        expect(
          snapshot.toLocalMinorUnits(
            usdMinorUnits: -100,
            currencyCode: 'IDR',
          ),
          -17000,
        );

        expect(
          snapshot.toUsdMinorUnits(
            localMinorUnits: -17000,
            currencyCode: 'IDR',
          ),
          -100,
        );
      });

      test('throws when a requested exchange rate is missing', () {
        final snapshot = createSnapshot();

        expect(
          () => snapshot.toLocalMinorUnits(
            usdMinorUnits: 100,
            currencyCode: 'GBP',
          ),
          throwsArgumentError,
        );

        expect(
          () => snapshot.toUsdMinorUnits(
            localMinorUnits: 100,
            currencyCode: 'GBP',
          ),
          throwsArgumentError,
        );
      });
    });
  });
}
