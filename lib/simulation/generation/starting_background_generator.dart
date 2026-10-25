import '../../core/random/seeded_random.dart';
import '../../domain/character/starting_background.dart';
import 'country_economic_profile.dart';

class StartingBackgroundGenerator {
  const StartingBackgroundGenerator._();

  /// Generates a starting economic class using the selected birth country.
  /// Country weights are gameplay estimates and always normalize to a total
  /// probability of 100%, even if future profiles use different weight totals.
  static StartingBackground generate(
    SeededRandom random, {
    String countryCode = 'ID',
  }) {
    final weights = CountryEconomicProfile.forCountryCode(
      countryCode,
    ).startingBackgroundWeights;
    final totalWeight = weights.fold<int>(0, (total, weight) => total + weight);
    var roll = random.nextInt(totalWeight);

    for (var index = 0; index < StartingBackgroundTier.values.length; index++) {
      roll -= weights[index];
      if (roll < 0) {
        return StartingBackground(tier: StartingBackgroundTier.values[index]);
      }
    }

    throw StateError('Unable to generate a starting background.');
  }
}
