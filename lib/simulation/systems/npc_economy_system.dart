import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../economy/npc_economy.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Every year, adult siblings and school faculty earn and save for real.
/// Students own nothing, so they stay at zero.
class NpcEconomySystem implements SimulationSystem {
  const NpcEconomySystem();

  @override
  String get id => 'npc_economy';

  @override
  int get priority => SystemPriority.npcEconomy.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    final year = state.clock.currentYear;
    var next = state;

    final household = state.familyHousehold;

    if (household != null && household.siblings.isNotEmpty) {
      final siblings = [
        for (final sibling in household.siblings)
          () {
            final age = year - sibling.birthYear;

            if (!sibling.isAlive || age < 18) {
              return sibling;
            }

            final finance = sibling.finance;

            return sibling.copyWith(
              finance: finance == null
                  ? NpcEconomy.forSibling(
                      id: sibling.id,
                      age: age,
                      countryCode: sibling.countryCode,
                    )
                  : NpcEconomy.advance(
                      finance: finance,
                      age: age,
                      countryCode: sibling.countryCode,
                    ),
            );
          }(),
      ];

      next = next.copyWith(
        familyHousehold: household.copyWith(siblings: siblings),
      );
    }

    final education = next.lifeProgress.education;

    if (education.npcs.any((npc) => npc.role.isFaculty)) {
      final npcs = [
        for (final npc in education.npcs)
          () {
            if (!npc.role.isFaculty) {
              return npc;
            }

            final age = year - npc.birthYear;
            final finance = npc.finance;

            if (finance == null) {
              return npc.copyWith(
                finance: NpcEconomy.forFaculty(npc: npc, age: age),
              );
            }

            return npc.copyWith(
              finance: NpcEconomy.advance(
                finance: finance,
                age: age,
                countryCode: npc.countryCode,
              ),
            );
          }(),
      ];

      next = next.copyWith(
        lifeProgress: next.lifeProgress.copyWith(
          education: education.copyWith(npcs: npcs),
        ),
      );
    }

    return next;
  }
}
