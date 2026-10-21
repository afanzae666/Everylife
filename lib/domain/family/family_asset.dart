
import 'package:everylife/core/money/money.dart';

enum FamilyAssetType {
  property,
  vehicle,
  business,
  investment,
  valuable,
  other,
}

class FamilyAsset {
  const FamilyAsset({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    this.ownerNpcId,
  });

  final String id;
  final String name;
  final FamilyAssetType type;

  /// Estimated current value of this asset.
  final Money value;

  /// Null means the asset belongs to the household collectively.
  final String? ownerNpcId;
}
