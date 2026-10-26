
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/cultural_name_catalog.dart';
import 'package:everylife/domain/event/simulation_event.dart';
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
    expect(birthEvent.description, contains('Alfan Zaenal was born in 2026.'));
    expect(
      birthEvent.description.length,
      greaterThan('Alfan Zaenal was born in 2026.'.length),
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
