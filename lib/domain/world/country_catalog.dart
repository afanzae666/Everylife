import 'country.dart';

class CountryCatalog {
  CountryCatalog._();

  /// Starter country catalog.
  ///
  /// Country codes are stable identifiers because saved character
  /// locations use them.
  static const List<Country> countries = [
    Country(
      code: 'AE',
      name: 'United Arab Emirates',
      currencyCode: 'AED',
    ),
    Country(
      code: 'AR',
      name: 'Argentina',
      currencyCode: 'ARS',
    ),
    Country(
      code: 'AT',
      name: 'Austria',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'AU',
      name: 'Australia',
      currencyCode: 'AUD',
    ),
    Country(
      code: 'BE',
      name: 'Belgium',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'BR',
      name: 'Brazil',
      currencyCode: 'BRL',
    ),
    Country(
      code: 'CA',
      name: 'Canada',
      currencyCode: 'CAD',
    ),
    Country(
      code: 'CH',
      name: 'Switzerland',
      currencyCode: 'CHF',
    ),
    Country(
      code: 'CL',
      name: 'Chile',
      currencyCode: 'CLP',
    ),
    Country(
      code: 'CN',
      name: 'China',
      currencyCode: 'CNY',
    ),
    Country(
      code: 'CO',
      name: 'Colombia',
      currencyCode: 'COP',
    ),
    Country(
      code: 'CU',
      name: 'Cuba',
      currencyCode: 'CUP',
    ),
    Country(
      code: 'DE',
      name: 'Germany',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'DK',
      name: 'Denmark',
      currencyCode: 'DKK',
    ),
    Country(
      code: 'EG',
      name: 'Egypt',
      currencyCode: 'EGP',
    ),
    Country(
      code: 'ES',
      name: 'Spain',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'ET',
      name: 'Ethiopia',
      currencyCode: 'ETB',
    ),
    Country(
      code: 'FJ',
      name: 'Fiji',
      currencyCode: 'FJD',
    ),
    Country(
      code: 'FR',
      name: 'France',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'GB',
      name: 'United Kingdom',
      currencyCode: 'GBP',
    ),
    Country(
      code: 'GH',
      name: 'Ghana',
      currencyCode: 'GHS',
    ),
    Country(
      code: 'GR',
      name: 'Greece',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'ID',
      name: 'Indonesia',
      currencyCode: 'IDR',
    ),
    Country(
      code: 'IE',
      name: 'Ireland',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'IN',
      name: 'India',
      currencyCode: 'INR',
    ),
    Country(
      code: 'IT',
      name: 'Italy',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'JP',
      name: 'Japan',
      currencyCode: 'JPY',
    ),
    Country(
      code: 'KE',
      name: 'Kenya',
      currencyCode: 'KES',
    ),
    Country(
      code: 'KR',
      name: 'South Korea',
      currencyCode: 'KRW',
    ),
    Country(
      code: 'MA',
      name: 'Morocco',
      currencyCode: 'MAD',
    ),
    Country(
      code: 'MC',
      name: 'Monaco',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'MX',
      name: 'Mexico',
      currencyCode: 'MXN',
    ),
    Country(
      code: 'MY',
      name: 'Malaysia',
      currencyCode: 'MYR',
    ),
    Country(
      code: 'NG',
      name: 'Nigeria',
      currencyCode: 'NGN',
    ),
    Country(
      code: 'NL',
      name: 'Netherlands',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'NP',
      name: 'Nepal',
      currencyCode: 'NPR',
    ),
    Country(
      code: 'NO',
      name: 'Norway',
      currencyCode: 'NOK',
    ),
    Country(
      code: 'NZ',
      name: 'New Zealand',
      currencyCode: 'NZD',
    ),
    Country(
      code: 'PK',
      name: 'Pakistan',
      currencyCode: 'PKR',
    ),
    Country(
      code: 'PL',
      name: 'Poland',
      currencyCode: 'PLN',
    ),
    Country(
      code: 'PT',
      name: 'Portugal',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'RU',
      name: 'Russia',
      currencyCode: 'RUB',
    ),
    Country(
      code: 'SA',
      name: 'Saudi Arabia',
      currencyCode: 'SAR',
    ),
    Country(
      code: 'SE',
      name: 'Sweden',
      currencyCode: 'SEK',
    ),
    Country(
      code: 'SG',
      name: 'Singapore',
      currencyCode: 'SGD',
    ),
    Country(
      code: 'TH',
      name: 'Thailand',
      currencyCode: 'THB',
    ),
    Country(
      code: 'TR',
      name: 'Turkey',
      currencyCode: 'TRY',
    ),
    Country(
      code: 'UA',
      name: 'Ukraine',
      currencyCode: 'UAH',
    ),
    Country(
      code: 'US',
      name: 'United States',
      currencyCode: 'USD',
    ),
    Country(
      code: 'VN',
      name: 'Vietnam',
      currencyCode: 'VND',
    ),
    Country(
      code: 'ZA',
      name: 'South Africa',
      currencyCode: 'ZAR',
    ),
    Country(
      code: 'TZ',
      name: 'Tanzania',
      currencyCode: 'TZS',
    ),
    Country(
      code: 'PE',
      name: 'Peru',
      currencyCode: 'PEN',
    ),
    Country(
      code: 'PH',
      name: 'Philippines',
      currencyCode: 'PHP',
    ),
  ];

  /// Finds a country using its ISO alpha-2 code.
  ///
  /// The lookup is case-insensitive.
  static Country? findByCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    for (final country in countries) {
      if (country.code == normalizedCode) {
        return country;
      }
    }

    return null;
  }

  /// Searches country names without case sensitivity.
  ///
  /// An empty query returns the complete country catalog.
  static List<Country> searchByName(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return countries;
    }

    return countries
        .where(
          (country) => country.name
              .toLowerCase()
              .contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  /// Indicates whether all country records are valid and unique.
  static bool get hasValidData {
    final codes = countries
        .map((country) => country.code)
        .toSet();

    return codes.length == countries.length &&
        countries.every((country) => country.isValid);
  }
}
