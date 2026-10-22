import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/data/models/world_state_snapshot.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/character_stats.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/character/player_asset.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';

void main() {
group('WorldStateSnapshot player assets', () {
test(
'preserves player assets and debt through JSON save/load',
() {
final original = _createWorldState(
assets: const [
PlayerAsset(
id: 'asset-house-1',
name: 'Family House',
type: PlayerAssetType.property,
value: Money.fromMinorUnits(25000000),
),
PlayerAsset(
id: 'asset-car-1',
name: 'Personal Car',
type: PlayerAssetType.vehicle,
value: Money.fromMinorUnits(4500000),
),
PlayerAsset(
id: 'asset-investment-1',
name: 'Index Fund',
type: PlayerAssetType.investment,
value: Money.fromMinorUnits(1200000),
),
],
debt: const Money.fromMinorUnits(8000000),
);

    final savedJson =
        WorldStateSnapshot.fromWorldState(original).toJson();

    final restored = WorldStateSnapshot
        .fromJson(savedJson)
        .toWorldState();

    expect(restored.player.assets, hasLength(3));

    expect(
      restored.player.assets[0].id,
      'asset-house-1',
    );
    expect(
      restored.player.assets[0].name,
      'Family House',
    );
    expect(
      restored.player.assets[0].type,
      PlayerAssetType.property,
    );
    expect(
      restored.player.assets[0].value.minorUnits,
      25000000,
    );

    expect(
      restored.player.assets[1].type,
      PlayerAssetType.vehicle,
    );
    expect(
      restored.player.assets[1].value.minorUnits,
      4500000,
    );

    expect(
      restored.player.assets[2].type,
      PlayerAssetType.investment,
    );
    expect(
      restored.player.assets[2].value.minorUnits,
      1200000,
    );

    expect(
      restored.player.debt.minorUnits,
      8000000,
    );
  },
);

test(
  'defaults assets and debt when loading a legacy save',
  () {
    final original = _createWorldState(
      assets: const [
        PlayerAsset(
          id: 'asset-old-1',
          name: 'Old Asset',
          type: PlayerAssetType.valuable,
          value: Money.fromMinorUnits(50000),
        ),
      ],
      debt: const Money.fromMinorUnits(25000),
    );

    final json =
        WorldStateSnapshot.fromWorldState(original).toJson();

    final playerJson =
        json['player'] as Map<String, dynamic>;

    playerJson.remove('assets');
    playerJson.remove('debtMinorUnits');

    final restored = WorldStateSnapshot
        .fromJson(json)
        .toWorldState();

    expect(restored.player.assets, isEmpty);
    expect(
      restored.player.debt.minorUnits,
      0,
    );
  },
);

test(
  'rejects an unknown player asset type',
  () {
    final json =
        WorldStateSnapshot.fromWorldState(
      _createWorldState(),
    ).toJson();

    final playerJson =
        json['player'] as Map<String, dynamic>;

    playerJson['assets'] = [
      {
        'id': 'asset-invalid-1',
        'name': 'Invalid Asset',
        'type': 'unknownType',
        'valueMinorUnits': 10000,
      },
    ];

    expect(
      () => WorldStateSnapshot.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  },
);

test(
  'rejects a non-list player assets field',
  () {
    final json =
        WorldStateSnapshot.fromWorldState(
      _createWorldState(),
    ).toJson();

    final playerJson =
        json['player'] as Map<String, dynamic>;

    playerJson['assets'] = 'not-a-list';

    expect(
      () => WorldStateSnapshot.fromJson(json),
      throwsA(isA<FormatException>()),
    );
  },
);

});
}

WorldState _createWorldState({
List<PlayerAsset> assets = const <PlayerAsset>[],
Money debt = const Money.zero(),
}) {
return WorldState(
clock: const SimulationClock(
currentYear: 2050,
),
player: Character(
id: 'player-assets-test',
name: 'Test Character',
gender: Gender.male,
birthYear: 2025,
stats: const CharacterStats(),
money: const Money.fromMinorUnits(500000),
assets: assets,
debt: debt,
),
events: const <SimulationEvent>[],
);
}
