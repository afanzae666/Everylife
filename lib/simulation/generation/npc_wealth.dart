import 'package:everylife/core/money/money.dart';

import '../../domain/career/school_npc.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/sibling_npc.dart';

/// Net worth of NPCs, always from their real money. Anyone without money
/// (children, students) is exactly zero.
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

  /// A sibling's savings (zero until they work).
  static Money forSibling(SiblingNpc sibling) =>
      Money.fromMinorUnits(sibling.finance?.cashMinor ?? 0);

  /// A teacher's, principal's, professor's or dean's savings; students own
  /// nothing.
  static Money forSchoolNpc(SchoolNpc npc) =>
      Money.fromMinorUnits(npc.finance?.cashMinor ?? 0);
}
