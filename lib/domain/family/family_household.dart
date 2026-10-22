
import 'package:everylife/core/money/money.dart';

import 'family_asset.dart';
import 'parent_npc.dart';

enum HousingStatus {
  rented,
  familyOwned,
  ownedWithMortgage,
  temporary,
  providedByOthers,
  homeless,
}

class FamilyHousehold {
  FamilyHousehold({
    required this.id,
    required List<ParentNpc> parents,
    required this.cashSavings,
    required List<FamilyAsset> assets,
    required this.housingStatus,
    required this.annualLivingCosts,
    required this.totalDebt,
  })  : parents = List.unmodifiable(parents),
        assets = List.unmodifiable(assets);

  final String id;
  final List<ParentNpc> parents;

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
