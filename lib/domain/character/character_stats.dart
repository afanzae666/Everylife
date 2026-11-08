class CharacterStats {
  const CharacterStats({
    this.health = 100,
    this.intelligence = 50,
    this.fitness = 50,
    this.happiness = 75,
    this.willpower = 50,
    this.charisma = 50,
    this.creativity = 50,
    this.luck = 50,
    this.fertility = 70,
  });

  static const int minimum = 0;
  static const int maximum = 100;

  final int health;
  final int intelligence;
  final int fitness;
  final int happiness;
  final int willpower;
  final int charisma;
  final int creativity;
  final int luck;

  /// Baseline fertility the character is born with. The fertility that is
  /// shown also follows age (see `Fertility.effective`).
  final int fertility;

  /// Appearance, from 0 to 100. It is not stored: it follows from how fit,
  /// charming, and healthy the character is, so events that change those
  /// stats change looks too.
  int get looks {
    final score = (fitness * 4 + charisma * 4 + health * 2) / 10;

    return _clamp(score.round());
  }

  CharacterStats copyWith({
    int? health,
    int? intelligence,
    int? fitness,
    int? happiness,
    int? willpower,
    int? charisma,
    int? creativity,
    int? luck,
    int? fertility,
  }) {
    return CharacterStats(
      health: _clamp(health ?? this.health),
      intelligence: _clamp(
        intelligence ?? this.intelligence,
      ),
      fitness: _clamp(
        fitness ?? this.fitness,
      ),
      happiness: _clamp(
        happiness ?? this.happiness,
      ),
      willpower: _clamp(
        willpower ?? this.willpower,
      ),
      charisma: _clamp(
        charisma ?? this.charisma,
      ),
      creativity: _clamp(
        creativity ?? this.creativity,
      ),
      luck: _clamp(
        luck ?? this.luck,
      ),
      fertility: _clamp(fertility ?? this.fertility),
    );
  }

  static int _clamp(int value) {
    if (value < minimum) {
      return minimum;
    }

    if (value > maximum) {
      return maximum;
    }

    return value;
  }
}
