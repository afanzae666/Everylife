import 'city.dart';
import 'country_catalog.dart';

/// Stable catalog of playable cities. Existing city IDs are preserved.
class CityCatalog {
  CityCatalog._();

  /// 139 cities across the 54-country starter catalog.
  /// The United States has seven choices; legacy countries retain their
  /// existing four-city sets, and newly added countries have two or three.
  static const List<City> cities = [
    // Australia — 4 cities
    City(id: 'au-canberra', name: 'Canberra', countryCode: 'AU', isCapital: true),
    City(id: 'au-sydney', name: 'Sydney', countryCode: 'AU'),
    City(id: 'au-melbourne', name: 'Melbourne', countryCode: 'AU'),
    City(id: 'au-brisbane', name: 'Brisbane', countryCode: 'AU'),

    // Canada — 4 cities
    City(id: 'ca-ottawa', name: 'Ottawa', countryCode: 'CA', isCapital: true),
    City(id: 'ca-toronto', name: 'Toronto', countryCode: 'CA'),
    City(id: 'ca-vancouver', name: 'Vancouver', countryCode: 'CA'),
    City(id: 'ca-montreal', name: 'Montreal', countryCode: 'CA'),

    // China — 4 cities
    City(id: 'cn-beijing', name: 'Beijing', countryCode: 'CN', isCapital: true),
    City(id: 'cn-shanghai', name: 'Shanghai', countryCode: 'CN'),
    City(id: 'cn-guangzhou', name: 'Guangzhou', countryCode: 'CN'),
    City(id: 'cn-shenzhen', name: 'Shenzhen', countryCode: 'CN'),

    // France — 4 cities
    City(id: 'fr-paris', name: 'Paris', countryCode: 'FR', isCapital: true),
    City(id: 'fr-marseille', name: 'Marseille', countryCode: 'FR'),
    City(id: 'fr-lyon', name: 'Lyon', countryCode: 'FR'),
    City(id: 'fr-nice', name: 'Nice', countryCode: 'FR'),

    // Germany — 4 cities
    City(id: 'de-berlin', name: 'Berlin', countryCode: 'DE', isCapital: true),
    City(id: 'de-munich', name: 'Munich', countryCode: 'DE'),
    City(id: 'de-hamburg', name: 'Hamburg', countryCode: 'DE'),
    City(id: 'de-frankfurt', name: 'Frankfurt', countryCode: 'DE'),

    // India — 4 cities
    City(id: 'in-new-delhi', name: 'New Delhi', countryCode: 'IN', isCapital: true),
    City(id: 'in-mumbai', name: 'Mumbai', countryCode: 'IN'),
    City(id: 'in-bengaluru', name: 'Bengaluru', countryCode: 'IN'),
    City(id: 'in-kolkata', name: 'Kolkata', countryCode: 'IN'),

    // Indonesia — 4 cities
    City(id: 'id-jakarta', name: 'Jakarta', countryCode: 'ID', isCapital: true),
    City(id: 'id-surabaya', name: 'Surabaya', countryCode: 'ID'),
    City(id: 'id-bandung', name: 'Bandung', countryCode: 'ID'),
    City(id: 'id-yogyakarta', name: 'Yogyakarta', countryCode: 'ID'),

    // Italy — 4 cities
    City(id: 'it-rome', name: 'Rome', countryCode: 'IT', isCapital: true),
    City(id: 'it-milan', name: 'Milan', countryCode: 'IT'),
    City(id: 'it-naples', name: 'Naples', countryCode: 'IT'),
    City(id: 'it-florence', name: 'Florence', countryCode: 'IT'),

    // Japan — 4 cities
    City(id: 'jp-tokyo', name: 'Tokyo', countryCode: 'JP', isCapital: true),
    City(id: 'jp-osaka', name: 'Osaka', countryCode: 'JP'),
    City(id: 'jp-kyoto', name: 'Kyoto', countryCode: 'JP'),
    City(id: 'jp-yokohama', name: 'Yokohama', countryCode: 'JP'),

    // South Korea — 4 cities
    City(id: 'kr-seoul', name: 'Seoul', countryCode: 'KR', isCapital: true),
    City(id: 'kr-busan', name: 'Busan', countryCode: 'KR'),
    City(id: 'kr-incheon', name: 'Incheon', countryCode: 'KR'),
    City(id: 'kr-daegu', name: 'Daegu', countryCode: 'KR'),

    // United Kingdom — 4 cities
    City(id: 'gb-london', name: 'London', countryCode: 'GB', isCapital: true),
    City(id: 'gb-manchester', name: 'Manchester', countryCode: 'GB'),
    City(id: 'gb-birmingham', name: 'Birmingham', countryCode: 'GB'),
    City(id: 'gb-edinburgh', name: 'Edinburgh', countryCode: 'GB'),

    // United States — exactly 7 cities
    City(id: 'us-washington-dc', name: 'Washington, D.C.', countryCode: 'US', isCapital: true),
    City(id: 'us-new-york', name: 'New York City', countryCode: 'US'),
    City(id: 'us-los-angeles', name: 'Los Angeles', countryCode: 'US'),
    City(id: 'us-chicago', name: 'Chicago', countryCode: 'US'),
    City(id: 'us-san-francisco', name: 'San Francisco', countryCode: 'US'),
    City(id: 'us-miami', name: 'Miami', countryCode: 'US'),
    City(id: 'us-las-vegas', name: 'Las Vegas', countryCode: 'US'),

    // United Arab Emirates — 2 cities
    City(id: 'ae-abu-dhabi', name: 'Abu Dhabi', countryCode: 'AE', isCapital: true),
    City(id: 'ae-dubai', name: 'Dubai', countryCode: 'AE'),

    // Argentina — 2 cities
    City(id: 'ar-buenos-aires', name: 'Buenos Aires', countryCode: 'AR', isCapital: true),
    City(id: 'ar-cordoba', name: 'Córdoba', countryCode: 'AR'),

    // Austria — 2 cities
    City(id: 'at-vienna', name: 'Vienna', countryCode: 'AT', isCapital: true),
    City(id: 'at-salzburg', name: 'Salzburg', countryCode: 'AT'),

    // Belgium — 2 cities
    City(id: 'be-brussels', name: 'Brussels', countryCode: 'BE', isCapital: true),
    City(id: 'be-antwerp', name: 'Antwerp', countryCode: 'BE'),

    // Brazil — 3 cities
    City(id: 'br-brasilia', name: 'Brasília', countryCode: 'BR', isCapital: true),
    City(id: 'br-sao-paulo', name: 'São Paulo', countryCode: 'BR'),
    City(id: 'br-rio-de-janeiro', name: 'Rio de Janeiro', countryCode: 'BR'),

    // Switzerland — 2 cities
    City(id: 'ch-bern', name: 'Bern', countryCode: 'CH', isCapital: true),
    City(id: 'ch-zurich', name: 'Zurich', countryCode: 'CH'),

    // Chile — 2 cities
    City(id: 'cl-santiago', name: 'Santiago', countryCode: 'CL', isCapital: true),
    City(id: 'cl-valparaiso', name: 'Valparaíso', countryCode: 'CL'),

    // Colombia — 2 cities
    City(id: 'co-bogota', name: 'Bogotá', countryCode: 'CO', isCapital: true),
    City(id: 'co-medellin', name: 'Medellín', countryCode: 'CO'),

    // Cuba — 2 cities
    City(id: 'cu-havana', name: 'Havana', countryCode: 'CU', isCapital: true),
    City(id: 'cu-santiago-de-cuba', name: 'Santiago de Cuba', countryCode: 'CU'),

    // Denmark — 2 cities
    City(id: 'dk-copenhagen', name: 'Copenhagen', countryCode: 'DK', isCapital: true),
    City(id: 'dk-aarhus', name: 'Aarhus', countryCode: 'DK'),

    // Egypt — 2 cities
    City(id: 'eg-cairo', name: 'Cairo', countryCode: 'EG', isCapital: true),
    City(id: 'eg-alexandria', name: 'Alexandria', countryCode: 'EG'),

    // Spain — 3 cities
    City(id: 'es-madrid', name: 'Madrid', countryCode: 'ES', isCapital: true),
    City(id: 'es-barcelona', name: 'Barcelona', countryCode: 'ES'),
    City(id: 'es-valencia', name: 'Valencia', countryCode: 'ES'),

    // Ethiopia — 2 cities
    City(id: 'et-addis-ababa', name: 'Addis Ababa', countryCode: 'ET', isCapital: true),
    City(id: 'et-dire-dawa', name: 'Dire Dawa', countryCode: 'ET'),

    // Fiji — 2 cities
    City(id: 'fj-suva', name: 'Suva', countryCode: 'FJ', isCapital: true),
    City(id: 'fj-nadi', name: 'Nadi', countryCode: 'FJ'),

    // Ghana — 2 cities
    City(id: 'gh-accra', name: 'Accra', countryCode: 'GH', isCapital: true),
    City(id: 'gh-kumasi', name: 'Kumasi', countryCode: 'GH'),

    // Greece — 2 cities
    City(id: 'gr-athens', name: 'Athens', countryCode: 'GR', isCapital: true),
    City(id: 'gr-thessaloniki', name: 'Thessaloniki', countryCode: 'GR'),

    // Ireland — 2 cities
    City(id: 'ie-dublin', name: 'Dublin', countryCode: 'IE', isCapital: true),
    City(id: 'ie-cork', name: 'Cork', countryCode: 'IE'),

    // Kenya — 2 cities
    City(id: 'ke-nairobi', name: 'Nairobi', countryCode: 'KE', isCapital: true),
    City(id: 'ke-mombasa', name: 'Mombasa', countryCode: 'KE'),

    // Morocco — 2 cities
    City(id: 'ma-rabat', name: 'Rabat', countryCode: 'MA', isCapital: true),
    City(id: 'ma-casablanca', name: 'Casablanca', countryCode: 'MA'),

    // Monaco — 2 cities
    City(id: 'mc-monaco', name: 'Monaco', countryCode: 'MC', isCapital: true),
    City(id: 'mc-monte-carlo', name: 'Monte Carlo', countryCode: 'MC'),

    // Mexico — 3 cities
    City(id: 'mx-mexico-city', name: 'Mexico City', countryCode: 'MX', isCapital: true),
    City(id: 'mx-guadalajara', name: 'Guadalajara', countryCode: 'MX'),
    City(id: 'mx-monterrey', name: 'Monterrey', countryCode: 'MX'),

    // Malaysia — 2 cities
    City(id: 'my-kuala-lumpur', name: 'Kuala Lumpur', countryCode: 'MY', isCapital: true),
    City(id: 'my-george-town', name: 'George Town', countryCode: 'MY'),

    // Nigeria — 2 cities
    City(id: 'ng-abuja', name: 'Abuja', countryCode: 'NG', isCapital: true),
    City(id: 'ng-lagos', name: 'Lagos', countryCode: 'NG'),

    // Netherlands — 2 cities
    City(id: 'nl-amsterdam', name: 'Amsterdam', countryCode: 'NL', isCapital: true),
    City(id: 'nl-rotterdam', name: 'Rotterdam', countryCode: 'NL'),

    // Nepal — 2 cities
    City(id: 'np-kathmandu', name: 'Kathmandu', countryCode: 'NP', isCapital: true),
    City(id: 'np-pokhara', name: 'Pokhara', countryCode: 'NP'),

    // Norway — 2 cities
    City(id: 'no-oslo', name: 'Oslo', countryCode: 'NO', isCapital: true),
    City(id: 'no-bergen', name: 'Bergen', countryCode: 'NO'),

    // New Zealand — 2 cities
    City(id: 'nz-wellington', name: 'Wellington', countryCode: 'NZ', isCapital: true),
    City(id: 'nz-auckland', name: 'Auckland', countryCode: 'NZ'),

    // Pakistan — 2 cities
    City(id: 'pk-islamabad', name: 'Islamabad', countryCode: 'PK', isCapital: true),
    City(id: 'pk-karachi', name: 'Karachi', countryCode: 'PK'),

    // Poland — 2 cities
    City(id: 'pl-warsaw', name: 'Warsaw', countryCode: 'PL', isCapital: true),
    City(id: 'pl-krakow', name: 'Kraków', countryCode: 'PL'),

    // Portugal — 2 cities
    City(id: 'pt-lisbon', name: 'Lisbon', countryCode: 'PT', isCapital: true),
    City(id: 'pt-porto', name: 'Porto', countryCode: 'PT'),

    // Russia — 3 cities
    City(id: 'ru-moscow', name: 'Moscow', countryCode: 'RU', isCapital: true),
    City(id: 'ru-saint-petersburg', name: 'Saint Petersburg', countryCode: 'RU'),
    City(id: 'ru-novosibirsk', name: 'Novosibirsk', countryCode: 'RU'),

    // Saudi Arabia — 2 cities
    City(id: 'sa-riyadh', name: 'Riyadh', countryCode: 'SA', isCapital: true),
    City(id: 'sa-jeddah', name: 'Jeddah', countryCode: 'SA'),

    // Sweden — 2 cities
    City(id: 'se-stockholm', name: 'Stockholm', countryCode: 'SE', isCapital: true),
    City(id: 'se-gothenburg', name: 'Gothenburg', countryCode: 'SE'),

    // Singapore — 2 cities
    City(id: 'sg-singapore', name: 'Singapore', countryCode: 'SG', isCapital: true),
    City(id: 'sg-jurong-east', name: 'Jurong East', countryCode: 'SG'),

    // Thailand — 2 cities
    City(id: 'th-bangkok', name: 'Bangkok', countryCode: 'TH', isCapital: true),
    City(id: 'th-chiang-mai', name: 'Chiang Mai', countryCode: 'TH'),

    // Turkey — 2 cities
    City(id: 'tr-ankara', name: 'Ankara', countryCode: 'TR', isCapital: true),
    City(id: 'tr-istanbul', name: 'Istanbul', countryCode: 'TR'),

    // Ukraine — 2 cities
    City(id: 'ua-kyiv', name: 'Kyiv', countryCode: 'UA', isCapital: true),
    City(id: 'ua-lviv', name: 'Lviv', countryCode: 'UA'),

    // Vietnam — 2 cities
    City(id: 'vn-hanoi', name: 'Hanoi', countryCode: 'VN', isCapital: true),
    City(id: 'vn-ho-chi-minh-city', name: 'Ho Chi Minh City', countryCode: 'VN'),

    // South Africa — 2 cities
    City(id: 'za-pretoria', name: 'Pretoria', countryCode: 'ZA', isCapital: true),
    City(id: 'za-cape-town', name: 'Cape Town', countryCode: 'ZA'),

    // Tanzania — 2 cities
    City(id: 'tz-dodoma', name: 'Dodoma', countryCode: 'TZ', isCapital: true),
    City(id: 'tz-dar-es-salaam', name: 'Dar es Salaam', countryCode: 'TZ'),

    // Peru — 2 cities
    City(id: 'pe-lima', name: 'Lima', countryCode: 'PE', isCapital: true),
    City(id: 'pe-cusco', name: 'Cusco', countryCode: 'PE'),

    // Philippines — 2 cities
    City(id: 'ph-manila', name: 'Manila', countryCode: 'PH', isCapital: true),
    City(id: 'ph-cebu-city', name: 'Cebu City', countryCode: 'PH'),
  ];

  static City? findById(String id) {
    final normalizedId = id.trim().toLowerCase();

    for (final city in cities) {
      if (city.id == normalizedId) return city;
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
    final countryCodes =
        CountryCatalog.countries.map((country) => country.code).toSet();
    final capitalsByCountry = <String, int>{};

    for (final city in cities) {
      if (city.isCapital) {
        capitalsByCountry.update(
          city.countryCode,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return ids.length == cities.length &&
        cities.every(
          (city) => city.isValid && countryCodes.contains(city.countryCode),
        ) &&
        CountryCatalog.countries.every(
          (country) =>
              citiesForCountry(country.code).isNotEmpty &&
              capitalsByCountry[country.code] == 1,
        );
  }
}
