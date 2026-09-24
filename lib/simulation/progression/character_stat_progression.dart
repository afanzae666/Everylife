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
      discipline: _adjust(
        stats.discipline,
        _disciplineDelta(stage),
      ),
      empathy: _adjust(
        stats.empathy,
        _empathyDelta(stage),
      ),
      ambition: _adjust(
        stats.ambition,
        _ambitionDelta(stage),
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
        return 1;
      case LifeStage.child:
        return 1;
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
        return 1;
      case LifeStage.toddler:
        return 1;
      case LifeStage.child:
        return 1;
      case LifeStage.teen:
        return 0;
      case LifeStage.youngAdult:
        return 0;
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
        return 2;
      case LifeStage.teen:
        return 2;
      case LifeStage.youngAdult:
        return 1;
      case LifeStage.adult:
        return 0;
      case LifeStage.senior:
        return 0;
    }
  }

  int _disciplineDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return 0;
      case LifeStage.toddler:
        return 0;
      case LifeStage.child:
        return 1;
      case LifeStage.teen:
        return 1;
      case LifeStage.youngAdult:
        return 1;
      case LifeStage.adult:
        return 0;
      case LifeStage.senior:
        return 0;
    }
  }

  int _empathyDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return 0;
      case LifeStage.toddler:
        return 1;
      case LifeStage.child:
        return 1;
      case LifeStage.teen:
        return 1;
      case LifeStage.youngAdult:
        return 1;
      case LifeStage.adult:
        return 0;
      case LifeStage.senior:
        return 1;
    }
  }

  int _ambitionDelta(LifeStage stage) {
    switch (stage) {
      case LifeStage.infant:
        return 0;
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
