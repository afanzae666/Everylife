import 'package:everylife/core/money/money.dart';

import '../../domain/character/appearance.dart';
import '../../domain/character/character.dart';
import '../../domain/character/character_stats.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/player_asset.dart';
import '../../domain/character/starting_background.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/family/family_asset.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/sibling_npc.dart';
import '../../domain/time/simulation_clock.dart';
import '../../domain/world/character_location.dart';
import '../../domain/world/world_state.dart';

class WorldStateSnapshot {
const WorldStateSnapshot({
required this.currentYear,
required this.playerId,
required this.playerName,
required this.playerFirstName,
required this.playerLastName,
required this.playerGender,
required this.playerBirthYear,
this.playerBirthMonth = 1,
this.playerBirthDay = 1,
required this.playerHealth,
required this.playerIntelligence,
required this.playerFitness,
required this.playerHappiness,
required this.playerWillpower,
required this.playerCharisma,
required this.playerCreativity,
required this.playerLuck,
required this.playerMoneyMinorUnits,
this.playerAssets = const <PlayerAsset>[],
this.playerDebtMinorUnits = 0,
required this.playerAppearance,
this.playerLocation,
this.playerStartingBackgroundTier,
this.familyHousehold,
required this.events,
});

final int currentYear;

final String playerId;
final String playerName;
final String playerFirstName;
final String playerLastName;
final Gender playerGender;
final int playerBirthYear;
final int playerBirthMonth;
final int playerBirthDay;

final int playerHealth;
final int playerIntelligence;
final int playerFitness;
final int playerHappiness;
final int playerWillpower;
final int playerCharisma;
final int playerCreativity;
final int playerLuck;

final int playerMoneyMinorUnits;

/// Assets personally owned by the player.
///
/// Empty when loading a legacy save without player asset data.
final List<PlayerAsset> playerAssets;

/// Outstanding player debt in the game's base money unit.
///
/// Defaults to zero for legacy saves.
final int playerDebtMinorUnits;

final CharacterAppearance playerAppearance;

/// The player's country and city, or null for an unset location.
final CharacterLocation? playerLocation;

/// The player's starting background tier, or null for a legacy save.
final StartingBackgroundTier? playerStartingBackgroundTier;

/// Family data, null for legacy saves without a household.
final FamilyHousehold? familyHousehold;

final List<SimulationEvent> events;

factory WorldStateSnapshot.fromWorldState(
WorldState state,
) {
final player = state.player;
final stats = player.stats;

return WorldStateSnapshot(
  currentYear: state.clock.currentYear,
  playerId: player.id,
  playerName: player.name,
  playerFirstName: player.resolvedFirstName,
  playerLastName: player.resolvedLastName,
  playerGender: player.gender,
  playerBirthYear: player.birthYear,
  playerBirthMonth: player.birthMonth,
  playerBirthDay: player.birthDay,
  playerHealth: stats.health,
  playerIntelligence: stats.intelligence,
  playerFitness: stats.fitness,
  playerHappiness: stats.happiness,
  playerWillpower: stats.willpower,
  playerCharisma: stats.charisma,
  playerCreativity: stats.creativity,
  playerLuck: stats.luck,
  playerMoneyMinorUnits: player.money.minorUnits,
  playerAssets: List.unmodifiable(player.assets),
  playerDebtMinorUnits: player.debt.minorUnits,
  playerAppearance: player.appearance,
  playerLocation: player.location,
  playerStartingBackgroundTier:
      state.startingBackground?.tier,
  familyHousehold: state.familyHousehold,
  events: List.unmodifiable(state.events),
);

}

WorldState toWorldState() {
return WorldState(
clock: SimulationClock(
currentYear: currentYear,
),
player: Character(
id: playerId,
name: playerName,
firstName: playerFirstName,
lastName: playerLastName,
gender: playerGender,
birthYear: playerBirthYear,
birthMonth: playerBirthMonth,
birthDay: playerBirthDay,
stats: CharacterStats(
health: playerHealth,
intelligence: playerIntelligence,
fitness: playerFitness,
happiness: playerHappiness,
willpower: playerWillpower,
charisma: playerCharisma,
creativity: playerCreativity,
luck: playerLuck,
),
money: Money.fromMinorUnits(
playerMoneyMinorUnits,
),
assets: List.unmodifiable(playerAssets),
debt: Money.fromMinorUnits(
playerDebtMinorUnits,
),
appearance: playerAppearance,
location: playerLocation,
),
events: List.unmodifiable(events),
startingBackground:
playerStartingBackgroundTier == null
? null
: StartingBackground(
tier: playerStartingBackgroundTier!,
),
familyHousehold: familyHousehold,
);
}

Map<String, dynamic> toJson() {
return {
'currentYear': currentYear,
'player': {
'id': playerId,
'name': playerName,
'firstName': playerFirstName,
'lastName': playerLastName,
'gender': playerGender.name,
'birthYear': playerBirthYear,
'birthMonth': playerBirthMonth,
'birthDay': playerBirthDay,
'stats': {
'health': playerHealth,
'intelligence': playerIntelligence,
'fitness': playerFitness,
'happiness': playerHappiness,
'willpower': playerWillpower,
'charisma': playerCharisma,
'creativity': playerCreativity,
'luck': playerLuck,
},
'moneyMinorUnits': playerMoneyMinorUnits,
'assets': playerAssets
.map(
(asset) => {
'id': asset.id,
'name': asset.name,
'type': asset.type.name,
'valueMinorUnits': asset.value.minorUnits,
},
)
.toList(growable: false),
'debtMinorUnits': playerDebtMinorUnits,
'appearance': {
'base': playerAppearance.base,
'skinTone': playerAppearance.skinTone,
'hair': playerAppearance.hair,
'infantHair': playerAppearance.infantHair,
'toddlerHair': playerAppearance.toddlerHair,
'childHair': playerAppearance.childHair,
'hairColor': playerAppearance.hairColor,
'eyes': playerAppearance.eyes,
'eyeColor': playerAppearance.eyeColor,
'eyebrows': playerAppearance.eyebrows,
'beard': playerAppearance.beard,
},
'location': playerLocation == null
? null
: {
'countryCode': playerLocation!.countryCode,
'cityId': playerLocation!.cityId,
},
},
'startingBackground':
playerStartingBackgroundTier?.name,
'familyHousehold': familyHousehold == null
? null
: _familyHouseholdToJson(familyHousehold!),
'events': events
.map(
(event) => {
'id': event.id,
'type': event.type.name,
'year': event.year,
'title': event.title,
'description': event.description,
},
)
.toList(growable: false),
};
}

factory WorldStateSnapshot.fromJson(
Map<String, dynamic> json,
) {
final player = _requireMap(
json['player'],
'player',
);

final stats = _requireMap(
  player['stats'],
  'player.stats',
);

final appearanceJson = player['appearance'];
final locationJson = player['location'];
final playerAssetsJson = player['assets'];
final playerDebtJson = player['debtMinorUnits'];
final startingBackgroundJson =
    json['startingBackground'];
final familyHouseholdJson = json['familyHousehold'];
final eventsJson = json['events'];

if (eventsJson is! List) {
  throw const FormatException(
    'Field "events" must be a list.',
  );
}

return WorldStateSnapshot(
  currentYear: _requireInt(
    json['currentYear'],
    'currentYear',
  ),
  playerId: _requireString(
    player['id'],
    'player.id',
  ),
  playerName: _requireString(
    player['name'],
    'player.name',
  ),
  playerFirstName: _optionalString(
    player['firstName'],
  ),
  playerLastName: _optionalString(
    player['lastName'],
  ),
  playerGender: _parseGender(
    player['gender'],
  ),
  playerBirthYear: _requireInt(
    player['birthYear'],
    'player.birthYear',
  ),
  playerBirthMonth: player['birthMonth'] is int ? player['birthMonth'] as int : 1,
  playerBirthDay: player['birthDay'] is int ? player['birthDay'] as int : 1,
  playerHealth: _requireInt(
    stats['health'],
    'player.stats.health',
  ),
  playerIntelligence: _requireInt(
    stats['intelligence'],
    'player.stats.intelligence',
  ),
  playerFitness: _requireInt(
    stats['fitness'],
    'player.stats.fitness',
  ),
  playerHappiness: _requireInt(
    stats['happiness'],
    'player.stats.happiness',
  ),
  playerWillpower: _requireInt(
    stats['willpower'],
    'player.stats.willpower',
  ),
  playerCharisma: _requireInt(
    stats['charisma'],
    'player.stats.charisma',
  ),
  playerCreativity: _requireInt(
    stats['creativity'],
    'player.stats.creativity',
  ),
  playerLuck: _requireInt(
    stats['luck'],
    'player.stats.luck',
  ),
  playerMoneyMinorUnits: _requireInt(
    player['moneyMinorUnits'],
    'player.moneyMinorUnits',
  ),
  playerAssets: _parsePlayerAssets(
    playerAssetsJson,
  ),
  playerDebtMinorUnits: playerDebtJson == null
      ? 0
      : _requireInt(
          playerDebtJson,
          'player.debtMinorUnits',
        ),
  playerAppearance: appearanceJson == null
      ? const CharacterAppearance()
      : _parseAppearance(
          appearanceJson,
        ),
  playerLocation: locationJson == null
      ? null
      : _parseLocation(
          locationJson,
        ),
  playerStartingBackgroundTier:
      startingBackgroundJson == null
          ? null
          : _parseStartingBackgroundTier(
              startingBackgroundJson,
            ),
  familyHousehold: familyHouseholdJson == null
      ? null
      : _parseFamilyHousehold(
          familyHouseholdJson,
        ),
  events: List.unmodifiable(
    eventsJson
        .map(
          (event) => _parseEvent(event),
        )
        .toList(growable: false),
  ),
);

}

static List<PlayerAsset> _parsePlayerAssets(
Object? value,
) {
if (value == null) {
return const <PlayerAsset>[];
}

if (value is! List) {
  throw const FormatException(
    'Field "player.assets" must be a list.',
  );
}

return List<PlayerAsset>.unmodifiable(
  value.map((entry) {
    final asset = _requireMap(
      entry,
      'player.assets[]',
    );

    final typeName = _requireString(
      asset['type'],
      'player.assets[].type',
    );

    PlayerAssetType? parsedType;

    for (final type in PlayerAssetType.values) {
      if (type.name == typeName) {
        parsedType = type;
        break;
      }
    }

    if (parsedType == null) {
      throw FormatException(
        'Unknown player asset type: $typeName',
      );
    }

    return PlayerAsset(
      id: _requireString(
        asset['id'],
        'player.assets[].id',
      ),
      name: _requireString(
        asset['name'],
        'player.assets[].name',
      ),
      type: parsedType,
      value: Money.fromMinorUnits(
        _requireInt(
          asset['valueMinorUnits'],
          'player.assets[].valueMinorUnits',
        ),
      ),
    );
  }),
);

}

static Map<String, dynamic> _familyHouseholdToJson(
FamilyHousehold household,
) {
return {
'id': household.id,
'isAffairConception': household.isAffairConception,
'raisedByFather': household.raisedByFather,
'cashSavingsMinorUnits':
household.cashSavings.minorUnits,
'housingStatus': household.housingStatus.name,
'annualLivingCostsMinorUnits':
household.annualLivingCosts.minorUnits,
'totalDebtMinorUnits': household.totalDebt.minorUnits,
'parents': household.parents
.map(
(parent) => {
'id': parent.id,
'firstName': parent.firstName,
'lastName': parent.lastName,
'gender': parent.gender.name,
'birthYear': parent.birthYear,
'role': parent.role.name,
'employmentStatus':
parent.employmentStatus.name,
'occupation': parent.occupation,
'annualIncomeMinorUnits':
parent.annualIncome.minorUnits,
'incomeStability':
parent.incomeStability.name,
'countryCode': parent.countryCode,
'cashBalanceMinorUnits': parent.cashBalance.minorUnits,
'annualExpensesMinorUnits': parent.annualExpenses.minorUnits,
'isAlive': parent.isAlive,
'deathYear': parent.deathYear,
'siblingCount': parent.siblingCount,
'relationshipPercent': parent.relationshipPercent,
'appearance': {
'base': parent.appearance.base,
'skinTone': parent.appearance.skinTone,
'hair': parent.appearance.hair,
'infantHair': parent.appearance.infantHair,
'toddlerHair': parent.appearance.toddlerHair,
'childHair': parent.appearance.childHair,
'hairColor': parent.appearance.hairColor,
'eyes': parent.appearance.eyes,
'eyeColor': parent.appearance.eyeColor,
'eyebrows': parent.appearance.eyebrows,
'beard': parent.appearance.beard,
},
},
)
.toList(growable: false),
'siblings': household.siblings.map((sibling) => {
  'id': sibling.id,
  'firstName': sibling.firstName,
  'lastName': sibling.lastName,
  'gender': sibling.gender.name,
  'birthYear': sibling.birthYear,
  'relationshipPercent': sibling.relationshipPercent,
  'isTwin': sibling.isTwin,
  'relationship': sibling.relationship.name,
  'countryCode': sibling.countryCode,
  'appearance': {
    'base': sibling.appearance.base,
    'skinTone': sibling.appearance.skinTone,
    'hair': sibling.appearance.hair,
    'infantHair': sibling.appearance.infantHair,
    'toddlerHair': sibling.appearance.toddlerHair,
    'childHair': sibling.appearance.childHair,
    'hairColor': sibling.appearance.hairColor,
    'eyes': sibling.appearance.eyes,
    'eyeColor': sibling.appearance.eyeColor,
    'eyebrows': sibling.appearance.eyebrows,
    'beard': sibling.appearance.beard,
  },
}).toList(growable: false),
'assets': household.assets
.map(
(asset) => {
'id': asset.id,
'name': asset.name,
'type': asset.type.name,
'valueMinorUnits': asset.value.minorUnits,
'ownerNpcId': asset.ownerNpcId,
},
)
.toList(growable: false),
};
}

static FamilyHousehold _parseFamilyHousehold(
Object? value,
) {
final json = _requireMap(
value,
'familyHousehold',
);
final parentsJson = json['parents'];
final assetsJson = json['assets'];

if (parentsJson is! List) {
  throw const FormatException(
    'Field "familyHousehold.parents" must be a list.',
  );
}

if (assetsJson is! List) {
  throw const FormatException(
    'Field "familyHousehold.assets" must be a list.',
  );
}

final isLegacyFamilyFinancialSchema = parentsJson.any(
  (value) => value is Map && !value.containsKey('cashBalanceMinorUnits'),
);

final parents = parentsJson
    .map(
      (value) {
        final parent = _requireMap(
          value,
          'familyHousehold.parents[]',
        );

        final occupation = _optionalString(
          parent['occupation'],
        );

        return ParentNpc(
          id: _requireString(
            parent['id'],
            'parent.id',
          ),
          firstName: _requireString(
            parent['firstName'],
            'parent.firstName',
          ),
          lastName: _requireString(
            parent['lastName'],
            'parent.lastName',
          ),
          gender: _parseGender(
            parent['gender'],
          ),
          birthYear: _requireInt(
            parent['birthYear'],
            'parent.birthYear',
          ),
          role: _parseFamilyRole(
            parent['role'],
          ),
          employmentStatus: _parseEmploymentStatus(
            parent['employmentStatus'],
          ),
          occupation: occupation.isEmpty
              ? null
              : occupation,
          annualIncome: Money.fromMinorUnits(
            parent.containsKey('annualIncomeMinorUnits')
                ? _requireInt(
                    parent['annualIncomeMinorUnits'],
                    'parent.annualIncomeMinorUnits',
                  )
                : _requireInt(
                      parent['monthlyIncomeMinorUnits'],
                      'parent.monthlyIncomeMinorUnits',
                    ) *
                    12,
          ),
          incomeStability: _parseIncomeStability(
            parent['incomeStability'],
          ),
          countryCode: _optionalString(parent['countryCode']).isEmpty
              ? 'ID' : _optionalString(parent['countryCode']),
          cashBalance: Money.fromMinorUnits(
            parent['cashBalanceMinorUnits'] == null
                ? ((json['cashSavingsMinorUnits'] is int)
                        ? json['cashSavingsMinorUnits'] as int
                        : 0) ~/
                    (parentsJson.isEmpty ? 1 : parentsJson.length)
                : _requireInt(
                    parent['cashBalanceMinorUnits'],
                    'parent.cashBalanceMinorUnits',
                  ),
          ),
          annualExpenses: Money.fromMinorUnits(
            parent['annualExpensesMinorUnits'] == null ? 0 : _requireInt(parent['annualExpensesMinorUnits'], 'parent.annualExpensesMinorUnits'),
          ),
          isAlive: parent['isAlive'] is bool ? parent['isAlive'] as bool : true,
          deathYear: parent['deathYear'] == null ? null : _requireInt(parent['deathYear'], 'parent.deathYear'),
          siblingCount: parent['siblingCount'] == null ? 0 : _requireInt(parent['siblingCount'], 'parent.siblingCount'),
          relationshipPercent: parent['relationshipPercent'] is int ? (parent['relationshipPercent'] as int).clamp(-100, 100).toInt() : 50,
          appearance: parent['appearance'] == null
              ? const CharacterAppearance()
              : _parseAppearance(parent['appearance']),
        );
      },
    )
    .toList(growable: false);

final assets = assetsJson
    .map(
      (value) {
        final asset = _requireMap(
          value,
          'familyHousehold.assets[]',
        );

        final ownerNpcId = _optionalString(
          asset['ownerNpcId'],
        );

        return FamilyAsset(
          id: _requireString(
            asset['id'],
            'asset.id',
          ),
          name: _requireString(
            asset['name'],
            'asset.name',
          ),
          type: _parseFamilyAssetType(
            asset['type'],
          ),
          value: Money.fromMinorUnits(
            _requireInt(
              asset['valueMinorUnits'],
              'asset.valueMinorUnits',
            ),
          ),
          // Legacy unowned/shared assets are assigned once to the first
          // parent so the estate cannot be inherited by multiple parents.
          ownerNpcId: ownerNpcId.isEmpty && isLegacyFamilyFinancialSchema
              ? (parents.isEmpty ? null : parents.first.id)
              : (ownerNpcId.isEmpty ? null : ownerNpcId),
        );
      },
    )
    .toList(growable: false);

final parentsWithAssets = parents.map((parent) => parent.copyWith(
  assets: assets.where((asset) => asset.ownerNpcId == parent.id).toList(growable: false),
)).toList(growable: false);
final siblingsJson = json['siblings'];
final siblings = siblingsJson is List
    ? siblingsJson.map((value) {
        final sibling = _requireMap(value, 'familyHousehold.siblings[]');
        return SiblingNpc(
          id: _requireString(sibling['id'], 'sibling.id'),
          firstName: _requireString(sibling['firstName'], 'sibling.firstName'),
          lastName: _requireString(sibling['lastName'], 'sibling.lastName'),
          gender: _parseGender(sibling['gender']),
          birthYear: _requireInt(sibling['birthYear'], 'sibling.birthYear'),
          relationshipPercent: sibling['relationshipPercent'] is int ? (sibling['relationshipPercent'] as int).clamp(-100, 100).toInt() : 50,
          isTwin: sibling['isTwin'] == true,
          relationship: _parseSiblingRelationship(sibling['relationship']),
          countryCode: _optionalString(sibling['countryCode']).isEmpty
              ? 'ID' : _optionalString(sibling['countryCode']),
          appearance: sibling['appearance'] == null
              ? const CharacterAppearance()
              : _parseAppearance(sibling['appearance']),
        );
      }).toList(growable: false)
    : const <SiblingNpc>[];

return FamilyHousehold(
  id: _requireString(
    json['id'],
    'familyHousehold.id',
  ),
  isAffairConception: json['isAffairConception'] == true,
  raisedByFather: json['raisedByFather'] == true,
  parents: parentsWithAssets,
  siblings: siblings,
  // Legacy aggregate savings are migrated into parent accounts above.
  // Keeping the old aggregate would count the same money twice.
  cashSavings: isLegacyFamilyFinancialSchema
      ? const Money.zero()
      : Money.fromMinorUnits(
          _requireInt(
            json['cashSavingsMinorUnits'],
            'familyHousehold.cashSavingsMinorUnits',
          ),
        ),
  assets: assets,
  housingStatus: _parseHousingStatus(
    json['housingStatus'],
  ),
  annualLivingCosts: Money.fromMinorUnits(
    json.containsKey('annualLivingCostsMinorUnits')
        ? _requireInt(
            json['annualLivingCostsMinorUnits'],
            'familyHousehold.annualLivingCostsMinorUnits',
          )
        : _requireInt(
              json['monthlyLivingCostsMinorUnits'],
              'familyHousehold.monthlyLivingCostsMinorUnits',
            ) *
            12,
  ),
  totalDebt: Money.fromMinorUnits(
    _requireInt(
      json['totalDebtMinorUnits'],
      'familyHousehold.totalDebtMinorUnits',
    ),
  ),
);

}

static StartingBackgroundTier
_parseStartingBackgroundTier(
Object? value,
) {
if (value is! String) {
throw const FormatException(
'Field "startingBackground" must be a string.',
);
}

for (final tier in StartingBackgroundTier.values) {
  if (tier.name == value) {
    return tier;
  }
}

throw FormatException(
  'Unknown starting background tier: $value',
);

}

static FamilyRole _parseFamilyRole(
Object? value,
) {
for (final role in FamilyRole.values) {
if (role.name == value) {
return role;
}
}

throw FormatException(
  'Unknown family role: $value',
);

}

static EmploymentStatus _parseEmploymentStatus(
Object? value,
) {
for (final status in EmploymentStatus.values) {
if (status.name == value) {
return status;
}
}

throw FormatException(
  'Unknown employment status: $value',
);

}

static IncomeStability _parseIncomeStability(
Object? value,
) {
for (final stability in IncomeStability.values) {
if (stability.name == value) {
return stability;
}
}

throw FormatException(
  'Unknown income stability: $value',
);

}

static SiblingRelationship _parseSiblingRelationship(Object? value) {
  for (final relationship in SiblingRelationship.values) {
    if (relationship.name == value) return relationship;
  }
  throw FormatException('Unknown sibling relationship: $value');
}

static HousingStatus _parseHousingStatus(
Object? value,
) {
for (final status in HousingStatus.values) {
if (status.name == value) {
return status;
}
}

throw FormatException(
  'Unknown housing status: $value',
);

}

static FamilyAssetType _parseFamilyAssetType(
Object? value,
) {
for (final type in FamilyAssetType.values) {
if (type.name == value) {
return type;
}
}

throw FormatException(
  'Unknown family asset type: $value',
);

}

static CharacterLocation _parseLocation(
Object? value,
) {
final location = _requireMap(
value,
'player.location',
);

final parsedLocation = CharacterLocation(
  countryCode: _requireString(
    location['countryCode'],
    'player.location.countryCode',
  ),
  cityId: _requireString(
    location['cityId'],
    'player.location.cityId',
  ),
);

if (!parsedLocation.isValid) {
  throw const FormatException(
    'Field "player.location" contains an invalid country and city combination.',
  );
}

return parsedLocation;

}

static CharacterAppearance _parseAppearance(
Object? value,
) {
final appearance = _requireMap(
value,
'player.appearance',
);

final base = _optionalString(appearance['base']);
final skinTone = _optionalString(appearance['skinTone']);
final hair = _optionalString(appearance['hair']);
final infantHair = _optionalString(
  appearance['infantHair'],
);
final toddlerHair = _optionalString(
  appearance['toddlerHair'],
);
final childHair = _optionalString(
  appearance['childHair'],
);
final hairColor = _optionalString(
  appearance['hairColor'],
);
final eyes = _optionalString(appearance['eyes']);
final eyeColor = _optionalString(
  appearance['eyeColor'],
);
final eyebrows = _optionalString(
  appearance['eyebrows'],
);
final beard = _optionalString(appearance['beard']);

return CharacterAppearance(
  base: base.isEmpty ? 'default' : base,
  skinTone: skinTone.isEmpty ? 'default' : skinTone,
  hair: hair.isEmpty ? 'default' : hair,
  infantHair: infantHair.isEmpty ? null : infantHair,
  toddlerHair: toddlerHair.isEmpty ? null : toddlerHair,
  childHair: childHair.isEmpty ? null : childHair,
  hairColor: hairColor.isEmpty ? 'default' : hairColor,
  eyes: eyes.isEmpty ? 'default' : eyes,
  eyeColor: eyeColor.isEmpty ? 'default' : eyeColor,
  eyebrows: eyebrows.isEmpty ? 'default' : eyebrows,
  beard: beard.isEmpty ? 'none' : beard,
);

}

static Map<String, dynamic> _requireMap(
Object? value,
String field,
) {
if (value is Map<String, dynamic>) {
return value;
}

if (value is Map) {
  return Map<String, dynamic>.from(value);
}

throw FormatException(
  'Field "$field" must be an object.',
);

}

static String _requireString(
Object? value,
String field,
) {
if (value is String) {
return value;
}

throw FormatException(
  'Field "$field" must be a string.',
);

}

static String _optionalString(
Object? value,
) {
if (value == null) {
return '';
}

if (value is String) {
  return value;
}

throw const FormatException(
  'Optional string fields must be strings.',
);

}

static int _requireInt(
Object? value,
String field,
) {
if (value is int) {
return value;
}

throw FormatException(
  'Field "$field" must be an integer.',
);

}

static Gender _parseGender(
Object? value,
) {
if (value is! String) {
throw const FormatException(
'Gender fields must be strings.',
);
}

for (final gender in Gender.values) {
  if (gender.name == value) {
    return gender;
  }
}

throw FormatException(
  'Unknown gender: $value',
);

}

static SimulationEvent _parseEvent(
Object? value,
) {
final event = _requireMap(
value,
'event',
);

return SimulationEvent(
  id: _requireString(
    event['id'],
    'event.id',
  ),
  type: _parseEventType(
    event['type'],
  ),
  year: _requireInt(
    event['year'],
    'event.year',
  ),
  title: _requireString(
    event['title'],
    'event.title',
  ),
  description: _requireString(
    event['description'],
    'event.description',
  ),
);

}

static SimulationEventType _parseEventType(
Object? value,
) {
if (value is! String) {
throw const FormatException(
'Field "event.type" must be a string.',
);
}

for (final type in SimulationEventType.values) {
  if (type.name == value) {
    return type;
  }
}

throw FormatException(
  'Unknown simulation event type: $value',
);

}
}
