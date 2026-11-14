import '../../domain/career/part_time_catalog.dart';
import '../../domain/world/world_state.dart';
import '../events/life_effect_applier.dart';
import '../systems/career_system.dart';

/// The yearly income that does not come from the main job or pension:
/// the pay of a part-time job and the benefit of an adult without work.
/// Amounts are in the player's currency (minor units).
class IncomeBreakdown {
  const IncomeBreakdown({required this.partTime, required this.benefit});

  final int partTime;
  final int benefit;

  int get total => partTime + benefit;

  static IncomeBreakdown of(WorldState state) {
    final career = state.lifeProgress.career;
    final age = state.player.ageAt(state.clock.currentYear);
    final partTime = career.retired
        ? null
        : PartTimeCatalog.byId(career.partTimeId);
    final onBenefit = age >= 18 && !career.hasJob && !career.retired;

    return IncomeBreakdown(
      partTime: partTime == null
          ? 0
          : LifeEffectApplier.scaleMoney(state, partTime.pay),
      benefit: onBenefit
          ? LifeEffectApplier.scaleMoney(
              state,
              CareerSystem.unemploymentBenefitBase,
            )
          : 0,
    );
  }
}
