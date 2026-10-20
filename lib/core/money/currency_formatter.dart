
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
  /// Values below one billion are displayed in full, with thousands grouped.
  /// Unnecessary trailing decimal zeroes are omitted, but meaningful
  /// fractional digits are preserved.
  ///
  /// Values from one billion onward use compact suffixes such as B and T.
  /// Compact values retain up to two decimal places and omit trailing zeroes.
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
    final wholeUnits = absoluteMinorUnits ~/ divisor;
    final remainder = absoluteMinorUnits % divisor;

    final String number;

    if (wholeUnits >= _billion) {
      number = _formatCompact(wholeUnits);
    } else {
      final wholePart = _groupThousands(wholeUnits);

      if (remainder == 0 || currency.fractionDigits == 0) {
        number = wholePart;
      } else {
        final fraction = remainder
            .toString()
            .padLeft(currency.fractionDigits, '0')
            .replaceFirst(RegExp(r'0+$'), '');

        number = '$wholePart.$fraction';
      }
    }

    final separator = currency.symbol.length == 1 ? '' : ' ';
    final sign = localMinorUnits < 0 ? '-' : '';

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

    final formatted = scaled.toStringAsFixed(2);
    final trimmed = formatted
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');

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
