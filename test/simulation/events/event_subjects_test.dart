import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_event.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/simulation/events/life_event_catalog.dart';

void main() {
  const person = SchoolNpc(
    id: 'school-1',
    firstName: 'Rina',
    lastName: 'Putri',
    gender: Gender.female,
    birthYear: 2010,
    role: SchoolRole.classmate,
  );

  final pending = PendingLifeEvent(
    eventId: 'school_new_friend',
    year: 2020,
    subject: 'my classmate, Rina Putri',
    subjectNpcId: person.id,
    subjectKind: EventSubjectKind.classmate.name,
    subjectName: 'Rina Putri',
    subjectFirst: 'Rina',
    subjectRole: 'my classmate',
    subjectGender: Gender.female.name,
    subjectPerson: person,
  );

  test('placeholders are filled from the person the event is about', () {
    final text = LifeText.fillPending(
      '{Name} is {role}. {He} gave {him} {his} word; call {first}. {Role}.',
      pending,
    );

    expect(
      text,
      'Rina Putri is my classmate. She gave her her word; call Rina. My classmate.',
    );
  });

  test('pending events keep the person through save and load', () {
    final loaded = PendingLifeEvent.fromJson(pending.toJson())!;

    expect(loaded.subjectName, 'Rina Putri');
    expect(loaded.subjectKind, 'classmate');
    expect(loaded.subjectPerson?.id, 'school-1');
    expect(loaded.subjectPerson?.firstName, 'Rina');
  });

  test('old pending events without a person still load', () {
    final loaded = PendingLifeEvent.fromJson({
      'eventId': 'first_steps',
      'year': 2000,
    })!;

    expect(loaded.subjectPerson, isNull);
    expect(LifeText.fillPending('Hi {who}', loaded), 'Hi someone close to me');
  });

  test('events about a person use placeholders and only known ones', () {
    final known = RegExp(
      r'\{(name|Name|first|role|Role|he|He|him|his|His|who)\}',
    );

    for (final event in LifeEventCatalog.all) {
      final texts = [
        event.description,
        for (final choice in event.choices) ...[
          choice.label,
          for (final outcome in choice.outcomes) outcome.text,
        ],
      ];

      for (final text in texts) {
        final left = text.replaceAll(known, '');

        expect(left.contains(RegExp(r'\{[A-Za-z]+\}')), isFalse,
            reason: '${event.id}: $text');

        if (event.about == EventSubjectKind.none && !event.scripted) {
          expect(text.contains(RegExp(r'\{[a-zA-Z]+\}')), isFalse,
              reason: '${event.id}: $text');
        }
      }
    }
  });

  test('every person-based event names its person in the scene', () {
    for (final event in LifeEventCatalog.all) {
      if (event.about == EventSubjectKind.none) continue;

      expect(
        RegExp(r'\{(name|Name|first|Role|role)\}').hasMatch(event.description),
        isTrue,
        reason: event.id,
      );
    }
  });

  test('there are school, stranger and work friend events', () {
    bool has(EventSubjectKind kind) =>
        LifeEventCatalog.all.where((event) => event.about == kind).length >= 5;

    expect(has(EventSubjectKind.classmate), isTrue);
    expect(has(EventSubjectKind.teacher), isTrue);
    expect(has(EventSubjectKind.stranger), isTrue);
    expect(has(EventSubjectKind.coworker), isTrue);
    expect(has(EventSubjectKind.parent), isTrue);
    expect(has(EventSubjectKind.sibling), isTrue);
    expect(has(EventSubjectKind.friend), isTrue);
  });
}
