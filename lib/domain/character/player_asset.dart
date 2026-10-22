import 'package:everylife/core/money/money.dart';

/// Types of assets owned by the player character.
enum PlayerAssetType {
property,
vehicle,
business,
investment,
valuable,
other,
}

/// An asset personally owned by the player character.
class PlayerAsset {
const PlayerAsset({
required this.id,
required this.name,
required this.type,
required this.value,
});

/// Unique identifier for this asset.
final String id;

/// Display name of the asset.
final String name;

/// Category used to organize assets in the game.
final PlayerAssetType type;

/// Estimated current value stored in the game's base money unit.
final Money value;
}
