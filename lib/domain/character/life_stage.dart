enum LifeStage {
  infant,
  toddler,
  child,
  teen,
  youngAdult,
  adult,
  senior,
}

extension LifeStageAge on LifeStage {
  static LifeStage fromAge(int age) {
    if (age < 0) {
      throw ArgumentError.value(
        age,
        'age',
        'Age cannot be negative.',
      );
    }

    if (age <= 2) {
      return LifeStage.infant;
    }

    if (age <= 5) {
      return LifeStage.toddler;
    }

    if (age <= 12) {
      return LifeStage.child;
    }

    if (age <= 17) {
      return LifeStage.teen;
    }

    if (age <= 29) {
      return LifeStage.youngAdult;
    }

    if (age <= 59) {
      return LifeStage.adult;
    }

    return LifeStage.senior;
  }
}
