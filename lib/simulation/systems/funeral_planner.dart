import '../../domain/event/life_progress.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/world/world_state.dart';
import '../events/scripted_events.dart';

/// Starts the funeral decision when a parent dies.
///
/// Adults arrange the funeral themselves and choose how to say goodbye (and
/// how much to spend). Children watch the grown-ups arrange it. Babies are
/// too young to remember it, so nothing is shown for them.
abstract final class FuneralPlanner {
  static const int youngestAge = 6;

  static String roleName(FamilyRole role) => switch (role) {
        FamilyRole.father => 'father',
        FamilyRole.mother => 'mother',
        FamilyRole.guardian => 'guardian',
        FamilyRole.stepFather => 'stepfather',
        FamilyRole.stepMother => 'stepmother',
      };

  static String subjectFor(ParentNpc parent) =>
      'my ${roleName(parent.role)}, ${parent.fullName}';

  /// Returns [state] with a pending funeral for the parents that just died.
  static WorldState schedule(WorldState state, List<ParentNpc> died) {
    if (died.isEmpty || state.lifeProgress.ending != null) {
      return state;
    }

    final age = state.player.ageAt(state.clock.currentYear);

    if (age < youngestAge) {
      return state;
    }

    final names = died.map(subjectFor).join(' and ');
    final existing = state.lifeProgress.pending;

    // Two parents lost in the same year share one decision.
    if (existing != null) {
      final isFuneral = existing.eventId == ScriptedEvents.funeral ||
          existing.eventId == ScriptedEvents.funeralFamily;

      if (!isFuneral) return state;

      return state.copyWith(
        lifeProgress: state.lifeProgress.copyWith(
          pending: PendingLifeEvent(
            eventId: existing.eventId,
            year: existing.year,
            subject: '${existing.subject ?? ''} and $names'.trim(),
            subjectNpcId: existing.subjectNpcId ?? died.first.id,
          ),
        ),
      );
    }

    return state.copyWith(
      lifeProgress: state.lifeProgress.copyWith(
        pending: PendingLifeEvent(
          eventId:
              age >= 18 ? ScriptedEvents.funeral : ScriptedEvents.funeralFamily,
          year: state.clock.currentYear,
          subject: names,
          subjectNpcId: died.first.id,
        ),
      ),
    );
  }
}
