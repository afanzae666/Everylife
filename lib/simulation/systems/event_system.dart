import '../../core/random/seeded_random.dart';
import '../../domain/event/life_event.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../events/life_effect_applier.dart';
import '../events/life_event_catalog.dart';
import 'simulation_system.dart';
import 'system_priority.dart';

/// Draws at most one life event per year.
///
/// Events with choices become a pending decision that blocks aging up until
/// the player resolves it. Events without choices apply immediately.
class EventSystem implements SimulationSystem {
  EventSystem({
    required SeededRandom random,
    this.eventChancePercent = 70,
  }) : _random = random;

  final SeededRandom _random;

  /// Chance (0-100) that a year brings an event at all.
  final int eventChancePercent;

  @override
  String get id => 'events';

  @override
  int get priority => SystemPriority.event.value;

  @override
  WorldState process({
    required WorldState state,
    required SimulationCommand<dynamic> command,
  }) {
    if (command is! AgeUpCommand) {
      return state;
    }

    if (state.lifeProgress.ending != null ||
        state.lifeProgress.pending != null) {
      return state;
    }

    // Always consume the yearly roll so the random stream stays stable.
    final roll = _random.nextInt(100);

    if (roll >= eventChancePercent) {
      return state;
    }

    final year = state.clock.currentYear;
    final age = state.player.ageAt(year);
    final candidates = LifeEventCatalog.eligible(state: state, age: age);

    if (candidates.isEmpty) {
      return state;
    }

    final definition = LifeEffectApplier.pickWeighted<LifeEventDefinition>(
      candidates,
      (candidate) => candidate.weight,
      _random,
    );

    final seenState = state.copyWith(
      lifeProgress: state.lifeProgress.copyWith(
        lastSeenYear: {
          ...state.lifeProgress.lastSeenYear,
          definition.id: year,
        },
      ),
    );

    if (definition.choices.isNotEmpty) {
      return seenState.copyWith(
        lifeProgress: seenState.lifeProgress.copyWith(
          pending: PendingLifeEvent(eventId: definition.id, year: year),
        ),
      );
    }

    if (definition.autoOutcomes.isEmpty) {
      return seenState;
    }

    final outcome = LifeEffectApplier.pickOutcome(
      definition.autoOutcomes,
      _random,
    );

    return LifeEffectApplier.applyOutcome(
      state: seenState,
      outcome: outcome,
    ).addEvent(
      SimulationEvent(
        id: 'life-event-$year-${definition.id}',
        type: SimulationEventType.lifeEvent,
        year: year,
        title: definition.title,
        description: '${definition.description} ${outcome.text}',
      ),
    );
  }
}
