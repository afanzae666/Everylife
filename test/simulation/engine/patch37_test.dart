import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/career/school_npc.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/gender.dart';
import 'package:everylife/domain/event/life_progress.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/domain/love/breakup_summary.dart';
import 'package:everylife/domain/love/cheating_rules.dart';
import 'package:everylife/domain/love/love_state.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/simulation/engine/simulation_engine.dart';
import 'package:everylife/simulation/events/life_event_catalog.dart';

void main() {
  SimulationEngine engineWith({
    required LifeProgress progress,
    int cash = 0,
    int seed = 1,
  }) {
    final base = SimulationEngine.create(
      player: Character.create(
        id: 'player-1',
        name: 'Test Player',
        gender: Gender.male,
        birthYear: 2000,
      ),
      seed: 3,
      saveRepository: InMemorySaveRepository(),
    );

    return SimulationEngine(
      initialState: base.state.copyWith(
        clock: SimulationClock(currentYear: 2026),
        player: base.state.player.copyWith(
          money: Money.fromMinorUnits(cash),
        ),
        lifeProgress: progress,
      ),
      random: SeededRandom(seed),
      saveRepository: InMemorySaveRepository(),
    );
  }

  SchoolNpc npc(String id, {int score = 100, Gender? gender}) => SchoolNpc(
        id: id,
        firstName: 'Dewi',
        lastName: id,
        gender: gender ?? Gender.female,
        birthYear: 2000,
        role: SchoolRole.classmate,
        relationshipPercent: score,
      );

  PendingLifeEvent pendingFor(String eventId) => PendingLifeEvent(
        eventId: eventId,
        year: 2026,
        subjectNpcId: 'pal-1',
        subjectName: 'Dewi pal-1',
        subjectFirst: 'Dewi',
        subjectRole: 'my wife',
        subjectGender: 'female',
      );

  LifeProgress progressFor({
    String stage = LoveRules.stageDating,
    Set<String> flags = const {},
    PendingLifeEvent? pending,
    List<SchoolNpc>? friends,
    bool hasPartner = true,
    String? prenup,
  }) =>
      LifeProgress(
        friends: friends ?? [npc('pal-1'), npc('fr-2', score: 80)],
        flags: flags,
        pending: pending,
        love: LoveState(
          partnerId: hasPartner ? 'pal-1' : null,
          partnerSince: 2023,
          stage: stage,
          stageSince: 2023,
          prenup: prenup,
        ),
      );

  NpcInteractionOutcome outcomeOf(Result<NpcInteractionOutcome> result) {
    expect(result.isSuccess, isTrue);

    return (result as Success<NpcInteractionOutcome>).value;
  }

  String factOf(BreakupSummary summary, String label) =>
      summary.facts.firstWhere((fact) => fact.key == label).value;

  group('Cheating rules', () {
    test('temperament never changes for the same person, and all occur', () {
      final seen = <Temperament>{};

      for (var i = 0; i < 60; i++) {
        final id = 'person-$i';

        expect(Temperament.of(id), Temperament.of(id));
        seen.add(Temperament.of(id));
      }

      expect(seen, Temperament.values.toSet());
    });

    int chance({
      bool shared = false,
      int times = 0,
      int others = 0,
      int smarts = 50,
      Temperament partner = Temperament.steady,
    }) =>
        CheatingRules.chance(
          sharedCircle: shared,
          timesWithLover: times,
          otherAffairs: others,
          partnerSmarts: smarts,
          partner: partner,
        );

    test('repeating, shared circles and sharp partners raise the chance', () {
      final base = chance();

      expect(base, CheatingRules.base);
      expect(chance(shared: true), greaterThan(base));
      expect(chance(times: 1), greaterThan(base));
      expect(chance(others: 2), greaterThan(base));
      expect(chance(smarts: 90), greaterThan(base));
      expect(chance(smarts: 35), lessThan(base));
      expect(chance(partner: Temperament.tender), lessThan(base));
    });

    test('the chance always stays within its limits', () {
      final high = chance(
        shared: true,
        times: 9,
        others: 9,
        smarts: 100,
        partner: Temperament.hothead,
      );
      final low = chance(smarts: 0, partner: Temperament.tender);

      expect(high, lessThanOrEqualTo(CheatingRules.ceiling));
      expect(low, greaterThanOrEqualTo(CheatingRules.floor));
    });
  });

  group('Caught cheating', () {
    test('every temperament has its own scene for both situations', () {
      for (final base in ['cheating_caught', 'marriage_caught']) {
        for (final suffix in ['', '_hothead', '_tender']) {
          final event = LifeEventCatalog.byId('$base$suffix');

          expect(event, isNotNull, reason: '$base$suffix');
          expect(event!.choices.length, greaterThan(1));
        }
      }
    });

    test('word gets around when I am found out', () {
      var found = false;

      for (var seed = 1; seed <= 80 && !found; seed++) {
        final engine = engineWith(seed: seed, progress: progressFor());

        outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex'));

        if (engine.state.lifeProgress.pending == null) continue;

        found = true;

        expect(
          engine.state.events.any((event) => event.title == 'Word Got Around'),
          isTrue,
        );

        // My lover is dragged into it and thinks less of me.
        final lover = engine.npcById('fr-2')!;

        expect(lover.relationshipPercent, lessThan(80));
      }

      expect(found, isTrue);
    });

    test('nobody confronts me while another decision is waiting', () {
      for (var seed = 1; seed <= 40; seed++) {
        final engine = engineWith(
          seed: seed,
          progress: progressFor(
            pending: pendingFor('marriage_anniversary'),
          ),
        );

        outcomeOf(engine.interactWithNpc(npcId: 'fr-2', action: 'Have Sex'));

        expect(
          engine.state.lifeProgress.pending?.eventId,
          'marriage_anniversary',
        );
      }
    });
  });

  group('End of a relationship overlay', () {
    test('Break Up queues an overlay once, with real facts', () {
      final engine = engineWith(progress: progressFor());
      final before = engine.state.player.stats.happiness;

      outcomeOf(engine.interactWithNpc(npcId: 'pal-1', action: 'Break Up'));

      expect(engine.hasBreakup, isTrue);

      final summary = engine.takeBreakup()!;

      expect(engine.hasBreakup, isFalse);
      expect(engine.takeBreakup(), isNull);
      expect(summary.kind, BreakupKind.breakup);
      expect(summary.npcId, 'pal-1');
      expect(summary.title.trim(), isNotEmpty);
      expect(summary.story.trim(), isNotEmpty);
      expect(summary.quip.trim(), isNotEmpty);
      expect(factOf(summary, 'Why'), 'I ended it');
      expect(factOf(summary, 'Together for'), '3 years');
      expect(factOf(summary, 'Now'), 'Ex');
      expect(factOf(summary, 'Relationship'), contains('moved to Exes'));
      expect(
        engine.state.player.stats.happiness,
        lessThan(before),
      );
    });

    test('a called-off engagement says so', () {
      final engine = engineWith(
        progress: progressFor(stage: LoveRules.stageEngaged),
      );

      outcomeOf(engine.interactWithNpc(npcId: 'pal-1', action: 'Break Up'));

      final summary = engine.takeBreakup()!;

      expect(summary.kind, BreakupKind.engagement);
      expect(factOf(summary, 'Engaged for'), '3 years');
    });

    test('a divorce shows the marriage, the money and the new label', () {
      final engine = engineWith(
        cash: 5000000,
        progress: progressFor(
          stage: LoveRules.stageMarried,
          prenup: 'none',
          flags: {'married'},
        ),
      );

      outcomeOf(engine.divorce(npcId: 'pal-1'));

      final summary = engine.takeBreakup()!;

      expect(summary.kind, BreakupKind.divorce);
      expect(factOf(summary, 'Married for'), '3 years');
      expect(factOf(summary, 'Children'), 'None');
      expect(factOf(summary, 'Prenup'), isNotEmpty);
      expect(factOf(summary, 'Property split'), isNotEmpty);
      expect(factOf(summary, 'Fine'), contains('I paid'));
      expect(factOf(summary, 'Cash left'), isNotEmpty);
      expect(factOf(summary, 'Now'), 'Ex-wife');
      expect(factOf(summary, 'Relationship'), startsWith('100% \u2192 0%'));
    });

    test('being left after cheating also shows an overlay', () {
      var shown = false;

      for (var seed = 1; seed <= 60 && !shown; seed++) {
        final engine = engineWith(
          seed: seed,
          progress: progressFor(
            flags: {'player_cheated'},
            pending: pendingFor('cheating_caught'),
          ),
        );

        engine.resolveLifeChoice('deny');

        if (!engine.hasBreakup) continue;

        shown = true;

        final summary = engine.takeBreakup()!;

        expect(summary.kind, BreakupKind.breakup);
        expect(factOf(summary, 'Why'), startsWith('I cheated on'));
        expect(engine.state.lifeProgress.love.partnerId, isNull);
      }

      expect(shown, isTrue);
    });

    test('a spouse who leaves me after catching me gets an overlay', () {
      var shown = false;

      for (var seed = 1; seed <= 60 && !shown; seed++) {
        final engine = engineWith(
          seed: seed,
          cash: 1000000,
          progress: progressFor(
            stage: LoveRules.stageMarried,
            prenup: 'none',
            flags: {'married', 'player_cheated'},
            pending: pendingFor('marriage_caught'),
          ),
        );

        engine.resolveLifeChoice('deny');

        if (!engine.hasBreakup) continue;

        shown = true;

        final summary = engine.takeBreakup()!;

        expect(summary.kind, BreakupKind.divorce);
        expect(factOf(summary, 'Why'), startsWith('I cheated on'));
        expect(factOf(summary, 'Fine'), 'None, clear grounds');
      }

      expect(shown, isTrue);
    });

    test('divorcing a cheater with proof shows clear grounds', () {
      var shown = false;

      for (var seed = 1; seed <= 60 && !shown; seed++) {
        final engine = engineWith(
          seed: seed,
          progress: progressFor(
            stage: LoveRules.stageMarried,
            prenup: 'none',
            flags: {'married', 'spouse_cheated'},
            pending: pendingFor('marriage_divorce_choice_a'),
          ),
        );

        engine.resolveLifeChoice('divorce');

        if (!engine.hasBreakup) continue;

        shown = true;

        expect(
          factOf(engine.takeBreakup()!, 'Why'),
          endsWith('cheated on me'),
        );
      }

      expect(shown, isTrue);
    });

    test('a long marriage with children hurts more than a short fling', () {
      int dropOf(LifeProgress progress) {
        final engine = engineWith(progress: progress);
        final before = engine.state.player.stats.happiness;

        engine.interactWithNpc(npcId: 'pal-1', action: 'Break Up');

        return before - engine.state.player.stats.happiness;
      }

      final short = dropOf(progressFor());
      final long = dropOf(
        progressFor().copyWith(
          love: const LoveState(
            partnerId: 'pal-1',
            partnerSince: 2010,
            stage: LoveRules.stageDating,
            stageSince: 2010,
          ),
        ),
      );

      expect(long, greaterThan(short));
    });
  });
}
