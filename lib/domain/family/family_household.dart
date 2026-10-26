
import 'package:everylife/core/money/money.dart';

import 'family_asset.dart';
import 'parent_npc.dart';
import 'sibling_npc.dart';

enum HousingStatus {
  rented,
  familyOwned,
  ownedWithMortgage,
  temporary,
  providedByOthers,
  homeless,
}

/// Legacy family container retained to read existing save files.
/// Its aggregate money fields are not used by the active parent economy.
class FamilyHousehold {
  FamilyHousehold({
    required this.id,
    required List<ParentNpc> parents,
    required this.cashSavings,
    required List<FamilyAsset> assets,
    required this.housingStatus,
    required this.annualLivingCosts,
    required this.totalDebt,
    List<SiblingNpc> siblings = const <SiblingNpc>[],
    this.isAffairConception = false,
    this.raisedByFather = false,
  })  : parents = List.unmodifiable(parents),
        siblings = List.unmodifiable(siblings),
        assets = List.unmodifiable(assets);

  final String id;
  final List<ParentNpc> parents;

  /// True when the starting-life story establishes conception during an affair.
  /// Defaults to false when loading saves created before this field existed.
  final bool isAffairConception;

  /// Whether the father is the primary caregiver in the affair scenario.
  /// A stepmother may be generated only for this branch.
  final bool raisedByFather;

  /// Siblings generated once at new-life creation and persisted in saves.
  final List<SiblingNpc> siblings;

  /// Household cash and savings, separate from personal assets.
  final Money cashSavings;

  final List<FamilyAsset> assets;
  final HousingStatus housingStatus;

  /// Estimated household living costs per year.
  final Money annualLivingCosts;

  /// Combined household debt at the starting point.
  final Money totalDebt;

  Money get annualIncome {
    return parents.fold(
      const Money.zero(),
      (total, parent) => total + parent.annualIncome,
    );
  }

  Money get totalAssetValue {
    return assets.fold(
      cashSavings,
      (total, asset) => total + asset.value,
    );
  }

  Money get netWorth {
    return totalAssetValue - totalDebt;
  }

  Money get annualSurplus {
    return annualIncome - annualLivingCosts;
  }
}
