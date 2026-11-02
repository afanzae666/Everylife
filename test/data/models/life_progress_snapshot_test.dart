import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/models/world_state_snapshot.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';

void main() {
  WorldState stateWith(LifeProgress progress) => WorldState(
        clock: const SimulationClock(currentYear: 2040),
        player: Character.create(
          id: 'player-1',
          name: 'Test Player',
          birthYear: 2026,
        ),
        events: const [],
        lifeProgress: progress,
      );

  Map<String, dynamic> roundTripJson(WorldState state) {
    final encoded = jsonEncode(WorldStateSnapshot.fromWorldState(state).toJson());

    return jsonDecode(encoded) as Map<String, dynamic>;
  }

  test('life progress survives a save and load', () {
    const progress = LifeProgress(
      flags: {'bullied', 'smoker'},
      lastSeenYear: {'school_bully': 2034, 'school_test': 2036},
      choices: {'school_bully': 'avoid'},
      pending: PendingLifeEvent(eventId: 'school_test', year: 2040),
      ending: LifeEnding(
        year: 2040,
        age: 14,
        cause: 'a sudden illness',
        netWorthMinorUnits: 1234,
      ),
    );

    final restored = WorldStateSnapshot.fromJson(
      roundTripJson(stateWith(progress)),
    ).toWorldState().lifeProgress;

    expect(restored.flags, {'bullied', 'smoker'});
    expect(restored.lastSeenYear, progress.lastSeenYear);
    expect(restored.choices, progress.choices);
    expect(restored.pending?.eventId, 'school_test');
    expect(restored.pending?.year, 2040);
    expect(restored.ending?.age, 14);
    expect(restored.ending?.cause, 'a sudden illness');
    expect(restored.ending?.netWorthMinorUnits, 1234);
  });

  test('a save without life progress loads as an empty, living life', () {
    final json = roundTripJson(stateWith(const LifeProgress()));
    json.remove('lifeProgress');

    final restored =
        WorldStateSnapshot.fromJson(json).toWorldState().lifeProgress;

    expect(restored.flags, isEmpty);
    expect(restored.pending, isNull);
    expect(restored.ending, isNull);
    expect(restored.isAlive, isTrue);
  });

  test('malformed life progress falls back to an empty progress', () {
    final json = roundTripJson(stateWith(const LifeProgress()));
    json['lifeProgress'] = 'garbage';

    final restored =
        WorldStateSnapshot.fromJson(json).toWorldState().lifeProgress;

    expect(restored.flags, isEmpty);
    expect(restored.isAlive, isTrue);
  });
}
