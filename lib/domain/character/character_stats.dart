class CharacterStats {
  const CharacterStats({
    this.health = 100,
    this.happiness = 75,
    this.intelligence = 50,
    this.discipline = 50,
    this.empathy = 50,
    this.ambition = 50,
  });

  final int health;
  final int happiness;
  final int intelligence;
  final int discipline;
  final int empathy;
  final int ambition;

  CharacterStats copyWith({
    int? health,
    int? happiness,
    int? intelligence,
    int? discipline,
    int? empathy,
    int? ambition,
  }) {
    return CharacterStats(
      health: health ?? this.health,
      happiness: happiness ?? this.happiness,
      intelligence: intelligence ?? this.intelligence,
      discipline: discipline ?? this.discipline,
      empathy: empathy ?? this.empathy,
      ambition: ambition ?? this.ambition,
    );
  }
}
