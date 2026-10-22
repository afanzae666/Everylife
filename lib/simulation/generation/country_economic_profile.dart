
/// Gameplay cost-of-living profiles by ISO 3166-1 alpha-2 country code.
///
/// These indices are balancing estimates for the simulation, not official
/// cost-of-living statistics. Currency conversion is handled separately.
///
/// 10000 represents the neutral baseline:
/// 6500 means 65% of the baseline cost, and 14000 means 140%.
class CountryEconomicProfile {
  const CountryEconomicProfile._({
    required this.countryCode,
    required this.costOfLivingBasisPoints,
  });

  static const int neutralBasisPoints = 10000;

  static const Map<String, int> _costOfLivingIndices = {
    'AE': 11500,
    'AR': 6500,
    'AT': 11500,
    'AU': 12500,
    'BE': 11000,
    'BR': 6500,
    'CA': 12000,
    'CH': 16500,
    'CL': 7500,
    'CN': 7500,
    'CO': 5500,
    'CU': 5000,
    'DE': 11000,
    'DK': 13500,
    'EG': 4000,
    'ES': 9000,
    'ET': 3500,
    'FJ': 7500,
    'FR': 11500,
    'GB': 12000,
    'GH': 4000,
    'GR': 8500,
    'ID': 5500,
    'IE': 12500,
    'IN': 4500,
    'IT': 10000,
    'JP': 11000,
    'KE': 4000,
    'KR': 10500,
    'MA': 4500,
    'MC': 16000,
    'MX': 6000,
    'MY': 6000,
    'NG': 3500,
    'NL': 11500,
    'NP': 4000,
    'NO': 14500,
    'NZ': 12000,
    'PK': 3500,
    'PL': 7500,
    'PT': 8500,
    'RU': 6500,
    'SA': 8500,
    'SE': 12500,
    'SG': 14000,
    'TH': 6000,
    'TR': 5500,
    'UA': 5000,
    'US': 12000,
    'VN': 4500,
    'ZA': 6000,
    'TZ': 3500,
    'PE': 5500,
    'PH': 5000,
  };

  /// The normalized country code used to resolve this profile.
  final String countryCode;

  /// Relative cost-of-living index, where 10000 is the neutral baseline.
  final int costOfLivingBasisPoints;

  /// Returns a profile for a country, or the neutral profile if unknown.
  factory CountryEconomicProfile.forCountryCode(String countryCode) {
    final normalizedCode = countryCode.trim().toUpperCase();

    return CountryEconomicProfile._(
      countryCode: normalizedCode,
      costOfLivingBasisPoints:
          _costOfLivingIndices[normalizedCode] ?? neutralBasisPoints,
    );
  }

  /// Scales a non-negative amount using integer arithmetic and rounding.
  int scaleAmount(int amount) {
    if (amount < 0) {
      throw ArgumentError.value(amount, 'amount', 'Must not be negative.');
    }

    return (amount * costOfLivingBasisPoints +
            neutralBasisPoints ~/ 2) ~/
        neutralBasisPoints;
  }

      /// Scales both ends of a valid non-negative range.
  ///
  /// Throws [ArgumentError] when either bound is negative or
  /// the minimum is greater than the maximum.
  (int, int) scaleRange((int, int) range) {
    if (range.$1 < 0) {
      throw ArgumentError.value(
        range.$1,
        'range minimum',
        'Must not be negative.',
      );
    }

    if (range.$2 < 0) {
      throw ArgumentError.value(
        range.$2,
        'range maximum',
        'Must not be negative.',
      );
    }

    if (range.$1 > range.$2) {
      throw ArgumentError.value(
        range,
        'range',
        'Minimum must not exceed maximum.',
      );
    }

    return (
      scaleAmount(range.$1),
      scaleAmount(range.$2),
    );
  }
}
