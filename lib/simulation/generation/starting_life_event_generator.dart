import '../../core/random/seeded_random.dart';
import '../../domain/character/starting_background.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';

class StartingLifeEventGenerator {
  const StartingLifeEventGenerator._();

  static SimulationEvent generate({
    required SeededRandom random,
    required int year,
    required StartingBackground background,
    FamilyHousehold? household,
  }) {
    final familyNarrative = _familyNarrative(household);
    final economicNarrative = _economicNarrative(household);
    final description = household == null
        ? '${background.label}. Your family situation has not been recorded.'
        : '$familyNarrative $economicNarrative';

    return SimulationEvent(
      id: 'starting-life-event-$year',
      type: SimulationEventType.startingLifeEvent,
      year: year,
      title: 'Your Family Background',
      description: description.trim(),
    );
  }

  static String _familyNarrative(FamilyHousehold? household) {
    if (household == null || household.parents.isEmpty) {
      return 'Your family situation has not been recorded.';
    }

    final parents = household.parents;
    final guardian = parents.any((parent) => parent.role == FamilyRole.guardian);
    if (guardian) {
      return 'Your biological parents entrusted you to an orphanage, where a guardian or caregiver looks after you.';
    }

    final mother = _findRole(parents, FamilyRole.mother);
    final father = _findRole(parents, FamilyRole.father);
    if (mother != null && !mother.isAlive && father != null && father.isAlive) {
      return 'Your mother died while giving birth to you. Your father raises you without her presence from the beginning of your life.';
    }

    if (mother != null && father == null) {
      return 'Your mother raises you on her own from birth. Your biological father is not part of your life.';
    }

    if (mother != null && father != null) {
      return 'You were born into a family with both of your biological parents. They try to provide the best life they can for you.';
    }

    return 'Your family situation is recorded in your family details.';
  }

  static String _economicNarrative(FamilyHousehold? household) {
    if (household == null || household.parents.isEmpty) return '';

    final descriptions = <String>[];
    for (final parent in household.parents) {
      // A deceased parent's employment is historical context and is omitted
      // until a trustworthy employment-history field exists.
      if (!parent.isAlive || parent.role == FamilyRole.guardian) continue;
      final description = _employmentDescription(parent);
      if (description != null) descriptions.add(description);
    }

    if (descriptions.isEmpty) return '';
    return descriptions.join(' ');
  }

  static String? _employmentDescription(ParentNpc parent) {
    final occupation = parent.occupation?.trim();
    switch (parent.employmentStatus) {
      case EmploymentStatus.employed:
        if (occupation == null || occupation.isEmpty) {
          return 'Your ${_roleLabel(parent.role)} works as an employee.';
        }
        return 'Your ${_roleLabel(parent.role)} works as a $occupation.';
      case EmploymentStatus.selfEmployed:
        if (occupation == null || occupation.isEmpty) {
          return 'Your ${_roleLabel(parent.role)} is self-employed.';
        }
        return 'Your ${_roleLabel(parent.role)} is self-employed as a $occupation.';
      case EmploymentStatus.unemployed:
        return 'Your ${_roleLabel(parent.role)} is currently unemployed.';
      case EmploymentStatus.retired:
        return 'Your ${_roleLabel(parent.role)} is retired.';
      case EmploymentStatus.homemaker:
        return 'Your ${_roleLabel(parent.role)} takes care of the household.';
      case EmploymentStatus.unableToWork:
        return 'Your ${_roleLabel(parent.role)} is unable to work.';
    }
  }

  static String _roleLabel(FamilyRole role) => switch (role) {
        FamilyRole.father => 'father',
        FamilyRole.mother => 'mother',
        FamilyRole.guardian => 'guardian',
        FamilyRole.stepFather => 'stepfather',
        FamilyRole.stepMother => 'stepmother',
      };

  static ParentNpc? _findRole(List<ParentNpc> parents, FamilyRole role) {
    for (final parent in parents) {
      if (parent.role == role) return parent;
    }
    return null;
  }
}
