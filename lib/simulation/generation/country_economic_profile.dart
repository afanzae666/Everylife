
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


  /// Approximate starting-family economic distribution for gameplay.
  /// Values are balancing estimates informed by broad country income and
  /// poverty patterns, not official household-level statistics.
  /// Order: struggling, working class, middle class, upper middle class,
  /// wealthy, very wealthy. Each distribution totals 100.
  static const Map<String, List<int>> _startingTierWeights = {
    // Lower-income countries and countries with comparatively high poverty.
    'EG': [45, 30, 16, 6, 2, 1],
    'ET': [55, 27, 12, 4, 1, 1],
    'GH': [48, 29, 15, 5, 2, 1],
    'ID': [42, 31, 17, 6, 3, 1],
    'IN': [46, 30, 15, 6, 2, 1],
    'KE': [50, 28, 14, 5, 2, 1],
    'MA': [43, 31, 17, 6, 2, 1],
    'NG': [55, 27, 12, 4, 1, 1],
    'NP': [50, 29, 14, 5, 1, 1],
    'PK': [52, 28, 13, 5, 1, 1],
    'PH': [43, 31, 17, 6, 2, 1],
    'TZ': [58, 26, 11, 3, 1, 1],
    'VN': [35, 32, 21, 8, 3, 1],
    // Emerging and middle-income economies.
    'AR': [35, 31, 21, 8, 4, 1],
    'BR': [38, 30, 20, 7, 4, 1],
    'CL': [25, 30, 26, 12, 5, 2],
    'CN': [25, 31, 27, 11, 5, 1],
    'CO': [40, 30, 19, 7, 3, 1],
    'CU': [38, 31, 20, 7, 3, 1],
    'FJ': [30, 31, 24, 9, 4, 2],
    'GR': [22, 29, 28, 13, 6, 2],
    'MX': [36, 31, 21, 8, 3, 1],
    'MY': [25, 31, 26, 11, 5, 2],
    'PE': [39, 30, 19, 7, 4, 1],
    'PL': [16, 26, 31, 16, 8, 3],
    'RU': [30, 30, 24, 10, 5, 1],
    'SA': [18, 25, 27, 16, 10, 4],
    'TH': [30, 31, 24, 10, 4, 1],
    'TR': [32, 31, 23, 9, 4, 1],
    'UA': [30, 31, 24, 9, 5, 1],
    'ZA': [42, 28, 18, 7, 4, 1],
    // High-income economies; struggling households remain possible.
    'AE': [12, 22, 29, 19, 12, 6],
    'AT': [10, 23, 32, 19, 11, 5],
    'AU': [12, 23, 31, 19, 10, 5],
    'BE': [11, 24, 32, 19, 10, 4],
    'CA': [13, 24, 31, 18, 10, 4],
    'CH': [7, 17, 29, 22, 16, 9],
    'DE': [10, 23, 32, 19, 11, 5],
    'DK': [8, 20, 32, 21, 13, 6],
    'ES': [15, 25, 31, 17, 9, 3],
    'FR': [12, 24, 32, 18, 10, 4],
    'GB': [14, 24, 30, 18, 10, 4],
    'IE': [10, 22, 31, 20, 12, 5],
    'IT': [14, 25, 31, 17, 9, 4],
    'JP': [12, 25, 32, 18, 9, 4],
    'KR': [13, 24, 31, 18, 10, 4],
    'MC': [4, 10, 20, 23, 23, 20],
    'NL': [9, 22, 32, 21, 11, 5],
    'NO': [7, 19, 31, 22, 14, 7],
    'NZ': [12, 24, 31, 18, 10, 5],
    'PT': [17, 26, 30, 16, 8, 3],
    'SE': [8, 20, 32, 22, 12, 6],
    'SG': [8, 18, 28, 22, 15, 9],
    'US': [17, 24, 28, 16, 10, 5],
  };

  /// Weights aligned with the six starting-background tiers. Unknown countries
  /// use a neutral global estimate. Callers normalize by the weight total.
  List<int> get startingBackgroundWeights =>
      List<int>.unmodifiable(
        _startingTierWeights[countryCode] ?? const [30, 30, 22, 10, 5, 3],
      );

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
