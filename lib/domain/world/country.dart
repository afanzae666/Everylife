
class Country {
  const Country({
    required this.code,
    required this.name,
    required this.currencyCode,
  });

  /// Stable ISO 3166-1 alpha-2 country code.
  final String code;

  /// Display name of the country.
  final String name;

  /// ISO 4217 currency code.
  final String currencyCode;

  bool get isValid {
    return code.length == 2 &&
        code == code.toUpperCase() &&
        name.trim().isNotEmpty &&
        currencyCode.length == 3 &&
        currencyCode == currencyCode.toUpperCase();
  }
}
