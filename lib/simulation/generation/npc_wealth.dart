import 'package:everylife/core/money/money.dart';

import '../../domain/family/parent_npc.dart';
import 'country_economic_profile.dart';

/// Net worth of NPCs. Parents have real savings and assets; other adults
/// (siblings, teachers, ...) get a stable estimate that depends only on who
/// they are, so the number never changes between looks.
abstract final class NpcWealth {
  /// What a parent actually owns: savings plus the assets in their name.
  static Money forParent(ParentNpc parent) {
    var total = parent.cashBalance;

    for (final asset in parent.assets) {
      if (asset.ownerNpcId == parent.id) {
        total = total + asset.value;
      }
    }

    return total;
  }

  /// A stable guess for an adult NPC: roughly a few hundred to a couple of
  /// thousand dollars saved per adult year, scaled by the country and by
  /// [multiplier] (a principal has more than a student).
  static Money estimate({
    required String id,
    required int age,
    required String countryCode,
    int multiplier = 1,
  }) {
    if (age < 18) {
      return const Money.zero();
    }

    var seed = 11;

    for (final unit in id.codeUnits) {
      seed = (seed * 31 + unit) & 0x3fffffff;
    }

    final perYear = 20000 + seed % 180000;
    final base = (age - 17) * perYear * multiplier;
    final scaled = CountryEconomicProfile.forCountryCode(countryCode)
        .scaleAmount(base);

    return Money.fromMinorUnits(scaled);
  }
}
