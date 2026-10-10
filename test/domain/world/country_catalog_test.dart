
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/domain/world/country.dart';
import 'package:everylife/domain/world/country_catalog.dart';

void main() {
  group('Country', () {
    test('accepts valid country data', () {
      const country = Country(
        code: 'ID',
        name: 'Indonesia',
        currencyCode: 'IDR',
      );

      expect(country.isValid, isTrue);
    });

    test('rejects invalid country data', () {
      const country = Country(
        code: 'id',
        name: 'Indonesia',
        currencyCode: 'IDR',
      );

      expect(country.isValid, isFalse);
    });
  });

  group('CountryCatalog', () {
    test('finds country by code regardless of input case', () {
      final country = CountryCatalog.findByCode('id');

      expect(country, isNotNull);
      expect(country!.name, 'Indonesia');
      expect(country.currencyCode, 'IDR');
    });

    test('returns null for an unknown country code', () {
      expect(
        CountryCatalog.findByCode('ZZ'),
        isNull,
      );
    });

    test('searches country names without case sensitivity', () {
      final results = CountryCatalog.searchByName('jap');

      expect(results, hasLength(1));
      expect(results.single.name, 'Japan');
    });

    test('returns all countries for an empty search', () {
      expect(
        CountryCatalog.searchByName(''),
        hasLength(CountryCatalog.countries.length),
      );
    });
  });
}
