
import '../../core/random/seeded_random.dart';
import '../../domain/character/starting_background.dart';

class StartingBackgroundGenerator {
  const StartingBackgroundGenerator._();

  static const Map<StartingBackgroundTier, int> _weights = {
    StartingBackgroundTier.struggling: 35,
    StartingBackgroundTier.workingClass: 30,
    StartingBackgroundTier.middleClass: 18,
    StartingBackgroundTier.upperMiddleClass: 10,
    StartingBackgroundTier.wealthy: 5,
    StartingBackgroundTier.veryWealthy: 2,
  };

  static StartingBackground generate(SeededRandom random) {
    final totalWeight = _weights.values.fold<int>(
      0,
      (total, weight) => total + weight,
    );

    var roll = random.nextInt(totalWeight);

    for (final entry in _weights.entries) {
      roll -= entry.value;

      if (roll < 0) {
        return StartingBackground(tier: entry.key);
      }
    }

    throw StateError(
      'Unable to generate a starting background.',
    );
  }
}
