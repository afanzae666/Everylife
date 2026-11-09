import '../../domain/world/city_catalog.dart';
import '../../domain/world/country_catalog.dart';

/// Where an NPC lives, as "Country, City". The city is steady for each
/// person: it comes from their id, so it never changes between screens.
abstract final class NpcPlace {
  static int _seed(String id) {
    var seed = 17;

    for (final unit in id.codeUnits) {
      seed = (seed * 31 + unit) & 0x3fffffff;
    }

    return seed;
  }

  /// [sameHome] puts the person in the player's own city (family members).
  /// Other people in the player's country live there about two times in
  /// three.
  static String label({
    required String countryCode,
    required String id,
    String? homeCityId,
    bool sameHome = false,
  }) {
    final country = CountryCatalog.findByCode(countryCode)?.name ?? countryCode;
    final home = homeCityId == null ? null : CityCatalog.findById(homeCityId);
    final seed = _seed(id);

    if (home != null && home.countryCode == countryCode.toUpperCase()) {
      if (sameHome || seed % 3 != 0) return '$country, ${home.name}';
    }

    final cities = CityCatalog.citiesForCountry(countryCode);

    if (cities.isEmpty) return country;

    return '$country, ${cities[seed % cities.length].name}';
  }
}
