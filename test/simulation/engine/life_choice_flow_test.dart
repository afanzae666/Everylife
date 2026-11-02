import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/systems/event_system.dart';
import 'package:everylife/simulation/commands/age_up_command.dart';
import 'package:everylife/simulation/events/life_event_catalog.dart';

void main() {
  SimulationEngine engineWith(LifeProgress progress) {
    final base = SimulationEngine.create(
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        birthYear: 2026,
      ),
      seed: 5,
      saveRepository: InMemorySaveRepository(),
    );

    return SimulationEngine(
      initialState: base.state.copyWith(lifeProgress: progress),
      random: SeededRandom(1),
      saveRepository: InMemorySaveRepository(),
    );
  }

  LifeProgress pendingTantrum() => const LifeProgress(
        pending: PendingLifeEvent(eventId: 'toddler_tantrum', year: 2026),
      );

  test('aging up is blocked while a decision is pending', () {
    final engine = engineWith(pendingTantrum());
    final yearBefore = engine.state.clock.currentYear;

    final result = engine.ageUp();

    expect(result.isFailure, isTrue);
    expect(engine.state.clock.currentYear, yearBefore);
    expect(engine.nextTickId, 1);
  });

  test('aging up is blocked after the life has ended', () {
    final engine = engineWith(
      const LifeProgress(
        ending: LifeEnding(year: 2026, age: 0, cause: 'test'),
      ),
    );

    expect(engine.ageUp().isFailure, isTrue);
  });

  test('resolving a choice applies it, logs it, and unblocks aging', () {
    final engine = engineWith(pendingTantrum());
    final before = engine.state.player.stats;

    final result = engine.resolveLifeChoice('breathe');

    expect(result.isSuccess, isTrue);
    if (result case Success<LifeChoiceResult>(:final value)) {
      expect(value.eventTitle, 'Supermarket Meltdown');
      expect(value.resultText, isNotEmpty);
    }

    final state = engine.state;

    expect(state.lifeProgress.pending, isNull);
    expect(state.lifeProgress.choices['toddler_tantrum'], 'breathe');
    expect(state.player.stats.willpower, before.willpower + 3);
    expect(state.player.stats.happiness, before.happiness - 1);
    expect(state.events.last.type, SimulationEventType.lifeChoice);
    expect(engine.ageUp().isSuccess, isTrue);
  });

  test('unknown choices and missing events are rejected', () {
    final engine = engineWith(pendingTantrum());

    expect(engine.resolveLifeChoice('nope').isFailure, isTrue);
    expect(engine.state.lifeProgress.pending, isNotNull);

    final idle = engineWith(const LifeProgress());

    expect(idle.resolveLifeChoice('breathe').isFailure, isTrue);
  });

  test('an unknown pending event is cleared instead of trapping the player',
      () {
    final engine = engineWith(
      const LifeProgress(
        pending: PendingLifeEvent(eventId: 'removed_event', year: 2026),
      ),
    );

    expect(engine.pendingLifeEvent, isNull);
    expect(engine.resolveLifeChoice('anything').isFailure, isTrue);
    expect(engine.state.lifeProgress.pending, isNull);
  });

  test('choices the player cannot afford are refused', () {
    final engine = engineWith(
      const LifeProgress(
        pending: PendingLifeEvent(eventId: 'after_school_path', year: 2026),
      ),
    );
    final event = engine.pendingLifeEvent!;
    final gapYear = event.choices.firstWhere((choice) => choice.id == 'gap_year');

    expect(engine.canAffordChoice(gapYear), isFalse);
    expect(engine.resolveLifeChoice('gap_year').isFailure, isTrue);
    expect(engine.state.lifeProgress.pending, isNotNull);
  });

  test('the event system creates pending decisions and automatic events', () {
    var sawPending = false;
    var sawAutomatic = false;

    for (var seed = 0; seed < 80; seed++) {
      final base = engineWith(const LifeProgress()).state;
      final state = base.copyWith(
        clock: base.clock.advanceYear().advanceYear().advanceYear(),
      );

      final next = EventSystem(
        random: SeededRandom(seed),
        eventChancePercent: 100,
      ).process(state: state, command: const AgeUpCommand());

      final pending = next.lifeProgress.pending;

      if (pending != null) {
        sawPending = true;
        expect(LifeEventCatalog.byId(pending.eventId), isNotNull);
        expect(next.lifeProgress.lastSeenYear, contains(pending.eventId));
      } else if (next.events.length > state.events.length) {
        sawAutomatic = true;
        expect(next.events.last.type, SimulationEventType.lifeEvent);
      }
    }

    expect(sawPending, isTrue);
    expect(sawAutomatic, isTrue);
  });

  test('the event system does nothing while a decision is pending', () {
    final state = engineWith(pendingTantrum()).state;

    final next = EventSystem(
      random: SeededRandom(1),
      eventChancePercent: 100,
    ).process(state: state, command: const AgeUpCommand());

    expect(next.lifeProgress.pending?.eventId, 'toddler_tantrum');
    expect(next.events.length, state.events.length);
  });
}
