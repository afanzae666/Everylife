
import 'package:everylife/core/money/currency_catalog.dart';
import 'package:everylife/core/money/exchange_rate_snapshot.dart';
import 'package:everylife/core/money/fixed_exchange_rates.dart';
import 'package:everylife/core/money/money.dart';

/// Formats internally stored USD amounts into a country's display currency.
///
/// Money remains stored as USD minor units. Conversion only affects the
/// displayed value and never changes the original Money instance.
///
/// Formatting is deliberately deterministic and independent of device locale:
/// commas group thousands and periods separate fractional digits.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [money] using the selected ISO 4217 [currencyCode].
  ///
  /// Uses the fixed gameplay exchange-rate snapshot unless a snapshot is
  /// explicitly supplied. Unknown currency codes or missing rates throw
  /// [ArgumentError] rather than silently displaying the wrong currency.
  static String format(
    Money money, {
    required String currencyCode,
    ExchangeRateSnapshot? snapshot,
  }) {
    final currency = CurrencyCatalog.findByCode(currencyCode);

    if (currency == null) {
      throw ArgumentError.value(
        currencyCode,
        'currencyCode',
        'Currency is not present in CurrencyCatalog.',
      );
    }

    final rates = snapshot ?? FixedExchangeRates.snapshot;
    final localMinorUnits = rates.toLocalMinorUnits(
      usdMinorUnits: money.minorUnits,
      currencyCode: currency.code,
    );

    final number = _formatNumber(
      localMinorUnits,
      fractionDigits: currency.fractionDigits,
    );

    // Keep common one-character currency symbols compact (e.g. $100.00,
    // €89.00, ¥158). Multi-character symbols use a separating space.
    final separator = currency.symbol.length == 1 ? '' : ' ';

    return '${
      localMinorUnits < 0 ? '-' : ''
    }${currency.symbol}$separator${number.replaceFirst('-', '')}';
  }

  static String _formatNumber(
    int minorUnits, {
    required int fractionDigits,
  }) {
    final absoluteValue = minorUnits.abs();
    final divisor = _powerOfTen(fractionDigits);
    final wholeUnits = absoluteValue ~/ divisor;
    final fraction = absoluteValue % divisor;

    final groupedWhole = _groupThousands(wholeUnits);
    if (fractionDigits == 0) {
      return '${minorUnits < 0 ? '-' : ''}$groupedWhole';
    }

    final fractionalDigits = fraction
        .toString()
        .padLeft(fractionDigits, '0');

    return '${minorUnits < 0 ? '-' : ''}'
        '$groupedWhole.$fractionalDigits';
  }

  static int _powerOfTen(int exponent) {
    var result = 1;

    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }

    return result;
  }

  static String _groupThousands(int value) {
    final digits = value.toString();
    final result = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result.write(',');
      }
      result.write(digits[i]);
    }

    return result.toString();
  }
}
