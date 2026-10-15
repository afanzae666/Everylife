/// Provides country-aware formatting for character names.
class CulturalNameCatalog {
  CulturalNameCatalog._();

  /// Countries that conventionally place the family name before the
  /// given name in standard written name order.
  ///
  /// This affects display formatting only. The character's stored
  /// [firstName] and [lastName] values remain unchanged.
  static const Set<String> _familyNameFirstCountryCodes = {
    'CN', // China
    'JP', // Japan
    'KR', // South Korea
  };

  /// Formats a character's full name according to the country code.
  ///
  /// For China, Japan, and South Korea, the family name is displayed
  /// before the given name.
  ///
  /// For other countries, the given name is displayed before the
  /// family name.
  ///
  /// An unknown or empty country code uses the default given-name-first
  /// format to preserve compatibility with existing characters.
  ///
  /// Empty name components are ignored, and surrounding whitespace
  /// is removed.
  static String formatFullName(
    String countryCode,
    String firstName,
    String lastName,
  ) {
    final first = firstName.trim();
    final last = lastName.trim();

    if (first.isEmpty) {
      return last;
    }

    if (last.isEmpty) {
      return first;
    }

    final normalizedCountryCode = countryCode.trim().toUpperCase();

    if (_familyNameFirstCountryCodes.contains(
      normalizedCountryCode,
    )) {
      return '$last $first';
    }

    return '$first $last';
  }
}
