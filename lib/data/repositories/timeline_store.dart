import '../../domain/world/world_state.dart';
import 'save_repository.dart';

/// One remembered age of a life: where the Time Machine can travel back to.
class TimelineEntry {
  const TimelineEntry({
    required this.age,
    required this.state,
    required this.randomState,
    required this.nextTickId,
  });

  final int age;
  final WorldState state;
  final int randomState;
  final int nextTickId;
}

/// Optional capability of a save repository: keeping the Time Machine
/// timeline of a life next to its save slot.
abstract interface class TimelineStore {
  Future<void> saveTimeline(
    List<TimelineEntry> entries, {
    required SaveSlot slot,
  });

  Future<List<TimelineEntry>> loadTimeline({
    required SaveSlot slot,
  });

  Future<void> deleteTimeline({
    required SaveSlot slot,
  });
}
