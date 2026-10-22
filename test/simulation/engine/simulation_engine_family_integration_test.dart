import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/event/simulation_event.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';

void main() {
  Character createPlayer() {
    return Character.create(
      id: 'player-family-test',
      firstName: 'Alfan',
      lastName: 'Zaenal',
      birthYear: 2026,
    );
  }

  SimulationEngine createEngine({
    required SaveRepository repository,
    int seed = 12345,
  }) {
    return SimulationEngine.create(
      player: createPlayer(),
      seed: seed,
      saveRepository: repository,
    );
  }

  group('SimulationEngine family integration', () {
    test('generates a household when a new life is created', () {
      final engine = createEngine(
        repository: InMemorySaveRepository(),
      );

      final household = engine.state.familyHousehold;

      expect(household, isNotNull);
      expect(household!.id, 'family-household-2026');
      expect(household.parents, isNotEmpty);
      expect(engine.state.startingBackground, isNotNull);
    });

    test('uses the player family name for generated parents', () {
      final engine = createEngine(
        repository: InMemorySaveRepository(),
      );

      final household = engine.state.familyHousehold!;

      for (final parent in household.parents) {
        expect(parent.lastName, 'Zaenal');
      }
    });

    test('starting life event reflects generated household details', () {
      final engine = createEngine(
        repository: InMemorySaveRepository(),
      );

      final household = engine.state.familyHousehold!;
      final event = engine.state.events.firstWhere(
        (event) =>
            event.type == SimulationEventType.startingLifeEvent,
      );

      expect(event.year, 2026);
      expect(event.title, isNotEmpty);
      expect(event.description, isNotEmpty);

      for (final parent in household.parents) {
        expect(
          event.description,
          contains(parent.fullName),
        );
      }

      expect(
        event.description,
        contains(engine.state.startingBackground!.label),
      );
    });

    test('keeps household data when the player ages up', () {
      final engine = createEngine(
        repository: InMemorySaveRepository(),
      );

      final originalHousehold = engine.state.familyHousehold!;
      final result = engine.ageUp();

      expect(result.isSuccess, isTrue);
      expect(engine.state.clock.currentYear, 2027);
      expect(engine.state.familyHousehold, same(originalHousehold));
      expect(
        engine.state.familyHousehold!.parents,
        hasLength(originalHousehold.parents.length),
      );
      expect(
        engine.state.familyHousehold!.assets,
        hasLength(originalHousehold.assets.length),
      );
    });

    test('preserves household data through engine save and load', () async {
      final repository = InMemorySaveRepository();
      final firstEngine = createEngine(
        repository: repository,
        seed: 12345,
      );

      final originalHousehold = firstEngine.state.familyHousehold!;
      final saveResult = await firstEngine.save();

      expect(saveResult.isSuccess, isTrue);

      final secondEngine = createEngine(
        repository: repository,
        seed: 98765,
      );

      final loadResult = await secondEngine.load();

      expect(loadResult.isSuccess, isTrue);

      final restoredHousehold = secondEngine.state.familyHousehold;

      expect(restoredHousehold, isNotNull);
      expect(restoredHousehold!.id, originalHousehold.id);
      expect(
        restoredHousehold.housingStatus,
        originalHousehold.housingStatus,
      );
      expect(
        restoredHousehold.cashSavings,
        originalHousehold.cashSavings,
      );
      expect(
        restoredHousehold.annualLivingCosts,
        originalHousehold.annualLivingCosts,
      );
      expect(
        restoredHousehold.totalDebt,
        originalHousehold.totalDebt,
      );
      expect(
        restoredHousehold.parents.length,
        originalHousehold.parents.length,
      );
      expect(
        restoredHousehold.assets.length,
        originalHousehold.assets.length,
      );
      expect(
        secondEngine.state.startingBackground!.tier,
        firstEngine.state.startingBackground!.tier,
      );
    });

    test('generates the same household for the same seed', () {
      final firstEngine = createEngine(
        repository: InMemorySaveRepository(),
        seed: 555,
      );

      final secondEngine = createEngine(
        repository: InMemorySaveRepository(),
        seed: 555,
      );

      final firstHousehold = firstEngine.state.familyHousehold!;
      final secondHousehold = secondEngine.state.familyHousehold!;

      expect(secondHousehold.id, firstHousehold.id);
      expect(
        secondHousehold.housingStatus,
        firstHousehold.housingStatus,
      );
      expect(
        secondHousehold.cashSavings,
        firstHousehold.cashSavings,
      );
      expect(
        secondHousehold.annualLivingCosts,
        firstHousehold.annualLivingCosts,
      );
      expect(
        secondHousehold.totalDebt,
        firstHousehold.totalDebt,
      );
      expect(
        secondHousehold.parents.length,
        firstHousehold.parents.length,
      );
      expect(
        secondHousehold.assets.length,
        firstHousehold.assets.length,
      );

      for (var index = 0;
          index < firstHousehold.parents.length;
          index++) {
        final firstParent = firstHousehold.parents[index];
        final secondParent = secondHousehold.parents[index];

        expect(secondParent.id, firstParent.id);
        expect(secondParent.fullName, firstParent.fullName);
        expect(
          secondParent.employmentStatus,
          firstParent.employmentStatus,
        );
        expect(
          secondParent.annualIncome,
          firstParent.annualIncome,
        );
      }
    });
  });
}
