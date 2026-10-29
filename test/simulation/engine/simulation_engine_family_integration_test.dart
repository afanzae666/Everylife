
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/cultural_name_catalog.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/domain/family/parent_npc.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  Character createPlayer() => Character.create(
        id: 'player-family-test',
        firstName: 'Alfan',
        lastName: 'Zaenal',
        birthYear: 2026,
      );

  SimulationEngine createEngine({int seed = 12345}) =>
      SimulationEngine.create(
        player: createPlayer(),
        seed: seed,
        saveRepository: InMemorySaveRepository(),
      );

  SimulationEvent eventByTitle(
    SimulationEngine engine,
    String title,
  ) =>
      engine.state.events.singleWhere((event) => event.title == title);

  List<SimulationEvent> eventsByTitle(
    SimulationEngine engine,
    String title,
  ) =>
      engine.state.events.where((event) => event.title == title).toList();

  test('NPC interaction updates relationship and appends a life event', () {
    final engine = createEngine();
    // NPC interactions are unavailable during infancy (ages 0–2).
    engine.ageUp();
    engine.ageUp();
    engine.ageUp();
    final parent = engine.state.familyHousehold!.parents.firstWhere(
      (npc) => npc.isAlive,
    );
    final originalScore = parent.relationshipPercent;
    final originalEventCount = engine.state.events.length;

    final result = engine.interactWithNpc(
      npcId: parent.id,
      action: 'Spend Time',
    );

    expect(result.isSuccess, isTrue);
    expect(engine.state.familyHousehold!.parents
        .firstWhere((npc) => npc.id == parent.id).relationshipPercent,
        (originalScore + 5).clamp(-100, 100));
    expect(engine.state.events, hasLength(originalEventCount + 1));
    final event = engine.state.events.last;
    expect(event.type, SimulationEventType.npcInteraction);
    expect(event.title, 'Spend Time');
    expect(event.description, contains(parent.fullName));
    expect(event.year, engine.state.clock.currentYear);
  });

  test('blocks NPC interactions during infancy', () {
    final engine = createEngine();
    final parent = engine.state.familyHousehold!.parents.firstWhere(
      (npc) => npc.isAlive,
    );

    final result = engine.interactWithNpc(
      npcId: parent.id,
      action: 'Talk',
    );

    expect(result.isFailure, isTrue);
    expect(engine.state.events.where((event) =>
        event.type == SimulationEventType.npcInteraction), isEmpty);
  });

  test('interaction narrative is first-person and age-appropriate', () {
    final childEngine = createEngine();
    childEngine.ageUp();
    childEngine.ageUp();
    childEngine.ageUp();
    final childParent = childEngine.state.familyHousehold!.parents.firstWhere(
      (npc) => npc.isAlive,
    );
    final childResult = childEngine.interactWithNpc(
      npcId: childParent.id,
      action: 'Talk',
    );
    expect(childResult.isSuccess, isTrue);
    if (childResult case Success<NpcInteractionOutcome>(:final value)) {
      expect(value.narrative, startsWith('I '));
      expect(value.narrative, contains(childParent.fullName));
      expect(value.narrative, isNot(contains('You had a conversation')));
    }

    final teenEngine = createEngine(seed: 98765);
    for (var i = 0; i < 13; i++) {
      teenEngine.ageUp();
    }
    final teenParent = teenEngine.state.familyHousehold!.parents.firstWhere(
      (npc) => npc.isAlive,
    );
    final teenResult = teenEngine.interactWithNpc(
      npcId: teenParent.id,
      action: 'Talk',
    );
    expect(teenResult.isSuccess, isTrue);
    if (teenResult case Success<NpcInteractionOutcome>(:final value)) {
      expect(value.narrative, startsWith('I '));
      expect(value.narrative, contains(teenParent.fullName));
    }
  });

  test('blocks non-basic interactions for toddler and child stages', () {
    final engine = createEngine();
    engine.ageUp();
    engine.ageUp();
    engine.ageUp();
    final parent = engine.state.familyHousehold!.parents.firstWhere(
      (npc) => npc.isAlive,
    );

    final result = engine.interactWithNpc(
      npcId: parent.id,
      action: 'Argue',
    );

    expect(result.isFailure, isTrue);
  });

  test('generates individual parent financial records for a new life', () {
    final engine = createEngine();
    final parents = engine.state.familyHousehold!.parents;

    expect(parents, isNotEmpty);
    for (final parent in parents) {
      if (parent.role != FamilyRole.guardian) {
        expect(parent.lastName, 'Zaenal');
      } else {
        expect(parent.lastName, isNot('Zaenal'));
      }
      expect(parent.countryCode, 'ID');
      expect(parent.cashBalance.minorUnits, greaterThanOrEqualTo(0));
      expect(parent.annualExpenses.minorUnits, greaterThanOrEqualTo(0));
      expect(parent.assets, isNotNull);
    }

    expect(engine.state.familyHousehold!.cashSavings.minorUnits, 0);
  });

  test('creates separate starting family and economy events', () {
    final engine = createEngine();
    final household = engine.state.familyHousehold!;
    final familyEvent = eventByTitle(engine, 'Starting Family');
    final economyEvents = eventsByTitle(engine, 'Starting Economy');
    final economyDescription = economyEvents.map((event) => event.description).join('\n');

    expect(familyEvent.type, SimulationEventType.startingLifeEvent);
    expect(economyEvents.first.type, SimulationEventType.startingLifeEvent);
    expect(familyEvent.year, 2026);
    expect(economyEvents.first.year, 2026);
    expect(familyEvent.description, isNotEmpty);
    expect(economyDescription, isNotEmpty);
    expect(
      economyEvents.every((event) => !event.description.contains('•')),
      isTrue,
    );
    final birthEvent = engine.state.events.singleWhere(
      (event) => event.id == 'life-created',
    );
    expect(birthEvent.description, contains('I was born in 2026.'));
    expect(
      birthEvent.description.length,
      greaterThan('I was born in 2026.'.length),
    );
    expect(
      engine.state.events.where((event) => event.title == 'My Conception'),
      isEmpty,
    );

    expect(
      familyEvent.description,
      isNot(contains('works as a')),
    );
    expect(
      familyEvent.description,
      isNot(contains('currently unemployed')),
    );
    expect(
      economyDescription,
      isNot(contains('biological parents')),
    );
    expect(
      economyDescription,
      isNot(contains('orphanage')),
    );

    for (final parent in household.parents) {
      expect(
        parent.fullName,
        CulturalNameCatalog.formatFullName(
          parent.countryCode,
          parent.firstName,
          parent.lastName,
        ),
      );

      if (parent.isAlive) {
        final roleLabel = switch (parent.role) {
          FamilyRole.father => 'My father, ${parent.fullName},',
          FamilyRole.mother => 'My mother, ${parent.fullName},',
          FamilyRole.guardian => 'My guardian, ${parent.fullName},',
          FamilyRole.stepFather => 'My stepfather, ${parent.fullName},',
          FamilyRole.stepMother => 'My stepmother, ${parent.fullName},',
        };

        expect(economyDescription, contains(roleLabel));
      }
    }

    expect(familyEvent.description, isNot(contains('Alfan')));
    expect(economyDescription, isNot(contains('Alfan')));
  });

  test('age-up advances each living parent financial balance', () {
    final engine = createEngine();
    final before = engine.state.familyHousehold!.parents;

    expect(engine.ageUp().isSuccess, isTrue);
    expect(engine.state.clock.currentYear, 2027);

    final after = engine.state.familyHousehold!.parents;
    expect(after.length, before.length);

    for (var i = 0; i < before.length; i++) {
      if (before[i].isAlive) {
        final expectedBalance =
            before[i].cashBalance.minorUnits +
                before[i].annualIncome.minorUnits -
                before[i].annualExpenses.minorUnits;

        expect(
          after[i].cashBalance.minorUnits,
          expectedBalance >= 0 ? expectedBalance : 0,
        );
      }
    }
  });
}
