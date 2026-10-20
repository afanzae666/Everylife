
import 'package:everylife/core/money/currency_catalog.dart';

/// A dated snapshot of exchange rates used by the simulation.
///
/// Rates are expressed as the number of local minor units equivalent
/// to USD 1.00. For example:
/// - USD: 100 (100 cents)
/// - EUR: 9,200 (assuming 1 USD = 92 EUR, with 2 fraction digits)
/// - IDR: 17,000 (assuming 1 USD = 17,000 IDR, with 0 fraction digits)
///
/// The values above are examples of the rate representation, not
/// verified current exchange rates.
class ExchangeRateSnapshot {
  factory ExchangeRateSnapshot({
    required DateTime asOfDate,
    required String source,
    required Map<String, int> minorUnitsPerUsd,
  }) {
    final normalizedRates = <String, int>{};

    for (final entry in minorUnitsPerUsd.entries) {
      final code = entry.key.trim().toUpperCase();

      if (code.isEmpty) {
        throw ArgumentError.value(
          entry.key,
          'minorUnitsPerUsd',
          'Currency code cannot be empty.',
        );
      }

      if (normalizedRates.containsKey(code)) {
        throw ArgumentError.value(
          entry.key,
          'minorUnitsPerUsd',
          'Duplicate currency code after normalization.',
        );
      }

      normalizedRates[code] = entry.value;
    }

    return ExchangeRateSnapshot._(
      asOfDate: DateTime.utc(
        asOfDate.year,
        asOfDate.month,
        asOfDate.day,
      ),
      source: source.trim(),
      minorUnitsPerUsd: Map.unmodifiable(normalizedRates),
    );
  }

  ExchangeRateSnapshot._({
    required this.asOfDate,
    required this.source,
    required this.minorUnitsPerUsd,
  });

  /// Number of USD minor units in USD 1.00.
  static const int usdMinorUnitsPerMajor = 100;

  /// Date on which this rate snapshot applies, normalized to UTC midnight.
  final DateTime asOfDate;

  /// Description of the rate source or gameplay-rate policy.
  final String source;

  /// Local minor units equivalent to USD 1.00, keyed by ISO currency code.
  final Map<String, int> minorUnitsPerUsd;

  /// Returns the rate for a currency, ignoring input case.
  int? rateFor(String currencyCode) {
    return minorUnitsPerUsd[currencyCode.trim().toUpperCase()];
  }

  /// Indicates whether the snapshot has valid metadata and rate entries.
  bool get hasValidData {
    if (source.isEmpty ||
        !minorUnitsPerUsd.containsKey('USD') ||
        minorUnitsPerUsd['USD'] != usdMinorUnitsPerMajor) {
      return false;
    }

    return minorUnitsPerUsd.entries.every((entry) {
      return CurrencyCatalog.findByCode(entry.key) != null &&
          entry.value > 0;
    });
  }

  /// Converts internal USD minor units to local currency minor units.
  ///
  /// Rounds to the nearest local minor unit. Throws [ArgumentError]
  /// when the snapshot does not contain the requested currency.
  int toLocalMinorUnits({
    required int usdMinorUnits,
    required String currencyCode,
  }) {
    final rate = rateFor(currencyCode);

    if (rate == null) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'No exchange rate is available for this currency.',
      );
    }

    return _divideRounded(
      usdMinorUnits * rate,
      usdMinorUnitsPerMajor,
    );
  }

  /// Converts local currency minor units back to internal USD minor units.
  ///
  /// Rounds to the nearest USD cent. Throws [ArgumentError] when the
  /// snapshot does not contain the requested currency.
  int toUsdMinorUnits({
    required int localMinorUnits,
    required String currencyCode,
  }) {
    final rate = rateFor(currencyCode);

    if (rate == null) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'No exchange rate is available for this currency.',
      );
    }

    return _divideRounded(
      localMinorUnits * usdMinorUnitsPerMajor,
      rate,
    );
  }

  static int _divideRounded(int numerator, int denominator) {
    if (denominator <= 0) {
      throw ArgumentError.value(
        denominator,
        'denominator',
        'Denominator must be positive.',
      );
    }

    if (numerator < 0) {
      return -((-numerator + denominator ~/ 2) ~/ denominator);
    }

    return (numerator + denominator ~/ 2) ~/ denominator;
  }
}
