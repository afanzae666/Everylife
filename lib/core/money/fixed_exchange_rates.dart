
import 'package:everylife/core/money/exchange_rate_snapshot.dart';

/// Fixed gameplay exchange rates for EveryLife.
///
/// The rates are based on historical market references dated
/// 16 October 2026. They are intentionally fixed for gameplay:
/// this class performs no network requests and never refreshes rates.
///
/// Values are local currency minor units per USD 1.00.
/// Currencies with zero fraction digits use whole local units.
class FixedExchangeRates {
  FixedExchangeRates._();

  static final ExchangeRateSnapshot snapshot = ExchangeRateSnapshot(
    asOfDate: DateTime.utc(2026, 10, 16),
    source: 'Fixed gameplay snapshot; historical market references '
        'dated 2026-10-16 (XE, with CUP and RUB cross-checks)',
    minorUnitsPerUsd: {
      'AED': 367,
      'ARS': 151321,
      'AUD': 144,
      'BRL': 509,
      'CAD': 142,
      'CHF': 82,
      'CLP': 984,
      'CNY': 669,
      'COP': 3182,
      'CUP': 2396,
      'DKK': 666,
      'EGP': 5345,
      'ETB': 16281,
      'EUR': 89,
      'FJD': 227,
      'GBP': 75,
      'GHS': 1166,
      'IDR': 18073,
      'INR': 9493,
      'JPY': 158,
      'KES': 12985,
      'KRW': 1334,
      'MAD': 975,
      'MXN': 1850,
      'MYR': 409,
      'NGN': 133147,
      'NOK': 945,
      'NPR': 15196,
      'NZD': 177,
      'PEN': 344,
      'PHP': 6304,
      'PKR': 27684,
      'PLN': 389,
      'RUB': 8308,
      'SAR': 375,
      'SEK': 992,
      'SGD': 128,
      'THB': 3344,
      'TRY': 4952,
      'TZS': 2640,
      'UAH': 4493,
      'USD': 100,
      'VND': 25857,
      'ZAR': 1648,
    },
  );
}
