import '../../core/money/money.dart';
import 'character_stats.dart';
import 'gender.dart';
import 'life_stage.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    this.gender = Gender.male,
    required this.birthYear,
    required this.stats,
    required this.money,
  });

  final String id;
  final String name;
  final Gender gender;
  final int birthYear;
  final CharacterStats stats;
  final Money money;

  int ageAt(int year) {
    final age = year - birthYear;

    if (age < 0) {
      throw StateError(
        'Character birth year cannot be after current year.',
      );
    }

    return age;
  }

  LifeStage lifeStageAt(int year) {
    return LifeStageAge.fromAge(ageAt(year));
  }

  Character copyWith({
    String? name,
    Gender? gender,
    int? birthYear,
    CharacterStats? stats,
    Money? money,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      stats: stats ?? this.stats,
      money: money ?? this.money,
    );
  }

  static Character create({
    required String id,
    required String name,
    Gender gender = Gender.male,
    required int birthYear,
    CharacterStats? stats,
  }) {
    return Character(
      id: id,
      name: name,
      gender: gender,
      birthYear: birthYear,
      stats: stats ?? const CharacterStats(),
      money: const Money.zero(),
    );
  }
}
