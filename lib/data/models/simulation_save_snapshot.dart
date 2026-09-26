import 'world_state_snapshot.dart';

class SimulationSaveSnapshot {
  const SimulationSaveSnapshot({
    required this.world,
    required this.randomState,
    required this.nextTickId,
    this.savedAt,
  });

  static const int currentSchemaVersion = 1;

  final WorldStateSnapshot world;
  final int randomState;
  final int nextTickId;
  final DateTime? savedAt;

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': currentSchemaVersion,
      'engine': {
        'randomState': randomState,
        'nextTickId': nextTickId,
      },
      'world': world.toJson(),
      if (savedAt != null)
        'savedAt': savedAt!.toUtc().toIso8601String(),
    };
  }

  factory SimulationSaveSnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final schemaVersion = _requireInt(
      json['schemaVersion'],
      'schemaVersion',
    );

    if (schemaVersion != currentSchemaVersion) {
      throw FormatException(
        'Unsupported save schema version: $schemaVersion',
      );
    }

    final engine = _requireMap(
      json['engine'],
      'engine',
    );

    final world = _requireMap(
      json['world'],
      'world',
    );

    final randomState = _requireInt(
      engine['randomState'],
      'engine.randomState',
    );

    final nextTickId = _requireInt(
      engine['nextTickId'],
      'engine.nextTickId',
    );

    final savedAt = _parseSavedAt(
      json['savedAt'],
    );

    if (nextTickId < 1) {
      throw const FormatException(
        'Field "engine.nextTickId" must be greater than zero.',
      );
    }

    return SimulationSaveSnapshot(
      world: WorldStateSnapshot.fromJson(world),
      randomState: _validateRandomState(randomState),
      nextTickId: nextTickId,
      savedAt: savedAt,
    );
  }

  static Map<String, dynamic> _requireMap(
    Object? value,
    String field,
  ) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw FormatException(
      'Field "$field" must be an object.',
    );
  }

  static int _requireInt(
    Object? value,
    String field,
  ) {
    if (value is int) {
      return value;
    }

    throw FormatException(
      'Field "$field" must be an integer.',
    );
  }

  static DateTime? _parseSavedAt(
    Object? value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is! String) {
      throw const FormatException(
        'Field "savedAt" must be an ISO-8601 string.',
      );
    }

    try {
      return DateTime.parse(value).toUtc();
    } on FormatException {
      throw const FormatException(
        'Field "savedAt" must be a valid ISO-8601 date.',
      );
    }
  }

  static int _validateRandomState(
    int state,
  ) {
    if (state < 0 || state > 0x7fffffff) {
      throw FormatException(
        'Field "engine.randomState" is outside the valid range.',
      );
    }

    return state;
  }
}
