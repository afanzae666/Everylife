
enum StartingBackgroundTier {
  struggling,
  workingClass,
  middleClass,
  upperMiddleClass,
  wealthy,
  veryWealthy,
}

class StartingBackground {
  const StartingBackground({
    required this.tier,
  });

  final StartingBackgroundTier tier;

  String get label {
    switch (tier) {
      case StartingBackgroundTier.struggling:
        return 'Struggling';
      case StartingBackgroundTier.workingClass:
        return 'Working Class';
      case StartingBackgroundTier.middleClass:
        return 'Middle Class';
      case StartingBackgroundTier.upperMiddleClass:
        return 'Upper Middle Class';
      case StartingBackgroundTier.wealthy:
        return 'Wealthy';
      case StartingBackgroundTier.veryWealthy:
        return 'Very Wealthy';
    }
  }
}
