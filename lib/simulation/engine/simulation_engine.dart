
import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';
import '../../data/services/save_manager.dart';
import '../../domain/character/character.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/time/simulation_clock.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../generation/family_household_generator.dart';
import '../generation/starting_background_generator.dart';
import '../generation/starting_life_event_generator.dart';
import '../systems/character_system.dart';
import '../systems/household_economy_system.dart';
import '../systems/simulation_system.dart';
import '../systems/time_system.dart';
import 'simulation_scheduler.dart';
import 'simulation_tick.dart';
import 'world_state_validator.dart';

class SimulationEngine {
  SimulationEngine({
    required WorldState initialState,
    required SeededRandom random,
    required SaveRepository saveRepository,
    int nextTickId = 1,
  })  : _state = initialState,
        _random = random,
        _saveManager = saveRepository is SaveManager
            ? saveRepository
            : SaveManager(
                repository: saveRepository,
              ),
        _scheduler = SimulationScheduler(
          systems: [
            TimeSystem(),
            HouseholdEconomySystem(),
            CharacterSystem(),
          ],
        ),
        _validator = const WorldStateValidator(),
        _nextTickId = nextTickId {
    if (nextTickId < 1) {
      throw ArgumentError.value(
        nextTickId,
        'nextTickId',
        'Must be greater than zero.',
      );
    }
  }

  WorldState _state;

  final SeededRandom _random;
  final SaveManager _saveManager;
  final SimulationScheduler _scheduler;
  final WorldStateValidator _validator;

  int _nextTickId;

  WorldState get state => _state;

  SeededRandom get random => _random;

  List<SimulationSystem> get systems => _scheduler.systems;

  int get nextTickId => _nextTickId;

  void registerSystem(
    SimulationSystem system,
  ) {
    _scheduler.registerSystem(system);
  }

  Result<void> execute(
    SimulationCommand<dynamic> command,
  ) {
    final validation = _validator.validate(_state);

    if (validation
        case Failure<void>(
          :final message,
        )) {
      return Failure(message);
    }

    final result = _scheduler.execute(
      state: _state,
      command: command,
    );

    return switch (result) {
      Success<WorldState>(
        :final value,
      ) =>
        _commit(value),
      Failure<WorldState>(
        :final message,
      ) =>
        Failure(message),
    };
  }

  Result<void> _commit(
    WorldState nextState,
  ) {
    final validation = _validator.validate(nextState);

    if (validation
        case Failure<void>(
          :final message,
        )) {
      return Failure(message);
    }

    _state = nextState;

    return const Success(null);
  }

  Result<void> ageUp() {
    final tick = SimulationTick(
      id: _nextTickId,
      fromYear: _state.clock.currentYear,
      toYear: _state.clock.currentYear + 1,
    );

    if (!tick.isValid) {
      return const Failure(
        'Unable to create a valid simulation tick.',
      );
    }

    final result = execute(
      const AgeUpCommand(),
    );

    if (result case Success<void>()) {
      _nextTickId++;
    }

    return result;
  }

  Future<Result<void>> save() {
    return saveToSlot(
      SaveSlot.autosave,
    );
  }

  Future<Result<void>> saveToSlot(
    SaveSlot slot,
  ) async {
    try {
      final validation = _validator.validate(_state);

      if (validation
          case Failure<void>(
            :final message,
          )) {
        return Failure(
          'Save failed: invalid world state: $message',
        );
      }

      if (_nextTickId < 1) {
        return const Failure(
          'Save failed: next tick ID must be greater than zero.',
        );
      }

      final randomState = _random.state;

      if (randomState < 0 || randomState > 0x7fffffff) {
        return const Failure(
          'Save failed: random state is outside the valid range.',
        );
      }

      await _saveManager.save(
        _state,
        randomState: randomState,
        nextTickId: _nextTickId,
        slot: slot,
      );

      return const Success(null);
    } catch (error) {
      return Failure(
        'Save failed: $error',
      );
    }
  }

  Future<Result<void>> saveManual(
    SaveSlot slot,
  ) async {
    if (slot == SaveSlot.autosave) {
      return const Failure(
        'Manual save cannot use the autosave slot.',
      );
    }

    return saveToSlot(slot);
  }

  Future<Result<void>> load() {
    return loadFromSlot(
      SaveSlot.autosave,
    );
  }

  Future<Result<void>> loadFromSlot(
    SaveSlot slot,
  ) async {
    try {
      final data = await _saveManager.loadSlot(
        slot,
      );

      if (data == null) {
        return const Failure(
          'No save data exists in this slot.',
        );
      }

      final validation = _validator.validate(
        data.state,
      );

      if (validation
          case Failure<void>(
            :final message,
          )) {
        return Failure(
          'Loaded save is invalid: $message',
        );
      }

      if (data.randomState < 0 ||
          data.randomState > 0x7fffffff) {
        return const Failure(
          'Loaded save is invalid: random state is outside '
          'the valid range.',
        );
      }

      if (data.nextTickId < 1) {
        return const Failure(
          'Loaded save is invalid: next tick ID must be '
          'greater than zero.',
        );
      }

      // Restore the random generator only after all loaded data
      // has passed validation. The remaining assignments cannot
      // fail under normal Dart execution.
      _random.restoreState(
        data.randomState,
      );

      _state = data.state;
      _nextTickId = data.nextTickId;

      return const Success(null);
    } catch (error) {
      return Failure(
        'Load failed: $error',
      );
    }
  }

  Future<Result<void>> deleteSave(
    SaveSlot slot,
  ) async {
    try {
      await _saveManager.deleteSlot(
        slot,
      );

      return const Success(null);
    } catch (error) {
      return Failure(
        'Delete failed: $error',
      );
    }
  }

  Future<bool> hasSave(
    SaveSlot slot,
  ) {
    return _saveManager.hasSave(
      slot,
    );
  }

  Future<SaveData?> readSaveSlot(
    SaveSlot slot,
  ) {
    return _saveManager.loadSlot(
      slot,
    );
  }

  static SimulationEngine create({
    required Character player,
    required int seed,
    required SaveRepository saveRepository,
  }) {
    final random = SeededRandom(seed);

    final startingBackground =
        StartingBackgroundGenerator.generate(random);

    final familyHousehold = FamilyHouseholdGenerator.generate(
      random: random,
      birthYear: player.birthYear,
      background: startingBackground,
      familyName: player.resolvedLastName,
      countryCode: player.location?.countryCode ?? 'ID',
    );

    final startingLifeEvent = StartingLifeEventGenerator.generate(
      random: random,
      year: player.birthYear,
      background: startingBackground,
      household: familyHousehold,
    );

    final initialState = WorldState(
      clock: SimulationClock(
        currentYear: player.birthYear,
      ),
      player: player,
      events: [
        SimulationEvent(
          id: 'life-created',
          type: SimulationEventType.lifeCreated,
          year: player.birthYear,
          title: 'A new life begins',
          description:
              '${player.name} was born in ${player.birthYear}.',
        ),
        startingLifeEvent,
      ],
      startingBackground: startingBackground,
      familyHousehold: familyHousehold,
    );

    return SimulationEngine(
      initialState: initialState,
      random: random,
      saveRepository: saveRepository,
    );
  }
}
