import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/simulation/events/life_event_catalog.dart';

void main() {
  const events = LifeEventCatalog.all;

  List<LifeOutcome> outcomesOf(LifeEventDefinition event) => [
        ...event.autoOutcomes,
        for (final choice in event.choices) ...choice.outcomes,
      ];

  test('event ids are unique and can be looked up', () {
    final ids = events.map((event) => event.id).toList();

    expect(ids.toSet().length, ids.length);

    for (final event in events) {
      expect(LifeEventCatalog.byId(event.id), same(event));
    }

    expect(LifeEventCatalog.byId('does_not_exist'), isNull);
  });

  test('every event has valid ages, weights, and text', () {
    for (final event in events) {
      expect(event.title.trim(), isNotEmpty, reason: event.id);
      expect(event.description.trim(), isNotEmpty, reason: event.id);
      expect(event.minAge, lessThanOrEqualTo(event.maxAge), reason: event.id);
      expect(event.minAge, greaterThanOrEqualTo(0), reason: event.id);
      expect(event.weight, greaterThan(0), reason: event.id);
      expect(event.cooldownYears, greaterThanOrEqualTo(0), reason: event.id);
    }
  });

  test('every event has choices or automatic outcomes, never both', () {
    for (final event in events) {
      final hasChoices = event.choices.isNotEmpty;
      final hasAuto = event.autoOutcomes.isNotEmpty;

      expect(hasChoices != hasAuto, isTrue, reason: event.id);
    }
  });

  test('choices and outcomes are well formed', () {
    for (final event in events) {
      final choiceIds = event.choices.map((choice) => choice.id).toList();
      expect(choiceIds.toSet().length, choiceIds.length, reason: event.id);

      for (final choice in event.choices) {
        expect(choice.label.trim(), isNotEmpty, reason: event.id);
        expect(choice.outcomes, isNotEmpty, reason: '${event.id}/${choice.id}');
      }

      for (final outcome in outcomesOf(event)) {
        expect(outcome.text.trim(), isNotEmpty, reason: event.id);
        expect(outcome.weight, greaterThan(0), reason: event.id);

        for (final effect in outcome.stats) {
          expect(effect.delta.abs(), lessThanOrEqualTo(15), reason: event.id);
        }
      }
    }
  });

  test('university and school events only reach the right students', () {
    for (final event in events) {
      if (event.id.startsWith('uni_')) {
        expect(
          event.requiredFlags,
          contains(SystemFlags.universityStudent),
          reason: event.id,
        );
      }

      if (event.id.startsWith('school_') && event.id != 'school_crush') {
        expect(
          event.requiredFlags,
          contains(SystemFlags.schoolStudent),
          reason: event.id,
        );
      }
    }
  });

  test('events about adult life are not offered to children', () {
    final adultWords = RegExp(
      r'\b(salary|boss|coworker|mortgage|landlord|nightclub|casino)\b',
      caseSensitive: false,
    );

    for (final event in events) {
      final text = '${event.title} ${event.description}';

      if (adultWords.hasMatch(text)) {
        expect(event.minAge, greaterThanOrEqualTo(16), reason: event.id);
      }
    }
  });

  test('flags that events require are set by some outcome', () {
    final addable = <String>{
      ...SystemFlags.all,
      for (final event in events)
        for (final outcome in outcomesOf(event)) ...outcome.addFlags,
    };

    for (final event in events) {
      for (final flag in event.requiredFlags) {
        expect(addable, contains(flag), reason: '${event.id} needs "$flag"');
      }
    }
  });

  test('events with several choices always carry some risk or cost', () {
    for (final event in events.where((event) => event.choices.length > 1)) {
      final hasDownside = outcomesOf(event).any(
        (outcome) =>
            outcome.moneyBase < 0 ||
            outcome.stats.any((effect) => effect.delta < 0),
      );

      expect(hasDownside, isTrue, reason: event.id);
    }
  });

  test('a fresh life has at least one possible event at every age', () {
    final player = Character.create(
      id: 'player-1',
      name: 'Test Player',
      birthYear: 2000,
    );

    for (var age = 1; age <= 100; age++) {
      final state = WorldState(
        clock: SimulationClock(currentYear: 2000 + age),
        player: player,
        events: const [],
      );

      expect(
        LifeEventCatalog.eligible(state: state, age: age),
        isNotEmpty,
        reason: 'No event available at age $age.',
      );
    }
  });
}
