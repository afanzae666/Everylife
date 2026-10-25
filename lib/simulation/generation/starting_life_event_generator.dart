
import '../../core/random/seeded_random.dart';
import '../../domain/character/starting_background.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';

class StartingLifeEventGenerator {
  const StartingLifeEventGenerator._();

  static List<SimulationEvent> generate({
    required SeededRandom random,
    required int year,
    required StartingBackground background,
    FamilyHousehold? household,
  }) {
    return [
      SimulationEvent(
        id: 'starting-life-event-$year-family',
        type: SimulationEventType.startingLifeEvent,
        year: year,
        title: 'Starting Family',
        description: _familyNarrative(household, background),
      ),
      SimulationEvent(
        id: 'starting-life-event-$year-economy',
        type: SimulationEventType.startingLifeEvent,
        year: year,
        title: 'Starting Economy',
        description: _economicNarrative(household),
      ),
    ];
  }

  static String _familyNarrative(
    FamilyHousehold? household,
    StartingBackground background,
  ) {
    if (household == null || household.parents.isEmpty) {
      return '${background.label}. Your family situation has not been recorded.';
    }

    final parents = household.parents;
    final guardian = parents.any(
      (parent) => parent.role == FamilyRole.guardian,
    );

    if (guardian) {
      return 'Your biological parents entrusted you to an orphanage, '
          'where a guardian or caregiver looks after you.';
    }

    final mother = _findRole(parents, FamilyRole.mother);
    final father = _findRole(parents, FamilyRole.father);

    if (mother != null && !mother.isAlive && father != null && father.isAlive) {
      return 'Your mother died while giving birth to you. '
          'Your father raises you without her presence from the beginning '
          'of your life.';
    }

    if (mother != null && father == null) {
      return 'Your mother raises you on her own from birth. '
          'Your biological father is not part of your life.';
    }

    if (mother != null && father != null) {
      return 'You were born into a family with both of your biological '
          'parents. They try to provide the best life they can for you.';
    }

    return 'Your family situation is recorded in your family details.';
  }

  static String _economicNarrative(FamilyHousehold? household) {
    if (household == null || household.parents.isEmpty) {
      return 'Your family economic circumstances have not been recorded.';
    }

    final descriptions = <String>[];

    for (final parent in household.parents) {
      // Do not invent employment history for deceased NPCs.
      if (!parent.isAlive) continue;

      final description = _employmentDescription(parent);
      if (description != null) {
        descriptions.add(description);
      }
    }

    if (descriptions.isEmpty) {
      return 'No current parental or guardian employment information '
          'is available.';
    }

    return descriptions.join(' ');
  }

  static String? _employmentDescription(ParentNpc parent) {
    final occupation = parent.occupation?.trim();
    final role = _roleLabel(parent.role);

    switch (parent.employmentStatus) {
      case EmploymentStatus.employed:
        if (occupation == null || occupation.isEmpty) {
          return 'Your $role works as an employee.';
        }
        return 'Your $role works as a $occupation.';

      case EmploymentStatus.selfEmployed:
        if (occupation == null || occupation.isEmpty) {
          return 'Your $role is self-employed.';
        }
        return 'Your $role is self-employed as a $occupation.';

      case EmploymentStatus.unemployed:
        return 'Your $role is currently unemployed.';

      case EmploymentStatus.retired:
        return 'Your $role is retired.';

      case EmploymentStatus.homemaker:
        return 'Your $role takes care of the household.';

      case EmploymentStatus.unableToWork:
        return 'Your $role is unable to work.';
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
