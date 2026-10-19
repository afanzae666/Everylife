
/// Metadata for a currency used by the EveryLife simulation.
///
/// Money is currently stored internally in USD minor units.
/// This catalog only defines how each country's local currency is
/// identified and displayed; exchange-rate conversion is handled
/// separately.
class CurrencyInfo {
  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.fractionDigits,
  });

  /// ISO 4217 currency code.
  final String code;

  /// Human-readable currency name.
  final String name;

  /// Common local display symbol.
  final String symbol;

  /// Number of decimal digits normally shown in the game UI.
  ///
  /// This is a display rule, not the precision used for internal USD
  /// storage. For example, Indonesian Rupiah is normally displayed
  /// without decimal digits.
  final int fractionDigits;

  bool get isValid {
    return code.length == 3 &&
        code == code.toUpperCase() &&
        name.trim().isNotEmpty &&
        symbol.trim().isNotEmpty &&
        fractionDigits >= 0 &&
        fractionDigits <= 4;
  }
}

class CurrencyCatalog {
  CurrencyCatalog._();

  /// Currency metadata for currencies used by the current country catalog.
  ///
  /// Symbols are presentation labels, not unique identifiers.
  /// Always use the ISO currency code for lookup and conversion.
  static const List<CurrencyInfo> currencies = [
    CurrencyInfo(
      code: 'AED',
      name: 'United Arab Emirates Dirham',
      symbol: 'د.إ',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'ARS',
      name: 'Argentine Peso',
      symbol: 'AR\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'CHF',
      name: 'Swiss Franc',
      symbol: 'CHF',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'CLP',
      name: 'Chilean Peso',
      symbol: 'CLP\$',
      fractionDigits: 0,
    ),
    CurrencyInfo(
      code: 'CNY',
      name: 'Chinese Yuan',
      symbol: '¥',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'COP',
      name: 'Colombian Peso',
      symbol: 'COL\$',
      fractionDigits: 0,
    ),
    CurrencyInfo(
      code: 'CUP',
      name: 'Cuban Peso',
      symbol: 'CUP\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'DKK',
      name: 'Danish Krone',
      symbol: 'kr',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'EGP',
      name: 'Egyptian Pound',
      symbol: 'E£',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'ETB',
      name: 'Ethiopian Birr',
      symbol: 'Br',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'FJD',
      name: 'Fijian Dollar',
      symbol: 'FJ\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'GBP',
      name: 'British Pound Sterling',
      symbol: '£',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'GHS',
      name: 'Ghanaian Cedi',
      symbol: 'GH₵',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      fractionDigits: 0,
    ),
    CurrencyInfo(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      fractionDigits: 0,
    ),
    CurrencyInfo(
      code: 'KES',
      name: 'Kenyan Shilling',
      symbol: 'KSh',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      fractionDigits: 0,
    ),
    CurrencyInfo(
      code: 'MAD',
      name: 'Moroccan Dirham',
      symbol: 'د.م.',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'MXN',
      name: 'Mexican Peso',
      symbol: 'MX\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'NGN',
      name: 'Nigerian Naira',
      symbol: '₦',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'NOK',
      name: 'Norwegian Krone',
      symbol: 'kr',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'NPR',
      name: 'Nepalese Rupee',
      symbol: 'रू',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'NZD',
      name: 'New Zealand Dollar',
      symbol: 'NZ\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'PEN',
      name: 'Peruvian Sol',
      symbol: 'S/',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'PHP',
      name: 'Philippine Peso',
      symbol: '₱',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'PKR',
      name: 'Pakistani Rupee',
      symbol: '₨',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'PLN',
      name: 'Polish Złoty',
      symbol: 'zł',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'RUB',
      name: 'Russian Ruble',
      symbol: '₽',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'SAR',
      name: 'Saudi Riyal',
      symbol: 'ر.س',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'SEK',
      name: 'Swedish Krona',
      symbol: 'kr',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'THB',
      name: 'Thai Baht',
      symbol: '฿',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'TRY',
      name: 'Turkish Lira',
      symbol: '₺',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'TZS',
      name: 'Tanzanian Shilling',
      symbol: 'TSh',
      fractionDigits: 0,
    ),
    CurrencyInfo(
      code: 'UAH',
      name: 'Ukrainian Hryvnia',
      symbol: '₴',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'USD',
      name: 'United States Dollar',
      symbol: '\$',
      fractionDigits: 2,
    ),
    CurrencyInfo(
      code: 'VND',
      name: 'Vietnamese Đồng',
      symbol: '₫',
      fractionDigits: 0,
    ),
    CurrencyInfo(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      fractionDigits: 2,
    ),
  ];

  /// Finds a currency by its ISO 4217 code, ignoring input case.
  static CurrencyInfo? findByCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    for (final currency in currencies) {
      if (currency.code == normalizedCode) {
        return currency;
      }
    }

    return null;
  }

  /// Confirms all entries are valid and currency codes are unique.
  static bool get hasValidData {
    final codes = currencies.map((currency) => currency.code).toSet();

    return codes.length == currencies.length &&
        currencies.every((currency) => currency.isValid);
  }
}
