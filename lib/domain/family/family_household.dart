
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
  })  : parents = List.unmodifiable(parents),
        siblings = List.unmodifiable(siblings),
        assets = List.unmodifiable(assets);

  final String id;
  final List<ParentNpc> parents;

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

  /// Returns a copy with the given fields replaced.
  ///
  /// Always prefer this over calling the constructor directly: it keeps
  /// every field, so systems cannot accidentally reset one when they update
  /// the household.
  FamilyHousehold copyWith({
    List<ParentNpc>? parents,
    List<SiblingNpc>? siblings,
    Money? cashSavings,
    List<FamilyAsset>? assets,
    HousingStatus? housingStatus,
    Money? annualLivingCosts,
    Money? totalDebt,
  }) {
    return FamilyHousehold(
      id: id,
      parents: parents ?? this.parents,
      siblings: siblings ?? this.siblings,
      cashSavings: cashSavings ?? this.cashSavings,
      assets: assets ?? this.assets,
      housingStatus: housingStatus ?? this.housingStatus,
      annualLivingCosts: annualLivingCosts ?? this.annualLivingCosts,
      totalDebt: totalDebt ?? this.totalDebt,
    );
  }

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
