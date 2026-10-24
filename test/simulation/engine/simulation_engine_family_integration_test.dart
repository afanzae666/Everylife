import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/cultural_name_catalog.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  Character createPlayer() => Character.create(
    id: 'player-family-test', firstName: 'Alfan', lastName: 'Zaenal',
    birthYear: 2026,
  );

  SimulationEngine createEngine({int seed = 12345}) => SimulationEngine.create(
    player: createPlayer(), seed: seed,
    saveRepository: InMemorySaveRepository(),
  );

  test('generates individual parent financial records for a new life', () {
    final engine = createEngine();
    final parents = engine.state.familyHousehold!.parents;
    expect(parents, isNotEmpty);
    for (final parent in parents) {
      expect(parent.lastName, 'Zaenal');
      expect(parent.countryCode, 'ID');
      expect(parent.cashBalance.minorUnits, greaterThanOrEqualTo(0));
      expect(parent.annualExpenses.minorUnits, greaterThanOrEqualTo(0));
      expect(parent.assets, isNotNull);
    }
    expect(engine.state.familyHousehold!.cashSavings.minorUnits, 0);
  });

  test('starting life event reflects culturally formatted parent names', () {
    final engine = createEngine();
    final household = engine.state.familyHousehold!;
    final event = engine.state.events.firstWhere(
      (event) => event.type == SimulationEventType.startingLifeEvent,
    );
    expect(event.year, 2026);
    expect(event.description, isNotEmpty);
    for (final parent in household.parents) {
      expect(parent.fullName, CulturalNameCatalog.formatFullName(
        parent.countryCode, parent.firstName, parent.lastName,
      ));
      expect(event.description, contains(parent.fullName));
    }
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
        expect(after[i].cashBalance.minorUnits,
            before[i].cashBalance.minorUnits + before[i].annualIncome.minorUnits - before[i].annualExpenses.minorUnits >= 0
                ? before[i].cashBalance.minorUnits + before[i].annualIncome.minorUnits - before[i].annualExpenses.minorUnits
                : 0);
      }
    }
  });
}
