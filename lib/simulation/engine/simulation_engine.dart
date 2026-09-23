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

class SimulationEngine {
  SimulationEngine({
    required WorldState initialState,
    required SeededRandom random,
    required SaveRepository saveRepository,
  })  : _state = initialState,
        _random = random,
        _saveRepository = saveRepository;

  WorldState _state;
  final SeededRandom _random;
  final SaveRepository _saveRepository;

  final List<SimulationSystem> _systems = [];

  WorldState get state => _state;

  SeededRandom get random => _random;

  void registerSystem(SimulationSystem system) {
    if (_systems.any((existing) => existing.id == system.id)) {
      throw StateError(
        'Simulation system already registered: ${system.id}',
      );
    }

    _systems.add(system);

    _systems.sort(
      (a, b) => a.priority.compareTo(b.priority),
    );
  }

  Result<void> execute(
    SimulationCommand<dynamic> command,
  ) {
    try {
      var nextState = _state;

      for (final system in _systems) {
        nextState = system.process(
          state: nextState,
          command: command,
        );
      }

      _state = nextState;

      return const Success(null);
    } catch (error) {
      return Failure(
        'Simulation command failed: $error',
      );
    }
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
