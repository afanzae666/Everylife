import '../../domain/character/character_stats.dart';
import '../../domain/character/life_stage.dart';

class CharacterStatProgression {
  const CharacterStatProgression();

  CharacterStats apply({
    required CharacterStats stats,
    required LifeStage stage,
  }) {
    return stats.copyWith(
      health: _adjust(
        stats.health,
        _healthDelta(stage),
      ),
      happiness: _adjust(
        stats.happiness,
        _happinessDelta(stage),
      ),
      intelligence: _adjust(
        stats.intelligence,
        _intelligenceDelta(stage),
      ),
      fitness: _adjust(
        stats.fitness,
        _fitnessDelta(stage),
      ),
      willpower: _adjust(
        stats.willpower,
        _willpowerDelta(stage),
      ),
      charisma: _adjust(
        stats.charisma,
        _charismaDelta(stage),
      ),
      creativity: _adjust(
        stats.creativity,
        _creativityDelta(stage),
      ),
    );
  }

  int _adjust(int value, int delta) {
    return (value + delta).clamp(0, 100);
  }

  int _healthDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return 0;
      case LifeStage.toddler:
      case LifeStage.child:
      case LifeStage.teen:
        return 1;
      case LifeStage.youngAdult:
        return 0;
      case LifeStage.adult:
        return -1;
      case LifeStage.senior:
        return -2;
    }
  }

  int _happinessDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
      case LifeStage.toddler:
      case LifeStage.child:
        return 1;
      case LifeStage.teen:
      case LifeStage.youngAdult:
      case LifeStage.adult:
        return 0;
      case LifeStage.senior:
        return 1;
    }
  }

  int _intelligenceDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return 0;
      case LifeStage.toddler:
        return 1;
      case LifeStage.child:
      case LifeStage.teen:
        return 2;
      case LifeStage.youngAdult:
        return 1;
      case LifeStage.adult:
      case LifeStage.senior:
        return 0;
    }
  }

  int _fitnessDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return 0;
      case LifeStage.toddler:
      case LifeStage.child:
      case LifeStage.teen:
        return 1;
      case LifeStage.youngAdult:
        return 0;
      case LifeStage.adult:
        return -1;
      case LifeStage.senior:
        return -2;
    }
  }

  int _willpowerDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
      case LifeStage.toddler:
        return 0;
      case LifeStage.child:
      case LifeStage.teen:
      case LifeStage.youngAdult:
        return 1;
      case LifeStage.adult:
      case LifeStage.senior:
        return 0;
    }
  }

  int _charismaDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return 0;
      case LifeStage.toddler:
      case LifeStage.child:
      case LifeStage.teen:
      case LifeStage.youngAdult:
        return 1;
      case LifeStage.adult:
        return 0;
      case LifeStage.senior:
        return 1;
    }
  }

  int _creativityDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
      case LifeStage.toddler:
        return 0;
      case LifeStage.child:
        return 1;
      case LifeStage.teen:
        return 2;
      case LifeStage.youngAdult:
        return 1;
      case LifeStage.adult:
        return 0;
      case LifeStage.senior:
        return -1;
    }
  }
}
