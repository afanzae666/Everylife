import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';
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
  })  : _state = initialState,
        _random = random,
        _saveRepository = saveRepository,
        _scheduler = SimulationScheduler(
          systems: [
            TimeSystem(),
            CharacterSystem(),
          ],
        ),
        _validator = const WorldStateValidator();

  WorldState _state;

  final SeededRandom _random;
  final SaveRepository _saveRepository;
  final SimulationScheduler _scheduler;
  final WorldStateValidator _validator;

  int _nextTickId = 1;

  WorldState get state => _state;

  SeededRandom get random => _random;

  List<SimulationSystem> get systems => _scheduler.systems;

  int get nextTickId => _nextTickId;

  void registerSystem(SimulationSystem system) {
    _scheduler.registerSystem(system);
  }

  Result<void> execute(
    SimulationCommand<dynamic> command,
  ) {
    final validation = _validator.validate(_state);

    if (validation case Failure<void>(:final message)) {
      return Failure(message);
    }

    final result = _scheduler.execute(
      state: _state,
      command: command,
    );

    return switch (result) {
      Success<WorldState>(:final value) => _commit(value),
      Failure<WorldState>(:final message) => Failure(message),
    };
  }

  Result<void> _commit(WorldState nextState) {
    final validation = _validator.validate(nextState);

    if (validation case Failure<void>(:final message)) {
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

  Future<Result<void>> save() async {
    try {
      await _saveRepository.save(_state);

      return const Success(null);
    } catch (error) {
      return Failure(
        'Save failed: $error',
      );
    }
  }

  Future<Result<void>> load() async {
    try {
      final loaded = await _saveRepository.load();

      if (loaded == null) {
        return const Failure(
          'No save data exists.',
        );
      }

      final validation = _validator.validate(loaded);

      if (validation case Failure<void>(:final message)) {
        return Failure(
          'Loaded save is invalid: $message',
        );
      }

      _state = loaded;

      return const Success(null);
    } catch (error) {
      return Failure(
        'Load failed: $error',
      );
    }
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
          type: SimulationEventType.lifeCreated,
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
