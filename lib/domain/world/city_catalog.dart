import 'city.dart';
import 'country_catalog.dart';

class CityCatalog {
CityCatalog._();

static const List<City> cities = [
// Australia — 4 cities
City(
id: 'au-canberra',
name: 'Canberra',
countryCode: 'AU',
isCapital: true,
),
City(
id: 'au-sydney',
name: 'Sydney',
countryCode: 'AU',
),
City(
id: 'au-melbourne',
name: 'Melbourne',
countryCode: 'AU',
),
City(
id: 'au-brisbane',
name: 'Brisbane',
countryCode: 'AU',
),

// Canada — 4 cities
City(
  id: 'ca-ottawa',
  name: 'Ottawa',
  countryCode: 'CA',
  isCapital: true,
),
City(
  id: 'ca-toronto',
  name: 'Toronto',
  countryCode: 'CA',
),
City(
  id: 'ca-vancouver',
  name: 'Vancouver',
  countryCode: 'CA',
),
City(
  id: 'ca-montreal',
  name: 'Montreal',
  countryCode: 'CA',
),

// China — 4 cities
City(
  id: 'cn-beijing',
  name: 'Beijing',
  countryCode: 'CN',
  isCapital: true,
),
City(
  id: 'cn-shanghai',
  name: 'Shanghai',
  countryCode: 'CN',
),
City(
  id: 'cn-guangzhou',
  name: 'Guangzhou',
  countryCode: 'CN',
),
City(
  id: 'cn-shenzhen',
  name: 'Shenzhen',
  countryCode: 'CN',
),

// France — 4 cities
City(
  id: 'fr-paris',
  name: 'Paris',
  countryCode: 'FR',
  isCapital: true,
),
City(
  id: 'fr-marseille',
  name: 'Marseille',
  countryCode: 'FR',
),
City(
  id: 'fr-lyon',
  name: 'Lyon',
  countryCode: 'FR',
),
City(
  id: 'fr-nice',
  name: 'Nice',
  countryCode: 'FR',
),

// Germany — 4 cities
City(
  id: 'de-berlin',
  name: 'Berlin',
  countryCode: 'DE',
  isCapital: true,
),
City(
  id: 'de-munich',
  name: 'Munich',
  countryCode: 'DE',
),
City(
  id: 'de-hamburg',
  name: 'Hamburg',
  countryCode: 'DE',
),
City(
  id: 'de-frankfurt',
  name: 'Frankfurt',
  countryCode: 'DE',
),

// India — 4 cities
City(
  id: 'in-new-delhi',
  name: 'New Delhi',
  countryCode: 'IN',
  isCapital: true,
),
City(
  id: 'in-mumbai',
  name: 'Mumbai',
  countryCode: 'IN',
),
City(
  id: 'in-bengaluru',
  name: 'Bengaluru',
  countryCode: 'IN',
),
City(
  id: 'in-kolkata',
  name: 'Kolkata',
  countryCode: 'IN',
),

// Indonesia — 4 cities
City(
  id: 'id-jakarta',
  name: 'Jakarta',
  countryCode: 'ID',
  isCapital: true,
),
City(
  id: 'id-surabaya',
  name: 'Surabaya',
  countryCode: 'ID',
),
City(
  id: 'id-bandung',
  name: 'Bandung',
  countryCode: 'ID',
),
City(
  id: 'id-yogyakarta',
  name: 'Yogyakarta',
  countryCode: 'ID',
),

// Italy — 4 cities
City(
  id: 'it-rome',
  name: 'Rome',
  countryCode: 'IT',
  isCapital: true,
),
City(
  id: 'it-milan',
  name: 'Milan',
  countryCode: 'IT',
),
City(
  id: 'it-naples',
  name: 'Naples',
  countryCode: 'IT',
),
City(
  id: 'it-florence',
  name: 'Florence',
  countryCode: 'IT',
),

// Japan — 4 cities
City(
  id: 'jp-tokyo',
  name: 'Tokyo',
  countryCode: 'JP',
  isCapital: true,
),
City(
  id: 'jp-osaka',
  name: 'Osaka',
  countryCode: 'JP',
),
City(
  id: 'jp-kyoto',
  name: 'Kyoto',
  countryCode: 'JP',
),
City(
  id: 'jp-yokohama',
  name: 'Yokohama',
  countryCode: 'JP',
),

// South Korea — 4 cities
City(
  id: 'kr-seoul',
  name: 'Seoul',
  countryCode: 'KR',
  isCapital: true,
),
City(
  id: 'kr-busan',
  name: 'Busan',
  countryCode: 'KR',
),
City(
  id: 'kr-incheon',
  name: 'Incheon',
  countryCode: 'KR',
),
City(
  id: 'kr-daegu',
  name: 'Daegu',
  countryCode: 'KR',
),

// United Kingdom — 4 cities
City(
  id: 'gb-london',
  name: 'London',
  countryCode: 'GB',
  isCapital: true,
),
City(
  id: 'gb-manchester',
  name: 'Manchester',
  countryCode: 'GB',
),
City(
  id: 'gb-birmingham',
  name: 'Birmingham',
  countryCode: 'GB',
),
City(
  id: 'gb-edinburgh',
  name: 'Edinburgh',
  countryCode: 'GB',
),

// United States — exactly 7 cities
City(
  id: 'us-washington-dc',
  name: 'Washington, D.C.',
  countryCode: 'US',
  isCapital: true,
),
City(
  id: 'us-new-york',
  name: 'New York City',
  countryCode: 'US',
),
City(
  id: 'us-los-angeles',
  name: 'Los Angeles',
  countryCode: 'US',
),
City(
  id: 'us-chicago',
  name: 'Chicago',
  countryCode: 'US',
),
City(
  id: 'us-san-francisco',
  name: 'San Francisco',
  countryCode: 'US',
),
City(
  id: 'us-miami',
  name: 'Miami',
  countryCode: 'US',
),
City(
  id: 'us-las-vegas',
  name: 'Las Vegas',
  countryCode: 'US',
),

];

static City? findById(String id) {
final normalizedId = id.trim().toLowerCase();

for (final city in cities) {
  if (city.id == normalizedId) {
    return city;
  }
}

return null;

}

static List<City> citiesForCountry(String countryCode) {
final normalizedCode = countryCode.trim().toUpperCase();

return cities
    .where((city) => city.countryCode == normalizedCode)
    .toList(growable: false);

}

static List<City> searchByName(
String query, {
String? countryCode,
}) {
final normalizedQuery = query.trim().toLowerCase();
final normalizedCountryCode = countryCode?.trim().toUpperCase();

return cities.where((city) {
  final matchesName = normalizedQuery.isEmpty ||
      city.name.toLowerCase().contains(normalizedQuery);

  final matchesCountry = normalizedCountryCode == null ||
      normalizedCountryCode.isEmpty ||
      city.countryCode == normalizedCountryCode;

  return matchesName && matchesCountry;
}).toList(growable: false);

}

static bool get hasValidData {
final ids = cities.map((city) => city.id).toSet();

return ids.length == cities.length &&
    cities.every(
      (city) =>
          city.isValid &&
          CountryCatalog.findByCode(city.countryCode) != null,
    );

}
}
