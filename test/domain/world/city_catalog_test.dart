import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/domain/world/city.dart';
import 'package:everylife/domain/world/city_catalog.dart';
import 'package:everylife/domain/world/country_catalog.dart';

void main() {
group('City', () {
test('accepts valid city data', () {
const city = City(
id: 'id-jakarta',
name: 'Jakarta',
countryCode: 'ID',
isCapital: true,
);

  expect(city.isValid, isTrue);
});

test('rejects an uppercase city identifier', () {
  const city = City(
    id: 'ID-JAKARTA',
    name: 'Jakarta',
    countryCode: 'ID',
  );

  expect(city.isValid, isFalse);
});

test('rejects an invalid country code', () {
  const city = City(
    id: 'id-jakarta',
    name: 'Jakarta',
    countryCode: 'id',
  );

  expect(city.isValid, isFalse);
});

});

group('CityCatalog', () {
test('contains valid data with unique IDs', () {
expect(CityCatalog.hasValidData, isTrue);

  final ids = CityCatalog.cities.map((city) => city.id).toSet();

  expect(ids.length, CityCatalog.cities.length);
});

test('contains exactly 51 cities initially', () {
  expect(CityCatalog.cities, hasLength(51));
});

test('contains exactly seven United States cities', () {
  final cities = CityCatalog.citiesForCountry('US');

  expect(cities, hasLength(7));
  expect(
    cities.map((city) => city.name),
    contains('New York City'),
  );
  expect(
    cities.map((city) => city.name),
    contains('Washington, D.C.'),
  );
});

test('contains four cities for every other country', () {
  for (final country in CountryCatalog.countries) {
    final cities = CityCatalog.citiesForCountry(country.code);

    if (country.code == 'US') {
      expect(cities, hasLength(7));
    } else {
      expect(
        cities,
        hasLength(4),
        reason: '${country.name} should have four starter cities.',
      );
    }
  }
});

test('finds a city by ID without case sensitivity', () {
  final city = CityCatalog.findById('ID-JAKARTA');

  expect(city, isNotNull);
  expect(city!.name, 'Jakarta');
  expect(city.countryCode, 'ID');
  expect(city.isCapital, isTrue);
});

test('returns null for an unknown city ID', () {
  expect(
    CityCatalog.findById('xx-unknown'),
    isNull,
  );
});

test('filters cities by country code', () {
  final cities = CityCatalog.citiesForCountry('id');

  expect(cities, hasLength(4));
  expect(
    cities.every((city) => city.countryCode == 'ID'),
    isTrue,
  );
});

test('searches city names without case sensitivity', () {
  final cities = CityCatalog.searchByName('tok');

  expect(cities, hasLength(1));
  expect(cities.single.name, 'Tokyo');
});

test('can search by name within one country', () {
  final cities = CityCatalog.searchByName(
    'san',
    countryCode: 'US',
  );

  expect(cities, hasLength(1));
  expect(cities.single.name, 'San Francisco');
});

test('returns all cities for an empty unrestricted search', () {
  expect(
    CityCatalog.searchByName(''),
    hasLength(CityCatalog.cities.length),
  );
});

test('contains a capital for every country in the starter catalog', () {
  for (final country in CountryCatalog.countries) {
    final capitals = CityCatalog.citiesForCountry(country.code)
        .where((city) => city.isCapital);

    expect(
      capitals,
      hasLength(1),
      reason: '${country.name} should have one designated capital.',
    );
  }
});

});
}
