
import 'package:everylife/core/money/currency_catalog.dart';
import 'package:everylife/core/money/exchange_rate_snapshot.dart';
import 'package:everylife/core/money/fixed_exchange_rates.dart';
import 'package:everylife/core/money/money.dart';

/// Formats internally stored USD amounts into a country's display currency.
///
/// Money remains stored as USD minor units. Conversion only affects display
/// and never changes the original Money instance.
class CurrencyFormatter {
  CurrencyFormatter._();

  static const int _billion = 1000000000;

  static const List<String> _compactUnits = [
    'B',
    'T',
    'Qa',
    'Qi',
    'Sx',
    'Sp',
    'Oc',
    'No',
    'Dc',
    'Ud',
    'Dd',
    'Td',
    'Qad',
    'Qid',
    'Sxd',
    'Spd',
    'Ocd',
    'Nod',
    'Vg',
  ];

  /// Formats [money] using the selected ISO 4217 [currencyCode].
  ///
  /// Values below one billion are displayed as whole local currency units.
  /// Values from one billion onward use compact suffixes such as B and T.
  /// Trailing decimal zeroes are omitted from compact values.
  ///
  /// Uses the fixed gameplay exchange-rate snapshot unless [snapshot] is
  /// supplied. Unknown currencies or missing exchange rates throw an
  /// [ArgumentError].
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

    final divisor = _powerOfTen(currency.fractionDigits);
    final absoluteMinorUnits = localMinorUnits.abs();

    // Round to the nearest whole local currency unit for display.
    final wholeUnits = (absoluteMinorUnits + divisor ~/ 2) ~/ divisor;
    final isNegative = localMinorUnits < 0;

    final number = wholeUnits >= _billion
        ? _formatCompact(wholeUnits)
        : _groupThousands(wholeUnits);

    final separator = currency.symbol.length == 1 ? '' : ' ';
    final sign = isNegative ? '-' : '';

    return '$sign${currency.symbol}$separator$number';
  }

  static String _formatCompact(int value) {
    var scaled = value / _billion;
    var unitIndex = 0;

    while (
      scaled >= 1000 &&
      unitIndex < _compactUnits.length - 1
    ) {
      scaled /= 1000;
      unitIndex++;
    }

    final formatted = scaled >= 100
        ? scaled.toStringAsFixed(0)
        : scaled >= 10
            ? scaled.toStringAsFixed(1)
            : scaled.toStringAsFixed(2);

    final trimmed = formatted.contains('.')
        ? formatted
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), '')
        : formatted;

    return '$trimmed${_compactUnits[unitIndex]}';
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
