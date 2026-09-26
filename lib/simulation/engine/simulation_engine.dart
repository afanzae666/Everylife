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
import '../systems/character_system.dart';
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
        _saveRepository = saveRepository,
        _saveManager = saveRepository is SaveManager
            ? saveRepository
            : SaveManager(
                repository: saveRepository,
              ),
        _scheduler = SimulationScheduler(
          systems: [
            TimeSystem(),
            CharacterSystem(),
          ],
        ),
        _validator = const WorldStateValidator(),
        _nextTickId = nextTickId;

  WorldState _state;

  final SeededRandom _random;
  final SaveRepository _saveRepository;
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
    final validation =
        _validator.validate(_state);

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
    final validation =
        _validator.validate(nextState);

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
      toYear:
          _state.clock.currentYear + 1,
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
      await _saveManager.save(
        _state,
        randomState: _random.state,
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
      final data =
          await _saveManager.loadSlot(
        slot,
      );

      if (data == null) {
        return const Failure(
          'No save data exists in this slot.',
        );
      }

      final validation =
          _validator.validate(
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

      _state = data.state;
      _random.restoreState(
        data.randomState,
      );
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

  static SimulationEngine create({
    required Character player,
    required int seed,
    required SaveRepository saveRepository,
  }) {
    final initialState = WorldState(
      clock: SimulationClock(
        currentYear: player.birthYear,
      ),
      player: player,
      events: [
        SimulationEvent(
          id: 'life-created',
          type:
              SimulationEventType.lifeCreated,
          year: player.birthYear,
          title: 'A new life begins',
          description:
              '${player.name} was born in ${player.birthYear}.',
        ),
      ],
    );

    return SimulationEngine(
      initialState: initialState,
      random: SeededRandom(seed),
      saveRepository: saveRepository,
    );
  }
}
