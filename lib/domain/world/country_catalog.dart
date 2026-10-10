
import 'country.dart';

class CountryCatalog {
  CountryCatalog._();

  static const List<Country> countries = [
    Country(
      code: 'AU',
      name: 'Australia',
      currencyCode: 'AUD',
    ),
    Country(
      code: 'CA',
      name: 'Canada',
      currencyCode: 'CAD',
    ),
    Country(
      code: 'CN',
      name: 'China',
      currencyCode: 'CNY',
    ),
    Country(
      code: 'FR',
      name: 'France',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'DE',
      name: 'Germany',
      currencyCode: 'EUR',
    ),
    Country(
      code: 'IN',
      name: 'India',
      currencyCode: 'INR',
    ),
    Country(
      code: 'ID',
      name: 'Indonesia',
      currencyCode: 'IDR',
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
      code: 'KR',
      name: 'South Korea',
      currencyCode: 'KRW',
    ),
    Country(
      code: 'GB',
      name: 'United Kingdom',
      currencyCode: 'GBP',
    ),
    Country(
      code: 'US',
      name: 'United States',
      currencyCode: 'USD',
    ),
  ];

  static Country? findByCode(String code) {
    final normalizedCode = code.trim().toUpperCase();

    for (final country in countries) {
      if (country.code == normalizedCode) {
        return country;
      }
    }

    return null;
  }

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
}
