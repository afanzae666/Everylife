import 'city_catalog.dart';
import 'country_catalog.dart';

/// The character's current country and city.
///
/// This model is intentionally separate from Character until
/// location is integrated into gameplay and save/load.
class CharacterLocation {
const CharacterLocation({
required this.countryCode,
required this.cityId,
});

/// ISO 3166-1 alpha-2 country code, for example "ID".
final String countryCode;

/// Stable city ID, for example "id-jakarta".
final String cityId;

bool get isValid {
final normalizedCountryCode = countryCode.trim().toUpperCase();

if (CountryCatalog.findByCode(normalizedCountryCode) == null) {
  return false;
}

final city = CityCatalog.findById(cityId);

if (city == null) {
  return false;
}

return city.countryCode == normalizedCountryCode;

}

bool belongsToCountry(String code) {
final normalizedCode = code.trim().toUpperCase();

return isValid && countryCode.trim().toUpperCase() == normalizedCode;

}
}
