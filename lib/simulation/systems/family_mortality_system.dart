import 'package:everylife/core/money/money.dart';
import '../../core/random/seeded_random.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/family/family_asset.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/sibling_npc.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import 'funeral_planner.dart';
import 'mortality_system.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Lets parents and siblings die of natural causes, and settles estates.
///
/// Each living family member gets one death roll per year, using the same
/// age-based table as the player (with a fixed, moderate health value).
class FamilyMortalitySystem implements SimulationSystem {
  FamilyMortalitySystem({
    required SeededRandom random,
  }) : _random = random;

  final SeededRandom _random;

  static const int _assumedParentHealth = 70;
  static const int _assumedSiblingHealth = 75;

  @override
  String get id => 'family_mortality';

  @override
  int get priority => SystemPriority.familyMortality.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final household = state.familyHousehold;

    if (household == null || state.lifeProgress.ending != null) {
      return state;
    }

    final year = state.clock.currentYear;
    final playerAge = state.player.ageAt(year);
    final flags = <String>{...state.lifeProgress.flags};
    final logs = <SimulationEvent>[];

    var player = state.player;
    var stats = player.stats;
    var assets = List<FamilyAsset>.of(household.assets);
    var changed = false;

    final parents = <ParentNpc>[];
    final diedNow = <ParentNpc>[];

    for (final parent in household.parents) {
      if (!parent.isAlive) {
        parents.add(parent);
        continue;
      }

      final age = year - parent.birthYear;
      final chance = MortalitySystem.deathChancePer10000(
        age: age,
        health: _assumedParentHealth,
      );

      if (_random.nextInt(10000) >= chance) {
        parents.add(parent);
        continue;
      }

      changed = true;
      diedNow.add(parent);

      final isBiological =
          parent.role == FamilyRole.father || parent.role == FamilyRole.mother;
      final owned = assets.where((asset) => asset.ownerNpcId == parent.id);
      final estate = parent.cashBalance.minorUnits +
          owned.fold<int>(0, (sum, asset) => sum + asset.value.minorUnits);

      assets = assets.where((asset) => asset.ownerNpcId != parent.id).toList();

      var share = 0;

      if (isBiological && playerAge >= 18) {
        share = estate ~/ (parent.siblingCount + 1);
        player = player.copyWith(
          money: Money.fromMinorUnits(player.money.minorUnits + share),
        );
      }

      stats = stats.copyWith(happiness: stats.happiness - (isBiological ? 12 : 4));

      if (isBiological) {
        flags.add(SystemFlags.lostParent);
      }

      logs.add(
        SimulationEvent(
          id: 'family-death-${parent.id}-$year',
          type: SimulationEventType.family,
          year: year,
          title: '${parent.fullName} passed away',
          description: _parentDeathText(
            parent: parent,
            age: age,
            share: share,
            isBiological: isBiological,
            playerAge: playerAge,
          ),
        ),
      );

      parents.add(
        parent.copyWith(
          isAlive: false,
          deathYear: year,
          cashBalance: const Money.zero(),
          assets: const <FamilyAsset>[],
        ),
      );
    }

    final siblings = <SiblingNpc>[];

    for (final sibling in household.siblings) {
      if (!sibling.isAlive || sibling.birthYear > year) {
        siblings.add(sibling);
        continue;
      }

      final age = year - sibling.birthYear;
      final chance = MortalitySystem.deathChancePer10000(
        age: age,
        health: _assumedSiblingHealth,
      );

      if (_random.nextInt(10000) >= chance) {
        siblings.add(sibling);
        continue;
      }

      changed = true;
      flags.add(SystemFlags.lostSibling);
      stats = stats.copyWith(happiness: stats.happiness - 10);

      logs.add(
        SimulationEvent(
          id: 'family-death-${sibling.id}-$year',
          type: SimulationEventType.family,
          year: year,
          title: '${sibling.fullName} passed away',
          description:
              'My sibling ${sibling.fullName} passed away at age $age. '
              'The family held each other close.',
        ),
      );

      siblings.add(sibling.copyWith(isAlive: false, deathYear: year));
    }

    if (!changed) {
      return state;
    }

    final hasProperty =
        assets.any((asset) => asset.type == FamilyAssetType.property);
    final ownsHome = household.housingStatus == HousingStatus.familyOwned ||
        household.housingStatus == HousingStatus.ownedWithMortgage;

    // The household must not claim to own a home whose deed holder died.
    final housingStatus = !hasProperty && ownsHome
        ? HousingStatus.providedByOthers
        : household.housingStatus;

    var next = state.copyWith(
      player: player.copyWith(stats: stats),
      familyHousehold: household.copyWith(
        parents: parents,
        siblings: siblings,
        assets: assets,
        housingStatus: housingStatus,
      ),
      lifeProgress: state.lifeProgress.copyWith(flags: flags),
    );

    for (final entry in logs) {
      next = next.addEvent(entry);
    }

    // The player decides how to say goodbye (burial, cremation, ...).
    return FuneralPlanner.schedule(next, diedNow);
  }

  String _parentDeathText({
    required ParentNpc parent,
    required int age,
    required int share,
    required bool isBiological,
    required int playerAge,
  }) {
    final base = 'My ${_roleLabel(parent.role)}, ${parent.fullName}, '
        'passed away at age $age.';

    if (!isBiological) {
      return base;
    }

    if (playerAge < 18) {
      return '$base What little they left went toward my upbringing.';
    }

    return share > 0
        ? '$base I inherited my share of their estate.'
        : '$base They left nothing behind but memories.';
  }

  String _roleLabel(FamilyRole role) => switch (role) {
        FamilyRole.father => 'father',
        FamilyRole.mother => 'mother',
        FamilyRole.guardian => 'guardian',
        FamilyRole.stepFather => 'stepfather',
        FamilyRole.stepMother => 'stepmother',
      };
}
