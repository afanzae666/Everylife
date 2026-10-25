import '../../core/random/seeded_random.dart';
import '../../domain/character/character.dart';
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
    Character? player,
  }) {
    final events = <SimulationEvent>[
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
        description: _parentDetailsNarrative(household),
      ),
      SimulationEvent(
        id: 'starting-life-event-$year-conception',
        type: SimulationEventType.startingLifeEvent,
        year: year,
        title: 'My Conception',
        description: _conceptionNarrative(household, random),
      ),
    ];

    if (player != null) {
      events.add(
        SimulationEvent(
          id: 'starting-life-event-$year-birthday',
          type: SimulationEventType.startingLifeEvent,
          year: year,
          title: 'My Birthday',
          description: _birthdayNarrative(player.birthMonth, player.birthDay),
        ),
      );
    }

    return events;
  }

  static String _familyNarrative(
    FamilyHousehold? household,
    StartingBackground background,
  ) {
    if (household == null || household.parents.isEmpty) {
      return 'I was born into a ${background.label.toLowerCase()} background. '
          'My family situation has not been recorded.';
    }

    final parents = household.parents;
    final guardian = parents.any((parent) => parent.role == FamilyRole.guardian);
    final mother = _findRole(parents, FamilyRole.mother);
    final father = _findRole(parents, FamilyRole.father);
    final childYear = int.tryParse(household.id.split('-').last) ?? 0;
    final siblings = household.siblings.where((sibling) => sibling.birthYear <= childYear).toList(growable: false);

    String siblingSummary() {
      if (siblings.isEmpty) return '';
      final counts = <String, int>{};
      for (final sibling in siblings) {
        final age = sibling.birthYear < childYear ? 'older' : 'younger';
        final gender = sibling.gender.name == 'male' ? 'brother' : 'sister';
        counts['$age $gender'] = (counts['$age $gender'] ?? 0) + 1;
      }
      final phrases = counts.entries.map((e) => '${e.value} ${e.key}${e.value == 1 ? '' : 's'}').toList();
      return ' I have ${_joinPhrases(phrases)}.';
    }

    if (guardian) {
      return 'I was placed in an orphanage, where a guardian or caregiver looks after me. '
          'My biological parents are unknown.';
    }

    if (mother != null && !mother.isAlive && father != null && father.isAlive) {
      return 'My mother died while giving birth to me. My father raised me without her presence from the beginning of my life.' + siblingSummary();
    }

    if (mother != null && father == null) {
      return 'My mother raised me on her own from birth. My father is unknown.' + siblingSummary();
    }

    if (mother != null && father != null) {
      return 'I was born into a family with both of my parents. They tried to provide the best life they could for me.' + siblingSummary();
    }

    return 'My family situation is recorded in my family details.' + siblingSummary();
  }

  static String _parentDetailsNarrative(FamilyHousehold? household) {
    if (household == null || household.parents.isEmpty) {
      return 'My parents’ names and employment details are not available.';
    }
    final parents = household.parents;
    final hasFather = parents.any((parent) => parent.role == FamilyRole.father);
    final descriptions = <String>[];
    if (!hasFather) descriptions.add('My father is unknown.');
    for (final parent in parents) {
      final role = _roleLabel(parent.role);
      final ageText = 'age ${_parentAgeAtChildBirth(parent, household)}';
      if (!parent.isAlive) {
        final death = parent.deathYear == null ? '' : ' in ${parent.deathYear}';
        descriptions.add('My $role, ${parent.fullName}, is deceased$death ($ageText).');
        continue;
      }
      final employment = _employmentDescription(parent);
      if (employment == null) {
        descriptions.add('My $role, ${parent.fullName}, is $ageText.');
      } else {
        descriptions.add('My $role, ${parent.fullName}, $employment ($ageText).');
      }
    }
    return descriptions.join(' ');
  }

  static int _parentAgeAtChildBirth(ParentNpc parent, FamilyHousehold household) {
    // The generated parent birth year is relative to the player's birth year.
    final candidates = household.parents.map((p) => p.birthYear).toList();
    // Family generator sets parent birth years before the child birth year;
    // the household id ends in the child's birth year for backwards compatibility.
    final childYear = int.tryParse(household.id.split('-').last) ?? candidates.reduce((a, b) => a < b ? a : b) + 25;
    return (childYear - parent.birthYear).clamp(0, 120);
  }

  static String? _employmentDescription(ParentNpc parent) {
    final occupation = parent.occupation?.trim().toLowerCase();
    switch (parent.employmentStatus) {
      case EmploymentStatus.employed:
        if (occupation == null || occupation.isEmpty) return 'works as an employee';
        return 'works as ${_article(occupation)} $occupation';
      case EmploymentStatus.selfEmployed:
        if (occupation == null || occupation.isEmpty) return 'is self-employed';
        return 'is self-employed as ${_article(occupation)} $occupation';
      case EmploymentStatus.unemployed:
        return 'is currently unemployed';
      case EmploymentStatus.retired:
        return 'is retired';
      case EmploymentStatus.homemaker:
        return 'takes care of the household';
      case EmploymentStatus.unableToWork:
        return 'is unable to work';
    }
  }

  static String _conceptionNarrative(FamilyHousehold? household, SeededRandom random) {
    final parents = household?.parents ?? const <ParentNpc>[];
    final guardian = parents.any((parent) => parent.role == FamilyRole.guardian);
    final hasMother = parents.any((parent) => parent.role == FamilyRole.mother);
    final hasFather = parents.any((parent) => parent.role == FamilyRole.father);
    if (guardian || (!hasMother && !hasFather)) {
      return 'The circumstances of my conception are unknown.';
    }
    if (hasMother && !hasFather) {
      const stories = <String>[
        'My conception happened when my mother hooked up with someone at a concert. It is unknown whether the drummer or the singer was my father.',
        'My mother had a brief encounter with someone whose identity was never confirmed. My father is unknown.',
        'My mother never revealed who my biological father was, so the circumstances of my conception remain a mystery.',
      ];
      return stories[random.nextInt(stories.length)];
    }
    const stories = <String>[
      'My parents planned to start a family and were happy when they learned I was on the way.',
      'My parents were surprised by an unexpected pregnancy, but they prepared to welcome me.',
      'My parents conceived me while they were in a committed relationship and decided to raise me together.',
    ];
    return stories[random.nextInt(stories.length)];
  }

  static String _birthdayNarrative(int month, int day) {
    const months = <String>[
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final safeMonth = month.clamp(1, 12).toInt();
    final safeDay = day.clamp(1, 31).toInt();
    final zodiac = switch ((safeMonth, safeDay)) {
      (1, >= 20) || (2, <= 18) => 'Aquarius',
      (2, >= 19) || (3, <= 20) => 'Pisces',
      (3, >= 21) || (4, <= 19) => 'Aries',
      (4, >= 20) || (5, <= 20) => 'Taurus',
      (5, >= 21) || (6, <= 20) => 'Gemini',
      (6, >= 21) || (7, <= 22) => 'Cancer',
      (7, >= 23) || (8, <= 22) => 'Leo',
      (8, >= 23) || (9, <= 22) => 'Virgo',
      (9, >= 23) || (10, <= 22) => 'Libra',
      (10, >= 23) || (11, <= 21) => 'Scorpio',
      (11, >= 22) || (12, <= 21) => 'Sagittarius',
      _ => 'Capricorn',
    };
    return 'My birthday is ${months[safeMonth - 1]} $safeDay. I am a $zodiac.';
  }

  static String _article(String word) => RegExp(r'^[aeiou]').hasMatch(word) ? 'an' : 'a';

  static String _joinPhrases(List<String> phrases) {
    if (phrases.isEmpty) return '';
    if (phrases.length == 1) return phrases.first;
    if (phrases.length == 2) return '${phrases[0]} and ${phrases[1]}';
    return '${phrases.sublist(0, phrases.length - 1).join(', ')}, and ${phrases.last}';
  }

  static String _roleLabel(FamilyRole role) => switch (role) {
        FamilyRole.father => 'father',
        FamilyRole.mother => 'mother',
        FamilyRole.guardian => 'guardian',
        FamilyRole.stepFather => 'stepfather',
        FamilyRole.stepMother => 'stepmother',
      };
}
