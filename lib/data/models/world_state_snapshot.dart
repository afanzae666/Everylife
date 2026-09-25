import '../../core/money/money.dart';
import '../../domain/character/character.dart';
import '../../domain/character/character_stats.dart';
import '../../domain/character/gender.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/time/simulation_clock.dart';
import '../../domain/world/world_state.dart';

class WorldStateSnapshot {
  const WorldStateSnapshot({
    required this.currentYear,
    required this.playerId,
    required this.playerName,
    required this.playerGender,
    required this.playerBirthYear,
    required this.playerHealth,
    required this.playerIntelligence,
    required this.playerFitness,
    required this.playerHappiness,
    required this.playerWillpower,
    required this.playerCharisma,
    required this.playerCreativity,
    required this.playerLuck,
    required this.playerMoneyMinorUnits,
    required this.events,
  });

  final int currentYear;

  final String playerId;
  final String playerName;
  final Gender playerGender;
  final int playerBirthYear;

  final int playerHealth;
  final int playerIntelligence;
  final int playerFitness;
  final int playerHappiness;
  final int playerWillpower;
  final int playerCharisma;
  final int playerCreativity;
  final int playerLuck;

  final int playerMoneyMinorUnits;

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
      playerGender: player.gender,
      playerBirthYear: player.birthYear,
      playerHealth: stats.health,
      playerIntelligence: stats.intelligence,
      playerFitness: stats.fitness,
      playerHappiness: stats.happiness,
      playerWillpower: stats.willpower,
      playerCharisma: stats.charisma,
      playerCreativity: stats.creativity,
      playerLuck: stats.luck,
      playerMoneyMinorUnits: player.money.minorUnits,
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
        gender: playerGender,
        birthYear: playerBirthYear,
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
      ),
      events: List.unmodifiable(events),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentYear': currentYear,
      'player': {
        'id': playerId,
        'name': playerName,
        'gender': playerGender.name,
        'birthYear': playerBirthYear,
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
      },
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

    final eventsJson = json['events'];

    if (eventsJson is! List) {
      throw FormatException(
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
      playerGender: _parseGender(
        player['gender'],
      ),
      playerBirthYear: _requireInt(
        player['birthYear'],
        'player.birthYear',
      ),
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
      events: List.unmodifiable(
        eventsJson
            .map(
              (event) => _parseEvent(event),
            )
            .toList(growable: false),
      ),
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

  static Gender _parseGender(Object? value) {
    if (value is! String) {
      throw const FormatException(
        'Field "player.gender" must be a string.',
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

  static SimulationEvent _parseEvent(Object? value) {
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
