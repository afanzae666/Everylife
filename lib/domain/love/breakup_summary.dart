/// What kind of ending a [BreakupSummary] describes.
enum BreakupKind {
  /// Dating ended.
  breakup,

  /// An engagement was called off.
  engagement,

  /// A marriage ended.
  divorce,
}

/// Everything the end-of-relationship overlay shows. The engine builds it
/// whenever a relationship ends, whatever the reason, and the game screen
/// shows it once.
class BreakupSummary {
  const BreakupSummary({
    required this.npcId,
    required this.name,
    required this.kind,
    required this.title,
    required this.story,
    required this.quip,
    required this.facts,
  });

  final String npcId;
  final String name;
  final BreakupKind kind;

  /// Headline of the overlay, for example "Divorced" or "Heartbreak".
  final String title;

  /// The scene itself: who ended it and why.
  final String story;

  /// A short, light closing line.
  final String quip;

  /// Interesting numbers and consequences (label, value), in reading order.
  final List<MapEntry<String, String>> facts;
}
