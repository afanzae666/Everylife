
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/engine/world_state_validator.dart';

void main() {
  group('Generated household validation integration', () {
    test(
      'generated world states remain valid across many seeds',
      () {
        const validator = WorldStateValidator();

        for (var seed = 0; seed < 300; seed++) {
          final engine = SimulationEngine.create(
            player: Character.create(
              id: 'validation-player-$seed',
              firstName: 'Alex',
              lastName: 'Morgan',
              birthYear: 2026,
            ),
            seed: seed,
            saveRepository: InMemorySaveRepository(),
          );

          final state = engine.state;
          final household = state.familyHousehold;

          expect(
            household,
            isNotNull,
            reason: 'Seed $seed should generate a family household.',
          );

          final result = validator.validate(state);

          expect(
            result.isSuccess,
            isTrue,
            reason: 'Seed $seed generated an invalid world state: '
                'background=${state.startingBackground?.tier.name}, '
                'housing=${household!.housingStatus.name}, '
                'parents=${household.parents.length}, '
                'assets=${household.assets.length}.',
          );
        }
      },
    );
  });
}
