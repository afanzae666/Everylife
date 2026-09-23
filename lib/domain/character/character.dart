import '../../core/money/money.dart';
import 'character_stats.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.stats,
    required this.money,
  });

  final String id;
  final String name;
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

  Character copyWith({
    String? name,
    int? birthYear,
    CharacterStats? stats,
    Money? money,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      birthYear: birthYear ?? this.birthYear,
      stats: stats ?? this.stats,
      money: money ?? this.money,
    );
  }

  static Character create({
    required String id,
    required String name,
    required int birthYear,
  }) {
    return Character(
      id: id,
      name: name,
      birthYear: birthYear,
      stats: const CharacterStats(),
      money: const Money.zero(),
    );
  }
}
