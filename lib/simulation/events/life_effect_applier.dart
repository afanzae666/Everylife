import 'package:everylife/core/money/money.dart';

import '../../core/random/seeded_random.dart';
import '../../domain/character/character_stats.dart';
import '../../domain/event/life_event.dart';
import '../../domain/family/family_household.dart';
import '../../domain/world/world_state.dart';
import '../generation/country_economic_profile.dart';

/// Applies event outcomes to the world and rolls weighted results.
///
/// Kept separate from the systems so the automatic yearly events and the
/// player's resolved choices change the world in exactly the same way.
abstract final class LifeEffectApplier {
  /// Picks one item by weight using the shared seeded random generator.
  static T pickWeighted<T>(
    List<T> items,
    int Function(T item) weightOf,
    SeededRandom random,
  ) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Must not be empty.');
    }

    var total = 0;
    for (final item in items) {
      final weight = weightOf(item);
      total += weight < 1 ? 1 : weight;
    }

    var roll = random.nextInt(total);

    for (final item in items) {
      final weight = weightOf(item);
      roll -= weight < 1 ? 1 : weight;
      if (roll < 0) return item;
    }

    return items.last;
  }

  static LifeOutcome pickOutcome(
    List<LifeOutcome> outcomes,
    SeededRandom random,
  ) {
    return pickWeighted<LifeOutcome>(
      outcomes,
      (outcome) => outcome.weight,
      random,
    );
  }

  /// Scales a baseline money amount by the player's country cost of living.
  /// The sign is preserved.
  static int scaleMoney(WorldState state, int baseMinorUnits) {
    if (baseMinorUnits == 0) return 0;

    final profile = CountryEconomicProfile.forCountryCode(
      state.player.location?.countryCode ?? 'ID',
    );
    final scaled = profile.scaleAmount(baseMinorUnits.abs());

    return baseMinorUnits < 0 ? -scaled : scaled;
  }

  /// Applies stat changes, money changes, and flag changes of [outcome].
  ///
  /// Spending more than the player holds turns the remainder into debt
  /// instead of making cash negative.
  static WorldState applyOutcome({
    required WorldState state,
    required LifeOutcome outcome,
  }) {
    var stats = state.player.stats;

    for (final effect in outcome.stats) {
      stats = _applyStat(stats, effect);
    }

    var money = state.player.money.minorUnits;
    var debt = state.player.debt.minorUnits;
    final delta = scaleMoney(state, outcome.moneyBase);

    if (delta >= 0) {
      money += delta;
    } else {
      final cost = -delta;
      if (money >= cost) {
        money -= cost;
      } else {
        debt += cost - money;
        money = 0;
      }
    }

    final flags = <String>{...state.lifeProgress.flags}
      ..addAll(outcome.addFlags)
      ..removeAll(outcome.removeFlags);

    return state.copyWith(
      player: state.player.copyWith(
        stats: stats,
        money: Money.fromMinorUnits(money),
        debt: Money.fromMinorUnits(debt),
      ),
      familyHousehold: _applyRelations(state, outcome),
      lifeProgress: state.lifeProgress.copyWith(flags: flags),
    );
  }

  /// Moves the relationship score of living family members.
  static FamilyHousehold? _applyRelations(
    WorldState state,
    LifeOutcome outcome,
  ) {
    final household = state.familyHousehold;

    if (household == null ||
        (outcome.parentRelation == 0 && outcome.siblingRelation == 0)) {
      return household;
    }

    final year = state.clock.currentYear;

    int shift(int score, int delta) =>
        (score + delta).clamp(-100, 100).toInt();

    return household.copyWith(
      parents: [
        for (final parent in household.parents)
          parent.isAlive && outcome.parentRelation != 0
              ? parent.copyWith(
                  relationshipPercent: shift(
                    parent.relationshipPercent,
                    outcome.parentRelation,
                  ),
                )
              : parent,
      ],
      siblings: [
        for (final sibling in household.siblings)
          sibling.isAlive &&
                  sibling.birthYear <= year &&
                  outcome.siblingRelation != 0
              ? sibling.copyWith(
                  relationshipPercent: shift(
                    sibling.relationshipPercent,
                    outcome.siblingRelation,
                  ),
                )
              : sibling,
      ],
    );
  }

  static CharacterStats _applyStat(
    CharacterStats stats,
    StatEffect effect,
  ) {
    final next = stats.valueOf(effect.stat) + effect.delta;

    return switch (effect.stat) {
      StatKey.health => stats.copyWith(health: next),
      StatKey.intelligence => stats.copyWith(intelligence: next),
      StatKey.fitness => stats.copyWith(fitness: next),
      StatKey.happiness => stats.copyWith(happiness: next),
      StatKey.willpower => stats.copyWith(willpower: next),
      StatKey.charisma => stats.copyWith(charisma: next),
      StatKey.creativity => stats.copyWith(creativity: next),
      StatKey.luck => stats.copyWith(luck: next),
    };
  }
}
