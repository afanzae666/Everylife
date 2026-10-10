class City {
const City({
required this.id,
required this.name,
required this.countryCode,
this.isCapital = false,
});

/// Stable city identifier, for example: "us-new-york".
final String id;

/// Display name of the city.
final String name;

/// ISO 3166-1 alpha-2 country code.
final String countryCode;

/// Whether this city is the country's capital.
final bool isCapital;

bool get isValid {
return id.trim().isNotEmpty &&
id == id.toLowerCase() &&
name.trim().isNotEmpty &&
countryCode.length == 2 &&
countryCode == countryCode.toUpperCase();
}
}
