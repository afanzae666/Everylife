import 'dart:math' as math;

import '../../core/random/seeded_random.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/character/cultural_randomizer_catalog.dart';
import '../../domain/character/gender.dart';
import '../../domain/event/life_event.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/sibling_npc.dart';
import '../../domain/world/world_state.dart';

/// Picks the real person a life event is about and applies relationship
/// changes to exactly that person.
abstract final class EventSubjects {
  static String _parentRole(ParentNpc parent) => switch (parent.role) {
        FamilyRole.father => 'my father',
        FamilyRole.mother => 'my mother',
        FamilyRole.stepFather => 'my stepfather',
        FamilyRole.stepMother => 'my stepmother',
        FamilyRole.guardian => 'my guardian',
      };

  static String _facultyRole(SchoolRole role) => switch (role) {
        SchoolRole.teacher => 'my teacher',
        SchoolRole.principal => 'the principal',
        SchoolRole.professor => 'my professor',
        SchoolRole.dean => 'the dean',
        SchoolRole.classmate => 'my classmate',
      };

  static List<ParentNpc> _livingParents(WorldState state) => [
        for (final parent in state.familyHousehold?.parents ?? const <ParentNpc>[])
          if (parent.isAlive) parent,
      ];

  static List<SiblingNpc> _livingSiblings(WorldState state) {
    final year = state.clock.currentYear;

    return [
      for (final sibling
          in state.familyHousehold?.siblings ?? const <SiblingNpc>[])
        if (sibling.isAlive && sibling.birthYear <= year) sibling,
    ];
  }

  static List<SchoolNpc> _teachers(WorldState state) => [
        for (final npc in state.lifeProgress.education.faculty)
          if (npc.role != SchoolRole.principal && npc.role != SchoolRole.dean)
            npc,
      ];

  /// Whether a person of [kind] exists for this player right now.
  static bool isAvailable(EventSubjectKind kind, WorldState state) {
    return switch (kind) {
      EventSubjectKind.none ||
      EventSubjectKind.stranger ||
      EventSubjectKind.coworker =>
        true,
      EventSubjectKind.parent => _livingParents(state).isNotEmpty,
      EventSubjectKind.sibling => _livingSiblings(state).isNotEmpty,
      EventSubjectKind.classmate =>
        state.lifeProgress.education.classmates.isNotEmpty,
      EventSubjectKind.teacher => _teachers(state).isNotEmpty,
    };
  }

  /// A pending event for [definition] with its person chosen.
  static PendingLifeEvent start({
    required LifeEventDefinition definition,
    required WorldState state,
    required SeededRandom random,
  }) {
    final year = state.clock.currentYear;
    final base = PendingLifeEvent(eventId: definition.id, year: year);

    PendingLifeEvent withPerson({
      required String role,
      required String name,
      required String first,
      required Gender gender,
      String? npcId,
      SchoolNpc? person,
    }) =>
        PendingLifeEvent(
          eventId: definition.id,
          year: year,
          subject: '$role, $name',
          subjectNpcId: npcId,
          subjectKind: definition.about.name,
          subjectName: name,
          subjectFirst: first,
          subjectRole: role,
          subjectGender: gender.name,
          subjectPerson: person,
        );

    switch (definition.about) {
      case EventSubjectKind.none:
        return base;
      case EventSubjectKind.parent:
        final parents = _livingParents(state);
        if (parents.isEmpty) return base;
        final parent = parents[random.nextInt(parents.length)];
        return withPerson(
          role: _parentRole(parent),
          name: parent.fullName,
          first: parent.firstName,
          gender: parent.gender,
          npcId: parent.id,
        );
      case EventSubjectKind.sibling:
        final siblings = _livingSiblings(state);
        if (siblings.isEmpty) return base;
        final sibling = siblings[random.nextInt(siblings.length)];
        return withPerson(
          role: sibling.gender == Gender.female ? 'my sister' : 'my brother',
          name: sibling.fullName,
          first: sibling.firstName,
          gender: sibling.gender,
          npcId: sibling.id,
        );
      case EventSubjectKind.classmate:
        final mates = state.lifeProgress.education.classmates.toList();
        if (mates.isEmpty) return base;
        final mate = mates[random.nextInt(mates.length)];
        return withPerson(
          role: 'my classmate',
          name: mate.fullName,
          first: mate.firstName,
          gender: mate.gender,
          npcId: mate.id,
          person: mate,
        );
      case EventSubjectKind.teacher:
        final staff = _teachers(state);
        if (staff.isEmpty) return base;
        final teacher = staff[random.nextInt(staff.length)];
        return withPerson(
          role: _facultyRole(teacher.role),
          name: teacher.fullName,
          first: teacher.firstName,
          gender: teacher.gender,
          npcId: teacher.id,
          person: teacher,
        );
      case EventSubjectKind.stranger:
      case EventSubjectKind.coworker:
        final stranger = _makeStranger(state, random);
        return withPerson(
          role: definition.about == EventSubjectKind.coworker
              ? 'my coworker'
              : 'a stranger',
          name: stranger.fullName,
          first: stranger.firstName,
          gender: stranger.gender,
          npcId: stranger.id,
          person: stranger,
        );
    }
  }

  static SchoolNpc _makeStranger(WorldState state, SeededRandom random) {
    final player = state.player;
    final country = player.location?.countryCode ?? 'US';
    final gender = random.nextBool() ? Gender.male : Gender.female;
    final year = state.clock.currentYear;

    return SchoolNpc(
      id: 'stranger-$year-${random.nextInt(100000)}',
      firstName: CulturalRandomizerCatalog.randomFirstName(
        countryCode: country,
        gender: gender,
        random: math.Random(random.nextInt(0x3fffffff)),
      ),
      lastName: CulturalRandomizerCatalog.randomLastName(
        countryCode: country,
        random: math.Random(random.nextInt(0x3fffffff)),
      ),
      gender: gender,
      birthYear: player.birthYear + random.nextInt(7) - 3,
      role: SchoolRole.classmate,
      countryCode: country,
      relationshipPercent: 20,
    );
  }

  /// Moves the relationship with the event's person by [delta].
  static WorldState applyRelation(
    WorldState state,
    PendingLifeEvent? pending,
    int delta,
  ) {
    final npcId = pending?.subjectNpcId;

    if (npcId == null || delta == 0) return state;

    int shift(int score) => (score + delta).clamp(-100, 100).toInt();

    final household = state.familyHousehold;
    var next = state;

    if (household != null) {
      next = next.copyWith(
        familyHousehold: household.copyWith(
          parents: [
            for (final parent in household.parents)
              parent.id == npcId
                  ? parent.copyWith(
                      relationshipPercent: shift(parent.relationshipPercent),
                    )
                  : parent,
          ],
          siblings: [
            for (final sibling in household.siblings)
              sibling.id == npcId
                  ? sibling.copyWith(
                      relationshipPercent: shift(sibling.relationshipPercent),
                    )
                  : sibling,
          ],
        ),
      );
    }

    final education = next.lifeProgress.education;

    if (education.npcs.any((npc) => npc.id == npcId)) {
      next = next.copyWith(
        lifeProgress: next.lifeProgress.copyWith(
          education: education.copyWith(
            npcs: [
              for (final npc in education.npcs)
                npc.id == npcId
                    ? npc.copyWith(
                        relationshipPercent: shift(npc.relationshipPercent),
                      )
                    : npc,
            ],
          ),
        ),
      );
    }

    return next;
  }
}
