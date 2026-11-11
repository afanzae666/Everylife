/// How a partner takes bad news. It follows from the person's id, so it
/// never changes between visits.
enum Temperament {
  /// Shouts, throws things, makes a scene.
  hothead,

  /// Goes quiet, cold and calm.
  steady,

  /// Cries, hurts deeply, and is easier to win back.
  tender;

  static Temperament of(String id) {
    var hash = 7;

    for (final unit in 'temperament|$id'.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }

    return Temperament.values[hash % Temperament.values.length];
  }
}

/// Rules for how likely a partner is to find out about an affair.
abstract final class CheatingRules {
  /// The chance for a careful, one-off affair with a stranger.
  static const int base = 20;

  /// The lowest and highest chance an affair can have.
  static const int floor = 5;
  static const int ceiling = 75;

  /// Percent chance of being found out.
  ///
  /// * [sharedCircle]: my partner and my lover know the same people.
  /// * [timesWithLover]: how often I already did this with the same person
  ///   this year.
  /// * [otherAffairs]: how many other people I cheated with this year.
  /// * [partnerSmarts]: how sharp my partner is (35 to 90).
  static int chance({
    required bool sharedCircle,
    required int timesWithLover,
    required int otherAffairs,
    required int partnerSmarts,
    required Temperament partner,
  }) {
    var value = base;

    if (sharedCircle) value += 12;

    value += (timesWithLover * 8).clamp(0, 16).toInt();
    value += (otherAffairs * 4).clamp(0, 12).toInt();
    value += (partnerSmarts - 50) ~/ 5;
    value += switch (partner) {
      Temperament.hothead => 3,
      Temperament.steady => 0,
      Temperament.tender => -5,
    };

    return value.clamp(floor, ceiling).toInt();
  }
}
