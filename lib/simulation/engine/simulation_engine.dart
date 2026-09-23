import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';
import '../../domain/character/character.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/time/simulation_clock.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../systems/simulation_system.dart';
import 'simulation_scheduler.dart';

class SimulationEngine {
  SimulationEngine({
    required WorldState initialState,
    required SeededRandom random,
    required SaveRepository saveRepository,
  })  : _state = initialState,
        _random = random,
        _saveRepository = saveRepository,
        _scheduler = SimulationScheduler();

  WorldState _state;

  final SeededRandom _random;
  final SaveRepository _saveRepository;
  final SimulationScheduler _scheduler;

  WorldState get state => _state;

  SeededRandom get random => _random;

  List<SimulationSystem> get systems => _scheduler.systems;

  void registerSystem(SimulationSystem system) {
    _scheduler.registerSystem(system);
  }

  Result<void> execute(
    SimulationCommand<dynamic> command,
  ) {
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
    _state = nextState;
    return const Success(null);
  }

  Result<void> ageUp() {
    return execute(
      const AgeUpCommand(),
    );
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
