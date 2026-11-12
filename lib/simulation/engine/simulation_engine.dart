
import '../../data/repositories/timeline_store.dart';
import '../../core/random/seeded_random.dart';
import '../narrative/npc_interaction_narratives.dart';
import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';
import '../../data/services/save_manager.dart';
import 'package:everylife/core/money/money.dart';
import '../../domain/character/character.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/major_catalog.dart';
import '../../domain/character/life_stage.dart';
import '../../domain/event/life_event.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/sibling_npc.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/social/social_rules.dart';
import '../narrative/school_narratives.dart';
import '../narrative/infant_narratives.dart';
import '../narrative/love_narratives.dart';
import '../narrative/breakup_narratives.dart';
import '../narrative/marriage_narratives.dart';
import '../narrative/relationship_narratives.dart';
import '../school/school_appearance.dart';
import '../../domain/character/fertility.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/cultural_randomizer_catalog.dart';
import 'dart:math' as math;
import '../../domain/love/breakup_summary.dart';
import '../../domain/love/genetics.dart';
import '../../domain/love/love_state.dart';
import '../../domain/time/simulation_clock.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../career/career_actions.dart';
import '../career/school_actions.dart';
import '../school/school_setup.dart';
import '../events/event_subjects.dart';
import '../events/money_text.dart';
import '../events/life_effect_applier.dart';
import '../events/life_event_catalog.dart';
import '../generation/family_household_generator.dart';
import '../generation/starting_life_event_generator.dart';
import '../systems/career_system.dart';
import '../systems/character_system.dart';
import '../systems/education_system.dart';
import '../systems/family_mortality_system.dart';
import '../systems/event_system.dart';
import '../systems/mortality_system.dart';
import '../systems/npc_economy_system.dart';
import '../systems/parent_economy_system.dart';
import '../systems/simulation_system.dart';
import '../systems/time_system.dart';
import 'simulation_scheduler.dart';
import 'simulation_tick.dart';
import 'world_state_validator.dart';

class SimulationEngine {
  SimulationEngine({
    required WorldState initialState,
    required SeededRandom random,
    required SaveRepository saveRepository,
    int nextTickId = 1,
  })  : _state = initialState,
        _random = random,
        _saveManager = saveRepository is SaveManager
            ? saveRepository
            : SaveManager(
                repository: saveRepository,
              ),
        _scheduler = SimulationScheduler(
          systems: [
            TimeSystem(),
            ParentEconomySystem(),
            NpcEconomySystem(),
            CharacterSystem(),
          ],
        ),
        _validator = const WorldStateValidator(),
        _nextTickId = nextTickId {
    if (nextTickId < 1) {
      throw ArgumentError.value(
        nextTickId,
        'nextTickId',
        'Must be greater than zero.',
      );
    }
  }

  /// The player may interact with a family member as often as they like.
  /// Each kind of interaction (Talk, Spend Time, ...) only moves the
  /// relationship the first time it is used with that person in a year; after
  /// that it still plays out, but the relationship stays where it is.
  bool hasInteractionProgressedThisYear(String npcId, String action) {
    final key = '${_state.clock.currentYear}:$npcId:$action';

    return (_state.lifeProgress.interactionCounts[key] ?? 0) > 0;
  }

  WorldState _state;

  final SeededRandom _random;
  final SaveManager _saveManager;
  final SimulationScheduler _scheduler;
  final WorldStateValidator _validator;

  int _nextTickId;

  WorldState get state => _state;

  SeededRandom get random => _random;

  List<SimulationSystem> get systems => _scheduler.systems;

  int get nextTickId => _nextTickId;

  void registerSystem(
    SimulationSystem system,
  ) {
    _scheduler.registerSystem(system);
  }

  /// Registers the systems that make a life unpredictable: yearly death
  /// rolls and random life events. Kept separate from the constructor so
  /// engine tests can run without randomness.
  void registerGameplaySystems() {
    registerSystem(FamilyMortalitySystem(random: _random));
    registerSystem(EducationSystem(random: _random));
    registerSystem(CareerSystem(random: _random));
    registerSystem(MortalitySystem(random: _random));
    registerSystem(EventSystem(random: _random));
  }

  /// Jobs the player currently qualifies for.
  List<JobDefinition> get availableJobs => CareerActions.availableJobs(_state);

  /// Chance (percent) of being hired for [job].
  int hiringChance(JobDefinition job) => CareerActions.hiringChance(_state, job);

  /// Chance (percent) that a university application succeeds.
  int get universityChance => CareerActions.universityChance(_state);

  /// Yearly tuition of [major] in the player's country, in minor units.
  int tuitionFor(MajorDefinition major) =>
      CareerActions.tuitionFor(_state, major);

  /// Why the player cannot apply for [major], or null when they can.
  String? majorBlocker(MajorDefinition major) =>
      CareerActions.majorBlocker(_state, major);

  Result<String> applyForJob(String jobId) => _commitAction(
        CareerActions.applyForJob(
          state: _state,
          random: _random,
          jobId: jobId,
        ),
      );

  Result<String> quitJob() => _commitAction(CareerActions.quitJob(_state));

  Result<String> askForRaise() => _commitAction(
        CareerActions.askForRaise(state: _state, random: _random),
      );

  Result<String> applyForUniversity(String majorId) => _commitAction(
        CareerActions.applyForUniversity(
          state: _state,
          random: _random,
          majorId: majorId,
        ),
      );

  /// Makes sure the school for the current stage exists (name, classmates,
  /// faculty). Safe to call at any time.
  void ensureSchool() {
    _state = SchoolSetup.ensure(_state);
  }

  Result<String> studyHarder() {
    ensureSchool();

    return _commitAction(
      SchoolActions.studyHarder(state: _state, random: _random),
    );
  }

  Result<String> joinClub(String clubId) {
    ensureSchool();

    return _commitAction(
      SchoolActions.joinClub(
        state: _state,
        clubId: clubId,
        random: _random,
      ),
    );
  }

  Result<String> trainClub() {
    ensureSchool();

    return _commitAction(
      SchoolActions.trainClub(state: _state, random: _random),
    );
  }

  Result<String> leaveClub() {
    ensureSchool();

    return _commitAction(
      SchoolActions.leaveClub(state: _state, random: _random),
    );
  }

  /// The club rank (1 or 2) the player just earned and has not seen yet.
  int? get clubPromotion => _state.lifeProgress.education.clubPromotion;

  /// Marks the club promotion as announced.
  void acknowledgeClubPromotion() {
    final education = _state.lifeProgress.education;

    if (education.clubPromotion == null) return;

    _state = _state.copyWith(
      lifeProgress: _state.lifeProgress.copyWith(
        education: education.copyWith(clearClubPromotion: true),
      ),
    );
  }

  Result<String> dropOutOfSchool() =>
      _commitAction(CareerActions.dropOutOfSchool(_state));

  Result<String> _commitAction(Result<CareerActionResult> result) {
    if (result case Failure<CareerActionResult>(:final message)) {
      return Failure(message);
    }

    final action = (result as Success<CareerActionResult>).value;
    final committed = _commit(action.state);

    if (committed case Failure<void>(:final message)) {
      return Failure(message);
    }

    return Success(action.message);
  }

  /// Endings (divorce, breakup, called-off engagement) that the screen has
  /// not shown yet, oldest first.
  final List<BreakupSummary> _breakups = <BreakupSummary>[];

  /// True while an ending is waiting to be shown.
  bool get hasBreakup => _breakups.isNotEmpty;

  /// The next ending to show, removed from the queue. Null when none.
  BreakupSummary? takeBreakup() =>
      _breakups.isEmpty ? null : _breakups.removeAt(0);

  /// The event currently waiting for the player's decision, if any.
  LifeEventDefinition? get pendingLifeEvent {
    final pending = _state.lifeProgress.pending;

    if (pending == null) return null;

    return LifeEventCatalog.byId(pending.eventId);
  }

  /// Who the pending scripted event is about (for example "my father, Alex").
  String? get pendingSubject => _state.lifeProgress.pending?.subject;

  /// Scene text of the pending event with its placeholders filled in.
  String get pendingDescription {
    final event = pendingLifeEvent;

    if (event == null) return '';

    return LifeText.fillPending(
      event.description,
      _state.lifeProgress.pending,
    );
  }

  /// Whether the player can afford [choice] right now.
  bool canAffordChoice(LifeChoice choice) {
    final required = LifeEffectApplier.scaleMoney(
      _state,
      choice.requiresMoneyBase,
    );

    return _state.player.money.minorUnits >= required;
  }

  /// Resolves the pending event with the chosen option.
  Result<LifeChoiceResult> resolveLifeChoice(String choiceId) {
    final pending = _state.lifeProgress.pending;

    if (pending == null) {
      return const Failure('There is no event waiting for a decision.');
    }

    final definition = LifeEventCatalog.byId(pending.eventId);

    if (definition == null) {
      // The event no longer exists (for example after a game update).
      // Drop it instead of trapping the player in an unresolvable state.
      final cleared = _state.copyWith(
        lifeProgress: _state.lifeProgress.copyWith(clearPending: true),
      );
      _commit(cleared);

      return const Failure('That event is no longer available.');
    }

    LifeChoice? choice;
    for (final candidate in definition.choices) {
      if (candidate.id == choiceId) {
        choice = candidate;
        break;
      }
    }

    if (choice == null) {
      return const Failure('Unknown choice.');
    }

    if (!canAffordChoice(choice)) {
      return const Failure('You cannot afford this choice.');
    }

    final outcome = LifeEffectApplier.pickOutcome(choice.outcomes, _random);

    _friendOffer = EventSubjects.friendCandidate(_state, pending, outcome);

    final applied = EventSubjects.applyToSubject(
      LifeEffectApplier.applyOutcome(state: _state, outcome: outcome),
      pending,
      outcome,
    );

    final progress = applied.lifeProgress.copyWith(
      choices: {
        ...applied.lifeProgress.choices,
        definition.id: choice.id,
      },
      clearPending: true,
    );

    // One flowing paragraph: the scene, what I did, and what happened.
    final story = LifeText.fillPending(choice.story, pending);
    final result = LifeText.fillPending(outcome.text, pending);
    final scene = LifeText.fillPending(definition.description, pending);

    final nextState = applied.copyWith(lifeProgress: progress).addEvent(
          SimulationEvent(
            id: 'life-choice-${pending.year}-${definition.id}',
            type: SimulationEventType.lifeChoice,
            year: pending.year,
            title: definition.title,
            description: '$scene $story $result',
          ),
        );

    final committed = _commit(nextState);

    if (committed case Failure<void>(:final message)) {
      return Failure(message);
    }

    // A spouse who asked for a divorce gets one.
    _processMarriageFlags();

    return Success(
      LifeChoiceResult(
        eventTitle: definition.title,
        choiceLabel: choice.label,
        resultText: '$story $result',
      ),
    );
  }

  Result<void> execute(
    SimulationCommand<dynamic> command,
  ) {
    final validation = _validator.validate(_state);

    if (validation
        case Failure<void>(
          :final message,
        )) {
      return Failure(message);
    }

    final result = _scheduler.execute(
      state: _state,
      command: command,
    );

    return switch (result) {
      Success<WorldState>(
        :final value,
      ) =>
        _commit(value),
      Failure<WorldState>(
        :final message,
      ) =>
        Failure(message),
    };
  }

  Result<void> _commit(
    WorldState nextState,
  ) {
    final validation = _validator.validate(nextState);

    if (validation
        case Failure<void>(
          :final message,
        )) {
      return Failure(message);
    }

    _state = nextState;

    return const Success(null);
  }

  Result<NpcInteractionOutcome> interactWithNpc({
    required String npcId,
    required String action,
  }) {
    final playerAge = (_state.clock.currentYear - _state.player.birthYear)
        .clamp(0, 150)
        .toInt();
    final playerStage = LifeStageAge.fromAge(playerAge);
    if (playerStage == LifeStage.infant &&
        !const ['Play', 'Cry'].contains(action)) {
      return const Failure('Babies can only play and cry.');
    }
    if (action == 'Become Friends') return _befriendNpc(npcId);

    if (_loveActions.contains(action)) return _loveAction(npcId, action);

    if (_state.lifeProgress.love.children.any((child) => child.id == npcId)) {
      return _childInteraction(npcId, action);
    }

    if (action == NpcInteractionOutcome.bestFriendYes ||
        action == NpcInteractionOutcome.bestFriendNo) {
      return _answerBestFriend(
        npcId,
        yes: action == NpcInteractionOutcome.bestFriendYes,
      );
    }

    if ((playerStage == LifeStage.toddler || playerStage == LifeStage.child) &&
        !const ['Talk', 'Spend Time', 'Compliment', 'Help', 'Play']
            .contains(action)) {
      return const Failure('This interaction is not available at your current life stage.');
    }

    final household = _state.familyHousehold;
    final education = _state.lifeProgress.education;
    final parentIndex =
        household?.parents.indexWhere((npc) => npc.id == npcId) ?? -1;
    final siblingIndex =
        household?.siblings.indexWhere((npc) => npc.id == npcId) ?? -1;
    final schoolIndex = education.npcs.indexWhere((npc) => npc.id == npcId);
    final friends = _state.lifeProgress.friends;
    final friendIndex = friends.indexWhere((npc) => npc.id == npcId);

    if (parentIndex < 0 &&
        siblingIndex < 0 &&
        schoolIndex < 0 &&
        friendIndex < 0) {
      return Failure(
        household == null && education.npcs.isEmpty
            ? 'No NPC household is available.'
            : 'NPC could not be found.',
      );
    }

    final isParent = parentIndex >= 0;
    final isSibling = siblingIndex >= 0;
    final alive = isParent
        ? household!.parents[parentIndex].isAlive
        : isSibling
            ? household!.siblings[siblingIndex].isAlive
            : true;
    if (!alive) return const Failure('A deceased NPC cannot be interacted with.');

    final npcBirthYear = isParent
        ? household!.parents[parentIndex].birthYear
        : isSibling
            ? household!.siblings[siblingIndex].birthYear
            : friendIndex >= 0
                ? friends[friendIndex].birthYear
                : education.npcs[schoolIndex].birthYear;
    final npcIsBaby = _state.clock.currentYear - npcBirthYear <= 2;

    if (npcIsBaby && action != 'Play') {
      return const Failure('A baby can only play.');
    }

    if (!npcIsBaby && (action == 'Play' || action == 'Cry') &&
        playerStage != LifeStage.infant) {
      return const Failure('This interaction is not available right now.');
    }

    final currentScore = isParent
        ? household!.parents[parentIndex].relationshipPercent
        : isSibling
            ? household!.siblings[siblingIndex].relationshipPercent
            : friendIndex >= 0
                ? friends[friendIndex].relationshipPercent
                : education.npcs[schoolIndex].relationshipPercent;
    final change = switch (action) {
      'Talk' => 2,
      'Spend Time' => 5,
      'Compliment' => 3,
      'Help' => 4,
      'Argue' => -8,
      'Apologize' => 4,
      'Play' => 3,
      'Cry' => 2,
      _ => null,
    };
    if (change == null) return const Failure('Unknown NPC interaction.');

    final interactionKey = '${_state.clock.currentYear}:$npcId:$action';
    final timesThisYear = _state.lifeProgress.interactionCounts[interactionKey] ?? 0;
    // Only the first use of each interaction per year moves the relationship.
    final progressed = timesThisYear == 0;
    final nextScore = progressed
        ? (currentScore + change).clamp(-100, 100).toInt()
        : currentScore;
    final npcName = isParent
        ? household!.parents[parentIndex].fullName
        : isSibling
            ? household!.siblings[siblingIndex].fullName
            : friendIndex >= 0
                ? friends[friendIndex].fullName
                : education.npcs[schoolIndex].fullName;
    // Someone who is very distant may simply refuse. A small chance remains
    // that they hear me out.
    if (change > 0 &&
        !npcIsBaby &&
        currentScore <= LoveRules.refuseAtOrBelow) {
      final repair = action == 'Apologize' || action == 'Help';
      final refuses = _random.nextDouble() < (repair ? 0.55 : 0.75);

      if (refuses) {
        return _socialOutcome(
          npcId: npcId,
          action: action,
          narrative: RelationshipNarratives.refuse(
            _random,
            npcName,
            repair: action == 'Apologize',
          ),
          score: currentScore,
          bond: _state.lifeProgress.love.exIds.contains(npcId)
              ? 'ex'
              : friendIndex >= 0
                  ? (friends[friendIndex].bestFriend ? 'best friend' : 'friend')
                  : 'none',
          romance:
              _state.lifeProgress.love.partnerId == npcId ? 'partner' : 'none',
          progressed: false,
          refused: true,
        );
      }
    }

    final narrative = action == 'Play' || action == 'Cry'
        ? InfantNarratives.pick(
            _random,
            action: action,
            name: npcName,
            playerIsBaby: playerStage == LifeStage.infant,
          )
        : NpcInteractionNarratives.pick(
            random: _random,
            action: action,
            npcName: npcName,
            stage: playerStage,
            kind: isParent
                ? NpcKind.parent
                : isSibling
                    ? NpcKind.sibling
                    : NpcKind.schoolmate,
            score: currentScore,
          );

    var nextHousehold = household;
    var nextEducation = education;

    if (isParent || isSibling) {
      final parents = List.of(household!.parents);
      final siblings = List.of(household.siblings);
      if (isParent) {
        parents[parentIndex] = parents[parentIndex].copyWith(relationshipPercent: nextScore);
      } else {
        siblings[siblingIndex] = siblings[siblingIndex].copyWith(relationshipPercent: nextScore);
      }
      nextHousehold = household.copyWith(
        parents: parents,
        siblings: siblings,
      );
    }

    // Friends and school people share one relationship score.
    var nextFriends = friends;

    if (friendIndex >= 0) {
      nextFriends = List.of(friends);
      nextFriends[friendIndex] =
          friends[friendIndex].copyWith(relationshipPercent: nextScore);
    }

    if (schoolIndex >= 0 && !isParent && !isSibling) {
      final npcs = List.of(education.npcs);
      npcs[schoolIndex] = npcs[schoolIndex].copyWith(relationshipPercent: nextScore);
      nextEducation = education.copyWith(npcs: npcs);
    }
    final event = SimulationEvent(
      id: 'npc-interaction-${_state.events.length + 1}-${_state.clock.currentYear}-$npcId',
      type: SimulationEventType.npcInteraction,
      year: _state.clock.currentYear,
      title: action,
      description: narrative,
    );
    final statEffect = !progressed
        ? null
        : switch (action) {
      'Spend Time' => const StatEffect(StatKey.happiness, 1),
      'Play' => const StatEffect(StatKey.happiness, 1),
      'Apologize' => const StatEffect(StatKey.happiness, 1),
      'Compliment' => const StatEffect(StatKey.charisma, 1),
      'Help' => const StatEffect(StatKey.willpower, 1),
      'Argue' => const StatEffect(StatKey.happiness, -2),
      _ => null,
    };
    var interactionStats = _state.player.stats;
    if (statEffect != null) {
      final raised = interactionStats.valueOf(statEffect.stat) + statEffect.delta;
      interactionStats = switch (statEffect.stat) {
        StatKey.happiness => interactionStats.copyWith(happiness: raised),
        StatKey.charisma => interactionStats.copyWith(charisma: raised),
        StatKey.willpower => interactionStats.copyWith(willpower: raised),
        _ => interactionStats,
      };
    }
    final nextState = _state.copyWith(
      player: _state.player.copyWith(stats: interactionStats),
      familyHousehold: nextHousehold,
      events: [..._state.events, event],
      lifeProgress: _state.lifeProgress.copyWith(
        education: nextEducation,
        friends: nextFriends,
        interactionCounts: {
          // Only this year's counts matter; older keys are dropped.
          for (final entry in _state.lifeProgress.interactionCounts.entries)
            if (entry.key.startsWith('${_state.clock.currentYear}:'))
              entry.key: entry.value,
          interactionKey: timesThisYear + 1,
        },
      ),
    );
    final committed = _commit(nextState);
    if (committed case Failure<void>(:final message)) return Failure(message);

    String? prompt;
    var bond = 'none';

    if (_state.lifeProgress.love.exIds.contains(npcId)) {
      bond = 'ex';
    } else if (friendIndex >= 0) {
      final friend = friends[friendIndex];

      bond = friend.bestFriend ? 'best friend' : 'friend';

      // A partner is already more than a best friend, so no prompt.
      if (progressed &&
          _state.lifeProgress.love.partnerId != npcId &&
          !friend.bestFriend &&
          nextScore >= SocialRules.bestFriendAt) {
        if (!friend.bestFriendAsked) {
          prompt = 'bestFriend';
        } else if (nextScore >= 100) {
          // I said no once. A perfect friendship asks again now and then,
          // at most once a year.
          final year = _state.clock.currentYear;
          final askedKey = '$year:$npcId:bf-asked';
          final progress = _state.lifeProgress;

          if ((progress.interactionCounts[askedKey] ?? 0) == 0 &&
              _random.nextInt(100) < 35) {
            prompt = 'bestFriend';
            _commit(
              _state.copyWith(
                lifeProgress: progress.copyWith(
                  interactionCounts: {
                    ...progress.interactionCounts,
                    askedKey: 1,
                  },
                ),
              ),
            );
          }
        }
      }
    }

    return Success(NpcInteractionOutcome(
      npcId: npcId,
      action: action,
      narrative: narrative,
      relationshipPercent: nextScore,
      bond: bond,
      prompt: prompt,
      romance:
          _state.lifeProgress.love.partnerId == npcId ? 'partner' : 'none',
      stage: _state.lifeProgress.love.partnerId == npcId
          ? _state.lifeProgress.love.stage
          : LoveRules.stageDating,
      onBirthControl: _state.lifeProgress.love.birthControl.contains(npcId),
      progressed: progressed,
      year: _state.clock.currentYear,
      age: (_state.clock.currentYear - _state.player.birthYear).clamp(0, 150),
    ));
  }

  SchoolNpc? _friendOffer;

  /// Someone an event just offered friendship to. The player accepts or
  /// declines with [acceptFriendOffer] and [declineFriendOffer].
  SchoolNpc? get friendOffer => _friendOffer;

  /// Says no, and the life log remembers it.
  void declineFriendOffer() {
    final person = _friendOffer;

    _friendOffer = null;

    if (person == null) return;

    const lines = [
      'I decided not to become friends with {n}. We stayed acquaintances.',
      'I kept my distance from {n}. Not everyone has to become a friend.',
      'I politely passed on a friendship with {n}.',
    ];
    final text =
        lines[_random.nextInt(lines.length)].replaceAll('{n}', person.fullName);

    _commit(
      _state.copyWith(
        events: [
          ..._state.events,
          SimulationEvent(
            id: 'friend-declined-${_state.events.length + 1}-${_state.clock.currentYear}-${person.id}',
            type: SimulationEventType.npcInteraction,
            year: _state.clock.currentYear,
            title: 'Said no to a friend',
            description: text,
          ),
        ],
      ),
    );
  }

  /// Adds the offered person to the friends list.
  Result<String> acceptFriendOffer() {
    final person = _friendOffer;

    if (person == null) return const Failure('Nobody is waiting to be asked.');

    _friendOffer = null;

    if (_state.lifeProgress.friends.any((friend) => friend.id == person.id)) {
      return const Failure('We are already friends.');
    }

    final text = SchoolNarratives.befriend(_random, person.fullName);

    final next = _state.copyWith(
      lifeProgress: _state.lifeProgress.copyWith(
        friends: [..._state.lifeProgress.friends, person],
      ),
      events: [
        ..._state.events,
        SimulationEvent(
          id: 'friend-${_state.events.length + 1}-${_state.clock.currentYear}-${person.id}',
          type: SimulationEventType.npcInteraction,
          year: _state.clock.currentYear,
          title: 'New friend',
          description: text,
        ),
      ],
    );

    final committed = _commit(next);

    if (committed case Failure<void>(:final message)) return Failure(message);

    return Success(text);
  }


  // ---------------------------------------------------------------------
  // Love: dating, pregnancy, children.
  // ---------------------------------------------------------------------

  static const Set<String> _loveActions = {
    'Start Dating',
    'Go on a Date',
    'Have Sex',
    'Break Up',
    'Get Back Together',
    'Birth Control',
    NpcInteractionOutcome.pregnancyKeep,
    NpcInteractionOutcome.pregnancyEnd,
  };

  /// A friend or classmate by id (used to show their picture).
  SchoolNpc? npcById(String id) => _personById(id);

  SchoolNpc? _personById(String id) {
    for (final friend in _state.lifeProgress.friends) {
      if (friend.id == id) return friend;
    }

    for (final npc in _state.lifeProgress.education.npcs) {
      if (npc.id == id) return npc;
    }

    return null;
  }

  /// Writes a new relationship score to every saved copy of a person.
  LifeProgress _scored(LifeProgress progress, String id, int score) {
    SchoolNpc update(SchoolNpc npc) =>
        npc.id == id ? npc.copyWith(relationshipPercent: score) : npc;

    return progress.copyWith(
      friends: [for (final friend in progress.friends) update(friend)],
      education: progress.education.copyWith(
        npcs: [for (final npc in progress.education.npcs) update(npc)],
      ),
    );
  }

  ParentGenes _playerGenes() {
    final player = _state.player;
    final look = player.appearance;

    return ParentGenes(
      skinTone: look.skinTone,
      hairColor: look.hairColor,
      eyeColor: look.eyeColor,
      eyebrows: look.eyebrows,
      looks: player.stats.looks,
      smarts: player.stats.intelligence,
      fertility: player.stats.fertility,
    );
  }

  ParentGenes _genesOf(SchoolNpc npc) {
    final look = SchoolAppearance.forNpc(npc);
    final traits = NpcTraits.forPerson(
      id: npc.id,
      gender: npc.gender,
      birthYear: npc.birthYear,
      currentYear: _state.clock.currentYear,
    );

    return ParentGenes(
      skinTone: look.skinTone,
      hairColor: look.hairColor,
      eyeColor: look.eyeColor,
      eyebrows: look.eyebrows,
      looks: traits.looks,
      smarts: traits.smarts,
      fertility: traits.fertilityBase,
    );
  }

  Result<NpcInteractionOutcome> _loveAction(String npcId, String action) {
    final year = _state.clock.currentYear;
    final playerAge = year - _state.player.birthYear;
    final progress = _state.lifeProgress;
    final love = progress.love;
    final person = _personById(npcId);

    if (person == null) return const Failure('I cannot find this person.');

    final age = year - person.birthYear;
    final name = person.fullName;
    final score = person.relationshipPercent;

    WorldState withStats(WorldState state, {int happiness = 0}) =>
        state.copyWith(
          player: state.player.copyWith(
            stats: state.player.stats.copyWith(
              happiness: state.player.stats.happiness + happiness,
            ),
          ),
        );

    if (action == 'Start Dating') {
      if (!person.role.isStudent) {
        return const Failure('I cannot date this person.');
      }

      if (love.exIds.contains(npcId)) {
        return const Failure('We broke up. That chapter is closed.');
      }

      if (love.hasPartner) {
        return const Failure('I already have a partner.');
      }

      if (!LoveRules.canDate(playerAge, age)) {
        return const Failure('We are not at the right age to date.');
      }

      if (score < LoveRules.dateAt) {
        return const Failure(
          'We are not close enough yet. Let us spend more time together.',
        );
      }

      final next = (score + 8).clamp(-100, 100).toInt();
      final partner = person.copyWith(relationshipPercent: next);
      final friends = progress.friends.any((friend) => friend.id == npcId)
          ? progress.friends
          : [...progress.friends, partner];
      final updated = _scored(
        progress.copyWith(
          friends: friends,
          love: love.copyWith(
            partnerId: npcId,
            partnerSince: year,
            stage: LoveRules.stageDating,
            stageSince: year,
          ),
        ),
        npcId,
        next,
      );

      return _socialOutcome(
        npcId: npcId,
        action: action,
        narrative: LoveNarratives.startDating(_random, name),
        score: next,
        bond: 'friend',
        romance: 'partner',
        next: withStats(
          _state.copyWith(lifeProgress: updated),
          happiness: 5,
        ),
      );
    }

    if (action == 'Get Back Together') {
      if (!love.exIds.contains(npcId)) {
        return const Failure('This person is not my ex.');
      }

      if (love.hasPartner) {
        return const Failure('I already have a partner.');
      }

      if (!LoveRules.canDate(playerAge, age)) {
        return const Failure('We are not at the right age to date.');
      }

      if (score < LoveRules.getBackAt) {
        return const Failure(
          'The wounds are still fresh. We need to rebuild trust first.',
        );
      }

      final next = (score + 10).clamp(-100, 100).toInt();
      final exes = {...love.exIds}..remove(npcId);
      final updated = _scored(
        progress.copyWith(
          love: love.copyWith(
            partnerId: npcId,
            partnerSince: year,
            stageSince: year,
            exIds: exes,
          ),
        ),
        npcId,
        next,
      );

      return _socialOutcome(
        npcId: npcId,
        action: action,
        narrative: RelationshipNarratives.getBack(_random, name),
        score: next,
        bond: 'friend',
        romance: 'partner',
        next: withStats(
          _state.copyWith(lifeProgress: updated),
          happiness: 6,
        ),
      );
    }

    if (action == 'Have Sex' && love.partnerId != npcId) {
      return _hookUp(npcId, person);
    }

    final answersPregnancy = (action == NpcInteractionOutcome.pregnancyKeep ||
            action == NpcInteractionOutcome.pregnancyEnd) &&
        love.pregnancy?.partner.id == npcId;

    if (love.partnerId != npcId && !answersPregnancy) {
      return const Failure('This person is not my partner.');
    }

    final key = '$year:$npcId:$action';
    final times = progress.interactionCounts[key] ?? 0;

    // Getting intimate counts twice a year. Everything else, once.
    final first = action == 'Have Sex' ? times < 2 : times == 0;
    final counts = {
      for (final entry in progress.interactionCounts.entries)
        if (entry.key.startsWith('$year:')) entry.key: entry.value,
      key: times + 1,
    };

    if (action == 'Break Up') {
      if (love.isMarried) {
        return const Failure(
          'We are married. The only way out is a divorce.',
        );
      }

      // The relationship collapses, and they move to the Exes page.
      final engaged = love.stage == LoveRules.stageEngaged;
      final kind = engaged ? BreakupKind.engagement : BreakupKind.breakup;
      final next = (score - 70).clamp(-100, 100).toInt();
      final broken = _scored(
        progress.copyWith(
          love: love.copyWith(
            clearPartner: true,
            exIds: {...love.exIds, npcId},
          ),
        ),
        npcId,
        next,
      );
      final updated = broken.copyWith(
        flags: {...broken.flags}
          ..remove(SystemFlags.engaged),
      );
      final story = BreakupNarratives.story(
        _random,
        name,
        kind: kind,
        cause: BreakupCause.iEndedIt,
      );
      final drop = _breakupDrop(love, kind, BreakupCause.iEndedIt);

      _enqueueBreakup(
        npcId: npcId,
        name: name,
        gender: person.gender,
        kind: kind,
        cause: BreakupCause.iEndedIt,
        story: story,
        middle: _breakupDurations(love, kind),
        drop: drop,
        scoreBefore: score,
        scoreAfter: next,
      );

      return _socialOutcome(
        npcId: npcId,
        action: action,
        narrative: story,
        score: next,
        bond: 'ex',
        next: withStats(
          _state.copyWith(lifeProgress: updated),
          happiness: -drop,
        ),
      );
    }

    if (action == 'Birth Control') {
      if (person.gender != Gender.female ||
          !LoveRules.canBeIntimate(playerAge, age)) {
        return const Failure('Birth control is not an option here.');
      }

      final on = love.birthControl.contains(npcId);
      final set = {...love.birthControl};

      if (on) {
        set.remove(npcId);
      } else {
        set.add(npcId);
      }

      return _socialOutcome(
        npcId: npcId,
        action: action,
        narrative: on
            ? '$name stopped using birth control. We are leaving things to '
                'fate now.'
            : '$name and I talked it through, and $name started using birth '
                'control. A grown-up decision, handled calmly.',
        score: score,
        bond: 'friend',
        romance: 'partner',
        next: _state.copyWith(
          lifeProgress: progress.copyWith(
            love: love.copyWith(birthControl: set),
          ),
        ),
      );
    }

    if (action == NpcInteractionOutcome.pregnancyKeep ||
        action == NpcInteractionOutcome.pregnancyEnd) {
      final waiting = love.pregnancy;

      if (waiting == null) return const Failure('There is no pregnancy.');

      final keep = action == NpcInteractionOutcome.pregnancyKeep;

      return _socialOutcome(
        npcId: npcId,
        action: action,
        narrative: keep
            ? 'We decided to keep the baby. Scared, excited, and ready to '
                'learn everything.'
            : 'We made the hard decision not to continue the pregnancy. It '
                'hurt, and we held each other through it.',
        score: score,
        bond: 'friend',
        romance: love.partnerId == npcId ? 'partner' : 'none',
        next: withStats(
          _state.copyWith(
            lifeProgress: progress.copyWith(
              love: keep
                  ? love.copyWith(pregnancy: waiting.copyWith(decided: true))
                  : love.copyWith(clearPregnancy: true),
            ),
          ),
          happiness: keep ? 2 : -8,
        ),
      );
    }

    var narrative = '';
    var next = score;
    var pregnancy = love.pregnancy;
    var asksAboutBaby = false;

    if (action == 'Go on a Date') {
      narrative = LoveNarratives.date(_random, name);
      next = first ? (score + 6).clamp(-100, 100).toInt() : score;
    } else {
      // Have Sex
      if (!LoveRules.canBeIntimate(playerAge, age)) {
        return const Failure('We are not old enough for that.');
      }

      if (score < LoveRules.intimacyAt) {
        return const Failure('We are not close enough for that yet.');
      }

      narrative = LoveNarratives.intimate(_random, name);
      next = first ? (score + 4).clamp(-100, 100).toInt() : score;

      if (first && pregnancy == null) {
        final player = _state.player;
        final mine = Fertility.effective(
          player.stats.fertility,
          playerAge,
          player.gender,
        );
        final theirs = NpcTraits.forPerson(
          id: person.id,
          gender: person.gender,
          birthYear: person.birthYear,
          currentYear: year,
        ).fertility;
        final canConceive = player.gender != person.gender;

        if (!canConceive) {
          narrative = '$narrative ${LoveNarratives.noBaby(name)}';
        } else {
          var chance = (mine * theirs / 100 * 0.6).round();

          final protected = love.birthControl.contains(npcId) ||
              (player.gender == Gender.female &&
                  love.birthControl.contains(player.id));

          if (protected) chance = chance ~/ 10;

          if (_random.nextInt(100) < chance) {
            pregnancy = Pregnancy(conceivedYear: year, partner: person);
            asksAboutBaby = true;
            narrative =
                '$narrative ${LoveNarratives.pregnancy(playerCarries: player.gender == Gender.female, name: name)}';
          }
        }
      }
    }

    final updated = _scored(
      progress.copyWith(
        interactionCounts: counts,
        love: pregnancy == love.pregnancy
            ? love
            : love.copyWith(pregnancy: pregnancy),
      ),
      npcId,
      next,
    );

    return _socialOutcome(
      npcId: npcId,
      action: action,
      narrative: narrative,
      score: next,
      bond: 'friend',
      romance: 'partner',
      progressed: first,
      prompt: asksAboutBaby ? 'pregnancy' : null,
      next: withStats(
        _state.copyWith(lifeProgress: updated),
        happiness: first ? 3 : 0,
      ),
    );
  }

  Result<NpcInteractionOutcome> _childInteraction(
    String childId,
    String action,
  ) {
    const changes = {
      'Talk': 2,
      'Spend Time': 5,
      'Compliment': 3,
      'Help': 4,
      'Argue': -8,
      'Apologize': 4,
      'Play': 3,
    };
    final change = changes[action];

    if (change == null) return const Failure('Unknown interaction.');

    final year = _state.clock.currentYear;
    final progress = _state.lifeProgress;
    final children = List.of(progress.love.children);
    final index = children.indexWhere((child) => child.id == childId);

    if (index < 0) return const Failure('I cannot find my child.');

    final child = children[index];
    final isBaby = year - child.birthYear <= 2;

    if (isBaby && action != 'Play') {
      return const Failure('A baby can only play.');
    }

    if (!isBaby && action == 'Play') {
      return const Failure('My child is too big for that.');
    }
    final key = '$year:$childId:$action';
    final times = progress.interactionCounts[key] ?? 0;
    final first = times == 0;
    final score = first
        ? (child.relationshipPercent + change).clamp(-100, 100).toInt()
        : child.relationshipPercent;

    children[index] = child.copyWith(relationshipPercent: score);

    final mood = !first
        ? 0
        : switch (action) {
            'Spend Time' || 'Apologize' || 'Play' => 1,
            'Argue' => -2,
            _ => 0,
          };

    return _socialOutcome(
      npcId: childId,
      action: action,
      narrative: LoveNarratives.child(_random, action, child.firstName),
      score: score,
      bond: 'child',
      progressed: first,
      next: _state.copyWith(
        player: _state.player.copyWith(
          stats: _state.player.stats.copyWith(
            happiness: _state.player.stats.happiness + mood,
          ),
        ),
        lifeProgress: progress.copyWith(
          love: progress.love.copyWith(children: children),
          interactionCounts: {
            for (final entry in progress.interactionCounts.entries)
              if (entry.key.startsWith('$year:')) entry.key: entry.value,
            key: times + 1,
          },
        ),
      ),
    );
  }

  /// Only an adult woman has her own birth control switch.
  bool get playerCanUseBirthControl =>
      _state.player.gender == Gender.female &&
      _state.clock.currentYear - _state.player.birthYear >=
          LoveRules.adultAge;

  bool get playerOnBirthControl =>
      _state.lifeProgress.love.birthControl.contains(_state.player.id);

  /// Turns the player's own birth control on or off.
  Result<String> setPlayerBirthControl({required bool on}) {
    if (!playerCanUseBirthControl) {
      return const Failure('Birth control is not available right now.');
    }

    final progress = _state.lifeProgress;
    final set = {...progress.love.birthControl};

    if (on) {
      set.add(_state.player.id);
    } else {
      set.remove(_state.player.id);
    }

    final text = on
        ? 'I started using birth control. My body, my plan.'
        : 'I stopped using birth control and left the future open.';
    final year = _state.clock.currentYear;
    final result = _commit(
      _state.copyWith(
        lifeProgress: progress.copyWith(
          love: progress.love.copyWith(birthControl: set),
        ),
        events: [
          ..._state.events,
          SimulationEvent(
            id: 'birth-control-${_state.events.length + 1}-$year',
            type: SimulationEventType.npcInteraction,
            year: year,
            title: on ? 'Started birth control' : 'Stopped birth control',
            description: text,
          ),
        ],
      ),
    );

    return result.isSuccess ? Success(text) : Failure('Could not save that.');
  }


  static const String _hideDeceasedFlag = 'ui_hide_deceased';

  /// Whether the Life page hides family who have died.
  bool get hideDeceased => _state.lifeProgress.hasFlag(_hideDeceasedFlag);

  void setHideDeceased({required bool hide}) {
    final progress = _state.lifeProgress;
    final flags = {...progress.flags};

    if (hide) {
      flags.add(_hideDeceasedFlag);
    } else {
      flags.remove(_hideDeceasedFlag);
    }

    _commit(_state.copyWith(lifeProgress: progress.copyWith(flags: flags)));
  }

  String get _everyoneKey => '${_state.clock.currentYear}:everyone:all';

  /// True until the player has spent time with everyone this year.
  bool get canSpendTimeWithEveryone =>
      (_state.lifeProgress.interactionCounts[_everyoneKey] ?? 0) == 0;

  /// Spends time with every person on the Life page (parents, siblings,
  /// partner, friends and children), once a year. The life log gets one
  /// combined entry instead of one per person.
  Result<String> spendTimeWithEveryone() {
    if (!canSpendTimeWithEveryone) {
      return const Failure('I already spent time with everyone this year.');
    }

    final year = _state.clock.currentYear;
    final playerStage = LifeStageAge.fromAge(
      (year - _state.player.birthYear).clamp(0, 150).toInt(),
    );
    final household = _state.familyHousehold;
    final love = _state.lifeProgress.love;
    final targets = <(String, int)>[
      if (household != null) ...[
        for (final parent in household.parents)
          if (parent.isAlive) (parent.id, parent.birthYear),
        for (final sibling in household.siblings)
          if (sibling.isAlive && sibling.birthYear <= year)
            (sibling.id, sibling.birthYear),
      ],
      for (final friend in _state.lifeProgress.friends)
        if (!love.exIds.contains(friend.id)) (friend.id, friend.birthYear),
      for (final child in love.children) (child.id, child.birthYear),
    ];
    final eventsBefore = _state.events.length;
    var met = 0;

    for (final (id, birthYear) in targets) {
      final baby = year - birthYear <= 2;
      final action = baby || playerStage == LifeStage.infant
          ? 'Play'
          : 'Spend Time';

      if (interactWithNpc(npcId: id, action: action).isSuccess) met++;
    }

    if (met == 0) return const Failure('There is nobody to spend time with.');

    final text = InfantNarratives.togetherWithAll(_random, met);
    final progress = _state.lifeProgress;
    final result = _commit(
      _state.copyWith(
        events: [
          // One entry for the whole round, not one per person.
          ..._state.events.take(eventsBefore),
          SimulationEvent(
            id: 'spend-all-$year-${eventsBefore + 1}',
            type: SimulationEventType.npcInteraction,
            year: year,
            title: 'Time with everyone',
            description: text,
          ),
        ],
        lifeProgress: progress.copyWith(
          interactionCounts: {
            ...progress.interactionCounts,
            _everyoneKey: 1,
          },
        ),
      ),
    );

    return result.isSuccess ? Success(text) : const Failure('Could not save that.');
  }

  ChildNpc? _newborn;

  /// The baby born at the last birthday, once. The screen announces it.
  ChildNpc? takeNewborn() {
    final baby = _newborn;

    _newborn = null;

    return baby;
  }

  /// Relationships fade when nobody keeps them up. Anyone I did not
  /// interact with last year loses a few points. It uses no dice, so saved
  /// games and tests stay predictable.
  void _decayRelationships() {
    final year = _state.clock.currentYear;
    final playerAge = year - _state.player.birthYear;

    if (playerAge <= 5) return;

    final progress = _state.lifeProgress;
    final counts = progress.interactionCounts;
    final prefix = '${year - 1}:';
    final love = progress.love;

    bool contacted(String id) => counts.keys.any(
          (key) => key.startsWith('$prefix$id:'),
        );

    int salt(String id) {
      var h = year;

      for (final unit in id.codeUnits) {
        h = (h * 31 + unit) & 0x7fffffff;
      }

      return h;
    }

    int lose(String id, int base, int span) =>
        base + salt(id) % span;

    // New score, or null when nothing changes.
    int? decayed(String id, int score, int birthYear, int base, int span) {
      if (year - birthYear <= 2 || contacted(id) || score <= 0) return null;

      return (score - lose(id, base, span)).clamp(0, 100).toInt();
    }

    final drifted = <String>[];
    final household = _state.familyHousehold;
    var nextHousehold = household;

    if (household != null) {
      nextHousehold = household.copyWith(
        parents: [
          for (final parent in household.parents)
            if (parent.isAlive)
              _fade(
                parent,
                decayed(parent.id, parent.relationshipPercent,
                    parent.birthYear, 2, 3),
                drifted,
              )
            else
              parent,
        ],
        siblings: [
          for (final sibling in household.siblings)
            if (sibling.isAlive && sibling.birthYear <= year)
              _fade(
                sibling,
                decayed(sibling.id, sibling.relationshipPercent,
                    sibling.birthYear, 2, 3),
                drifted,
              )
            else
              sibling,
        ],
      );
    }

    SchoolNpc fadePerson(SchoolNpc npc) {
      if (love.exIds.contains(npc.id)) return npc;

      final partner = love.partnerId == npc.id;
      final next = decayed(
        npc.id,
        npc.relationshipPercent,
        npc.birthYear,
        partner ? 4 : 3,
        partner ? 5 : 4,
      );

      if (next == null) return npc;

      if (npc.relationshipPercent >= 40 && next < 40) {
        if (!drifted.contains(npc.fullName)) drifted.add(npc.fullName);
      }

      return npc.copyWith(relationshipPercent: next);
    }

    final friends = [for (final f in progress.friends) fadePerson(f)];
    final classmates = [
      for (final npc in progress.education.npcs) fadePerson(npc),
    ];
    final children = [
      for (final child in love.children)
        () {
          final next = decayed(
            child.id,
            child.relationshipPercent,
            child.birthYear,
            2,
            3,
          );

          return next == null
              ? child
              : child.copyWith(relationshipPercent: next);
        }(),
    ];
    final events = <SimulationEvent>[..._state.events];

    if (drifted.isNotEmpty) {
      final names = drifted.take(2).join(' and ');

      events.add(
        SimulationEvent(
          id: 'drift-${events.length + 1}-$year',
          type: SimulationEventType.npcInteraction,
          year: year,
          title: 'Drifting apart',
          description: RelationshipNarratives.drift(salt(names), names),
        ),
      );
    }

    _commit(
      _state.copyWith(
        familyHousehold: nextHousehold,
        events: events,
        lifeProgress: progress.copyWith(
          friends: friends,
          education: progress.education.copyWith(npcs: classmates),
          love: love.copyWith(children: children),
        ),
      ),
    );
  }

  T _fade<T>(T npc, int? next, List<String> drifted) {
    if (next == null) return npc;

    if (npc is ParentNpc) {
      if (npc.relationshipPercent >= 40 && next < 40) {
        if (!drifted.contains(npc.fullName)) drifted.add(npc.fullName);
      }

      return npc.copyWith(relationshipPercent: next) as T;
    }

    if (npc is SiblingNpc) {
      if (npc.relationshipPercent >= 40 && next < 40) {
        if (!drifted.contains(npc.fullName)) drifted.add(npc.fullName);
      }

      return npc.copyWith(relationshipPercent: next) as T;
    }

    return npc;
  }

  /// Gives birth to a baby conceived in an earlier year.
  void _resolvePregnancy() {
    final progress = _state.lifeProgress;
    final pregnancy = progress.love.pregnancy;
    final year = _state.clock.currentYear;

    if (pregnancy == null || year <= pregnancy.conceivedYear) return;

    final player = _state.player;
    final other = pregnancy.partner;
    final genes = Genetics.inherit(
      _random,
      _playerGenes(),
      _genesOf(other),
    );
    final gender = _random.nextInt(2) == 0 ? Gender.male : Gender.female;
    final country = player.location?.countryCode ?? other.countryCode;
    final suggestions = _suggestNames(country, gender);
    final father = player.gender == Gender.male ? player : null;
    final lastName = father != null
        ? player.resolvedLastName
        : other.lastName;
    final baby = ChildNpc(
      id: 'child-$year-${progress.love.children.length + 1}',
      firstName: suggestions.first,
      lastName: lastName,
      gender: gender,
      birthYear: year,
      looks: genes.looks,
      smarts: genes.smarts,
      fertilityBase: genes.fertility,
      skinTone: genes.skinTone,
      hairColor: genes.hairColor,
      eyeColor: genes.eyeColor,
      eyebrows: genes.eyebrows,
      countryCode: country,
      otherParentName: other.fullName,
    );
    final text = LoveNarratives.birth(
      childName: baby.fullName,
      gender: gender,
      otherParent: other.firstName,
    );
    final next = _state.copyWith(
      player: player.copyWith(
        stats: player.stats.copyWith(happiness: player.stats.happiness + 10),
      ),
      lifeProgress: progress.copyWith(
        love: progress.love.copyWith(
          clearPregnancy: true,
          children: [...progress.love.children, baby],
        ),
      ),
      events: [
        ..._state.events,
        SimulationEvent(
          id: 'birth-$year-${baby.id}',
          type: SimulationEventType.npcInteraction,
          year: year,
          title: 'Baby born',
          description: text,
        ),
      ],
    );

    if (_commit(next) case Success<void>()) {
      _newborn = baby;
      _newbornNames = suggestions;
    }
  }

  List<String> _newbornNames = const <String>[];

  /// Names the other parent recommends for the newborn, from the country's
  /// own name pool.
  List<String> get newbornNameSuggestions => _newbornNames;

  List<String> _suggestNames(String countryCode, Gender gender) {
    final names = <String>[];

    for (var i = 0; i < 40 && names.length < 3; i++) {
      final name = CulturalRandomizerCatalog.randomFirstName(
        countryCode: countryCode,
        gender: gender,
        random: math.Random(_random.nextInt(0x3fffffff)),
      );

      if (!names.contains(name)) names.add(name);
    }

    return names;
  }

  /// One more culturally fitting name for the dice button.
  String randomNameFor(ChildNpc baby) => _suggestNames(
        baby.countryCode,
        baby.gender,
      ).first;

  /// Sets the baby's first name.
  Result<void> nameChild(String childId, String name) {
    final clean = name.trim();

    if (clean.isEmpty) return const Failure('A baby needs a name.');

    if (clean.length > 20) return const Failure('That name is too long.');

    final progress = _state.lifeProgress;
    final children = [
      for (final child in progress.love.children)
        child.id == childId ? child.copyWith(firstName: clean) : child,
    ];

    final found = children.where((child) => child.id == childId);

    if (found.isEmpty) return const Failure('I cannot find this child.');

    final named = found.first;

    return _commit(
      _state.copyWith(
        lifeProgress: progress.copyWith(
          love: progress.love.copyWith(children: children),
        ),
        events: [
          ..._state.events,
          SimulationEvent(
            id: 'child-named-${_state.events.length + 1}-$childId',
            type: SimulationEventType.npcInteraction,
            year: _state.clock.currentYear,
            title: 'Baby named',
            description: 'We named our baby ${named.fullName}.',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ Milestones
  //
  // Engagement, marriage (with a prenup) and divorce. The pop-ups live in
  // the NPC screen; these methods hold the rules.

  /// Money in the player's own currency for the pop-ups ("$300").
  String costLabel(int costBase) {
    if (costBase == 0) return 'Free';

    return MoneyText.of(
      _state,
      LifeEffectApplier.scaleMoney(_state, costBase.abs()),
    );
  }

  /// A varied scene for the milestone pop-up: 'engage', 'prenup', 'wedding'
  /// or 'divorce'.
  String milestoneScene(String kind, String npcId) {
    final name = _personById(npcId)?.fullName ?? 'my partner';

    return switch (kind) {
      'engage' => MarriageNarratives.proposalScene(_random, name),
      'prenup' => MarriageNarratives.prenupScene(_random, name),
      'wedding' => MarriageNarratives.weddingScene(_random, name),
      _ => MarriageNarratives.divorceScene(_random, name),
    };
  }

  /// Years since the current stage began.
  int _yearsInStage(LoveState love) {
    final since = love.stageSince ?? love.partnerSince;

    return since == null ? 0 : _state.clock.currentYear - since;
  }

  int _ageOf(SchoolNpc person) =>
      _state.clock.currentYear - person.birthYear;

  /// Whether the player may propose to [npcId] right now.
  bool canGetEngaged(String npcId) {
    final love = _state.lifeProgress.love;
    final person = _personById(npcId);

    if (person == null || love.partnerId != npcId) return false;

    final year = _state.clock.currentYear;

    return love.stage == LoveRules.stageDating &&
        LoveRules.canBeIntimate(
          year - _state.player.birthYear,
          _ageOf(person),
        ) &&
        _yearsInStage(love) >= LoveRules.yearsBeforeEngagement &&
        person.relationshipPercent >= LoveRules.engageAt &&
        (_state.lifeProgress.interactionCounts['$year:$npcId:Get Engaged'] ??
                0) ==
            0;
  }

  /// Whether the player may marry [npcId] right now.
  bool canGetMarried(String npcId) {
    final love = _state.lifeProgress.love;
    final person = _personById(npcId);

    if (person == null || love.partnerId != npcId) return false;

    return love.stage == LoveRules.stageEngaged &&
        _yearsInStage(love) >= LoveRules.yearsBeforeWedding &&
        person.relationshipPercent >= LoveRules.marryAt;
  }

  bool canDivorce(String npcId) {
    final love = _state.lifeProgress.love;

    return love.isMarried && love.partnerId == npcId;
  }

  /// Whether my cash covers [costBase] (a negative baseline amount). Big
  /// purchases are never put on credit.
  bool canAfford(int costBase) =>
      costBase >= 0 ||
      _state.player.money.minorUnits >=
          LifeEffectApplier.scaleMoney(_state, costBase).abs();

  WorldState _spend(WorldState state, int costBase) {
    if (costBase == 0) return state;

    return LifeEffectApplier.applyOutcome(
      state: state,
      outcome: LifeOutcome(text: '', moneyBase: costBase),
    );
  }

  /// Moves [minorUnits] (negative pays) with debt if cash runs out.
  WorldState _moveMoney(WorldState state, int minorUnits) {
    if (minorUnits == 0) return state;

    var money = state.player.money.minorUnits;
    var debt = state.player.debt.minorUnits;

    if (minorUnits > 0) {
      money += minorUnits;
    } else if (money >= -minorUnits) {
      money += minorUnits;
    } else {
      debt += -minorUnits - money;
      money = 0;
    }

    return state.copyWith(
      player: state.player.copyWith(
        money: Money.fromMinorUnits(money),
        debt: Money.fromMinorUnits(debt),
      ),
    );
  }

  WorldState _happier(WorldState state, int happiness) => state.copyWith(
        player: state.player.copyWith(
          stats: state.player.stats.copyWith(
            happiness: state.player.stats.happiness + happiness,
          ),
        ),
      );

  /// "Get Engaged": [ringId] is picked from [LoveRules.rings].
  Result<NpcInteractionOutcome> proposeEngagement({
    required String npcId,
    required String ringId,
  }) {
    final person = _personById(npcId);
    final ring = LoveRules.option(LoveRules.rings, ringId);

    if (person == null || ring == null) {
      return const Failure('I cannot find this person.');
    }

    if (!canGetEngaged(npcId)) {
      return const Failure(
        'It is too soon to propose. We need more time together.',
      );
    }

    if (!canAfford(ring.costBase)) {
      return const Failure('I cannot afford this ring.');
    }

    final year = _state.clock.currentYear;
    final progress = _state.lifeProgress;
    final chance =
        (person.relationshipPercent - 5 + ring.bonus).clamp(25, 100).toInt();
    final yes = _random.nextInt(100) < chance;
    final counts = {
      for (final entry in progress.interactionCounts.entries)
        if (entry.key.startsWith('$year:')) entry.key: entry.value,
      '$year:$npcId:Get Engaged': 1,
    };
    final their = person.gender == Gender.female ? 'her' : 'his';

    if (!yes) {
      final score = (person.relationshipPercent - 12).clamp(-100, 100).toInt();
      final updated = _scored(
        progress.copyWith(interactionCounts: counts),
        npcId,
        score,
      );

      return _socialOutcome(
        npcId: npcId,
        action: 'Get Engaged',
        narrative: '${MarriageNarratives.declined(_random, person.fullName)} '
            'I kept the ring. Maybe next year.',
        score: score,
        bond: 'friend',
        romance: 'partner',
        next: _happier(_state.copyWith(lifeProgress: updated), -6),
      );
    }

    final score = (person.relationshipPercent + 10).clamp(-100, 100).toInt();
    final scored = _scored(
      progress.copyWith(
        interactionCounts: counts,
        flags: {...progress.flags, SystemFlags.engaged},
        love: progress.love.copyWith(
          stage: LoveRules.stageEngaged,
          stageSince: year,
        ),
      ),
      npcId,
      score,
    );
    final paid = _spend(_state.copyWith(lifeProgress: scored), ring.costBase);
    final cost = ring.costBase == 0 ? '' : ' (${costLabel(ring.costBase)})';

    return _socialOutcome(
      npcId: npcId,
      action: 'Get Engaged',
      narrative: '${MarriageNarratives.accepted(
        _random,
        person.fullName,
        their,
      )} I bought the ${ring.label.toLowerCase()}$cost.',
      score: score,
      bond: 'friend',
      romance: 'partner',
      next: _happier(paid, 8),
    );
  }

  /// "Get Married": [prenupId] from [LoveRules.prenups] and [weddingId]
  /// from [LoveRules.weddings].
  Result<NpcInteractionOutcome> marry({
    required String npcId,
    required String prenupId,
    required String weddingId,
  }) {
    final person = _personById(npcId);
    final prenup = LoveRules.option(LoveRules.prenups, prenupId);
    final wedding = LoveRules.option(LoveRules.weddings, weddingId);

    if (person == null || prenup == null || wedding == null) {
      return const Failure('I cannot find this person.');
    }

    if (!canGetMarried(npcId)) {
      return const Failure(
        'We are not ready to marry yet. We need more time as a couple.',
      );
    }

    if (!canAfford(prenup.costBase + wedding.costBase)) {
      return const Failure('I cannot afford this wedding.');
    }

    final year = _state.clock.currentYear;
    final progress = _state.lifeProgress;
    final score = (person.relationshipPercent + 12 + prenup.relation)
        .clamp(-100, 100)
        .toInt();
    final flags = {...progress.flags, SystemFlags.married}
      ..remove(SystemFlags.engaged);
    final scored = _scored(
      progress.copyWith(
        flags: flags,
        love: progress.love.copyWith(
          stage: LoveRules.stageMarried,
          stageSince: year,
          prenup: prenup.id,
        ),
      ),
      npcId,
      score,
    );
    final paid = _spend(
      _spend(_state.copyWith(lifeProgress: scored), wedding.costBase),
      prenup.costBase,
    );
    final prenupNote = switch (prenup.id) {
      'none' => ' We signed nothing but the marriage certificate.',
      'fair' => ' The prenup was signed without drama.',
      _ => ' ${person.firstName} signed the ironclad prenup with a very '
          'tight smile.',
    };

    return _socialOutcome(
      npcId: npcId,
      action: 'Get Married',
      narrative: '${MarriageNarratives.wedded(
        _random,
        wedding.id,
        person.fullName,
      )}$prenupNote',
      score: score,
      bond: 'friend',
      romance: 'partner',
      next: _happier(paid, wedding.happiness),
    );
  }

  /// What a divorce would cost right now, in plain words.
  String divorcePreview(String npcId) {
    final terms = _divorceTerms(playerFiles: true);
    final prenup = LoveRules.option(
      LoveRules.prenups,
      _state.lifeProgress.love.prenup ?? 'none',
    );
    final cash = _state.player.money.minorUnits;
    final share = cash > 0 ? cash * terms.sharePct ~/ 100 : 0;

    return 'Without clear grounds I pay a fine to my spouse '
        '(${MoneyText.of(_state, -terms.fine)}). '
        '${prenup?.label ?? 'No prenup'}: my spouse takes '
        '${terms.sharePct}% of my cash '
        '(${MoneyText.of(_state, share)}).';
  }

  /// Share of my cash and the fine for a divorce. A positive [fine] is paid
  /// to me (my spouse filed with no reason), a negative one is paid by me.
  ({int sharePct, int fine}) _divorceTerms({required bool playerFiles}) {
    final love = _state.lifeProgress.love;
    final prenupShare =
        LoveRules.option(LoveRules.prenups, love.prenup ?? 'none')?.share ??
            50;
    final cash = _state.player.money.minorUnits;
    final amount = LifeEffectApplier.scaleMoney(_state, 500000);
    final fine = cash * 10 ~/ 100 > amount ? cash * 10 ~/ 100 : amount;

    return (sharePct: prenupShare, fine: playerFiles ? -fine : fine);
  }

  /// How hurt I am when a dating or engagement relationship ends.
  int _breakupDrop(LoveState love, BreakupKind kind, BreakupCause cause) {
    final year = _state.clock.currentYear;

    return _heartbreak(
      years: year - (love.partnerSince ?? year),
      children: love.children.length,
      cause: cause,
      kind: kind,
    );
  }

  /// "Together for" (and "Engaged for") facts of a dating or engagement
  /// that ended.
  List<MapEntry<String, String>> _breakupDurations(
    LoveState love,
    BreakupKind kind,
  ) {
    final year = _state.clock.currentYear;

    return [
      MapEntry('Together for', _yearsText(year - (love.partnerSince ?? year))),
      if (kind == BreakupKind.engagement)
        MapEntry(
          'Engaged for',
          _yearsText(year - (love.stageSince ?? year)),
        ),
    ];
  }

  static String _yearsText(int years) => years <= 0
      ? 'Less than a year'
      : years == 1
          ? '1 year'
          : '$years years';

  /// How much an ending hurts: longer relationships, children and being
  /// left hurt more.
  int _heartbreak({
    required int years,
    required int children,
    required BreakupCause cause,
    required BreakupKind kind,
  }) {
    var drop = switch (kind) {
      BreakupKind.divorce => 6,
      BreakupKind.engagement => 5,
      BreakupKind.breakup => 3,
    };

    drop += years.clamp(0, 12) ~/ 2;
    drop += children.clamp(0, 4).toInt();
    drop += switch (cause) {
      BreakupCause.iEndedIt => 0,
      BreakupCause.theyLeftNoReason => 3,
    };

    return drop < 2 ? 2 : drop;
  }

  String _causeText(BreakupCause cause, String name, BreakupKind kind) =>
      switch (cause) {
        BreakupCause.iEndedIt =>
          kind == BreakupKind.divorce ? 'I filed for divorce' : 'I ended it',
        BreakupCause.theyLeftNoReason => '$name left, no reason given',
      };

  /// Queues the overlay for an ending. [middle] holds the facts that depend
  /// on the kind of ending (how long, money, children).
  void _enqueueBreakup({
    required String npcId,
    required String name,
    required Gender gender,
    required BreakupKind kind,
    required BreakupCause cause,
    required String story,
    required List<MapEntry<String, String>> middle,
    required int drop,
    required int scoreBefore,
    required int scoreAfter,
  }) {
    _breakups.add(
      BreakupSummary(
        npcId: npcId,
        name: name,
        kind: kind,
        title: BreakupNarratives.title(_random, kind),
        story: story,
        quip: BreakupNarratives.quip(_random, kind),
        facts: [
          MapEntry('Why', _causeText(cause, name, kind)),
          ...middle,
          MapEntry('Happiness', '-$drop'),
          MapEntry(
            'Now',
            LoveRules.exLabel(
              gender,
              wasSpouse: kind == BreakupKind.divorce,
            ),
          ),
          MapEntry(
            'Relationship',
            '$scoreBefore% \u2192 $scoreAfter%, moved to Exes',
          ),
        ],
      ),
    );
  }

  /// Ends the marriage with [npcId]. Returns the new state and the story.
  /// The overlay for it is queued (see [takeBreakup]).
  (WorldState, String) _endMarriage({
    required String npcId,
    required bool playerFiles,
  }) {
    final person = _personById(npcId);
    final name = person?.fullName ?? 'my spouse';
    final terms = _divorceTerms(playerFiles: playerFiles);
    final year = _state.clock.currentYear;
    final cash = _state.player.money.minorUnits;
    final share = cash > 0 ? cash * terms.sharePct ~/ 100 : 0;
    final progress = _state.lifeProgress;
    final love = progress.love;
    final flags = {...progress.flags, SystemFlags.divorced}
      ..removeAll(const [
        SystemFlags.married,
        SystemFlags.divorceFiledUnclear,
      ]);
    final cause =
        playerFiles ? BreakupCause.iEndedIt : BreakupCause.theyLeftNoReason;
    final married = year - (love.stageSince ?? love.partnerSince ?? year);
    final total = year - (love.partnerSince ?? year);
    final children = love.children.length;
    final before = person?.relationshipPercent ?? 0;
    final prenup = LoveRules.option(LoveRules.prenups, love.prenup ?? 'none');
    final scored = _scored(
      progress.copyWith(
        flags: flags,
        love: love.copyWith(
          clearPartner: true,
          divorced: true,
          exIds: {...love.exIds, npcId},
          exSpouseIds: {...love.exSpouseIds, npcId},
        ),
      ),
      npcId,
      0,
    );
    final drop = _heartbreak(
      years: married,
      children: children,
      cause: cause,
      kind: BreakupKind.divorce,
    );
    var next = _moveMoney(
      _state.copyWith(lifeProgress: scored),
      -share + terms.fine,
    );

    next = _happier(next, -drop);

    final scene = BreakupNarratives.story(
      _random,
      name,
      kind: BreakupKind.divorce,
      cause: cause,
    );
    final parts = <String>[scene];

    if (share > 0) {
      parts.add(
        'Under the prenup rules my ex took ${terms.sharePct}% of my cash '
        '(${MoneyText.of(_state, share)}).',
      );
    } else if (love.prenup != null || terms.sharePct == 0) {
      parts.add('There was nothing to split.');
    }

    if (terms.fine < 0) {
      parts.add(
        'There were no clear grounds, so I paid my ex a fine of '
        '${MoneyText.of(_state, -terms.fine)}.',
      );
    } else if (terms.fine > 0) {
      parts.add(
        'My ex left without a clear reason, so they paid me a fine of '
        '${MoneyText.of(_state, terms.fine)}.',
      );
    }

    final borrowed =
        next.player.debt.minorUnits > _state.player.debt.minorUnits;

    if (borrowed) {
      parts.add('I had to borrow money to cover it.');
    }

    _enqueueBreakup(
      npcId: npcId,
      name: name,
      gender: person?.gender ?? Gender.male,
      kind: BreakupKind.divorce,
      cause: cause,
      story: scene,
      middle: [
        MapEntry('Married for', _yearsText(married)),
        if (total > married) MapEntry('Together in total', _yearsText(total)),
        MapEntry('Children', children == 0 ? 'None' : '$children'),
        MapEntry('Prenup', prenup?.label ?? 'None'),
        MapEntry(
          'Property split',
          share > 0
              ? '${terms.sharePct}% of my cash (${MoneyText.of(_state, share)})'
              : 'Nothing to split',
        ),
        MapEntry(
          'Fine',
          terms.fine < 0
              ? 'I paid ${MoneyText.of(_state, -terms.fine)}'
              : terms.fine > 0
                  ? '$name paid me ${MoneyText.of(_state, terms.fine)}'
                  : 'None',
        ),
        MapEntry(
          'Cash left',
          '${MoneyText.of(next, next.player.money.minorUnits)}'
              '${borrowed ? ' (I had to borrow)' : ''}',
        ),
      ],
      drop: drop,
      scoreBefore: before,
      scoreAfter: 0,
    );

    return (next, parts.join(' '));
  }

  /// "Divorce": I file for divorce.
  Result<NpcInteractionOutcome> divorce({required String npcId}) {
    if (!canDivorce(npcId)) {
      return const Failure('I am not married to this person.');
    }

    final (next, story) = _endMarriage(npcId: npcId, playerFiles: true);

    return _socialOutcome(
      npcId: npcId,
      action: 'Divorce',
      narrative: story,
      score: 0,
      bond: 'ex',
      next: next,
    );
  }

  /// Getting intimate with someone who is not my partner. Only possible
  /// while I am single.
  Result<NpcInteractionOutcome> _hookUp(String npcId, SchoolNpc person) {
    final year = _state.clock.currentYear;
    final playerAge = year - _state.player.birthYear;
    final progress = _state.lifeProgress;
    final love = progress.love;
    final age = year - person.birthYear;
    final name = person.fullName;
    final score = person.relationshipPercent;

    if (!person.role.isStudent) {
      return const Failure('I cannot get intimate with this person.');
    }

    if (love.hasPartner) {
      return const Failure(
        'I already have a partner. I am only intimate with them.',
      );
    }

    if (!LoveRules.canBeIntimate(playerAge, age)) {
      return const Failure('We are not old enough for that.');
    }

    if (score < LoveRules.hookUpAt) {
      return const Failure('We are not close enough for that.');
    }

    final key = '$year:$npcId:Have Sex';
    final times = progress.interactionCounts[key] ?? 0;
    final effective = times < 2;
    final counts = {
      for (final entry in progress.interactionCounts.entries)
        if (entry.key.startsWith('$year:')) entry.key: entry.value,
      key: times + 1,
    };
    var narrative = RelationshipNarratives.hookUp(_random, name);
    var next = score;
    var pregnancy = love.pregnancy;
    var asksAboutBaby = false;

    if (effective) {
      next = (score + 3).clamp(-100, 100).toInt();

      final player = _state.player;

      if (pregnancy == null && player.gender != person.gender) {
        final mine = Fertility.effective(
          player.stats.fertility,
          playerAge,
          player.gender,
        );
        final theirs = NpcTraits.forPerson(
          id: person.id,
          gender: person.gender,
          birthYear: person.birthYear,
          currentYear: year,
        ).fertility;
        var chance = (mine * theirs / 100 * 0.6).round();
        final protected = love.birthControl.contains(npcId) ||
            (player.gender == Gender.female &&
                love.birthControl.contains(player.id));

        if (protected) chance = chance ~/ 10;

        if (_random.nextInt(100) < chance) {
          pregnancy = Pregnancy(conceivedYear: year, partner: person);
          asksAboutBaby = true;
          narrative = '$narrative ${LoveNarratives.pregnancy(
            playerCarries: player.gender == Gender.female,
            name: name,
          )}';
        }
      }
    }

    final updated = _scored(
      progress.copyWith(
        interactionCounts: counts,
        love: pregnancy == love.pregnancy
            ? love
            : love.copyWith(pregnancy: pregnancy),
      ),
      npcId,
      next,
    );
    final state = _state.copyWith(
      lifeProgress: updated,
      player: _state.player.copyWith(
        stats: _state.player.stats.copyWith(
          happiness: _state.player.stats.happiness + (effective ? 3 : 0),
        ),
      ),
    );
    final friends = progress.friends;
    final friendIndex = friends.indexWhere((friend) => friend.id == npcId);

    return _socialOutcome(
      npcId: npcId,
      action: 'Have Sex',
      narrative: narrative,
      score: next,
      bond: love.exIds.contains(npcId)
          ? 'ex'
          : friendIndex >= 0
              ? (friends[friendIndex].bestFriend ? 'best friend' : 'friend')
              : 'none',
      progressed: effective,
      prompt: asksAboutBaby ? 'pregnancy' : null,
      next: state,
    );
  }

  /// Carries out a divorce that an event started (the spouse asked).
  void _processMarriageFlags() {
    final progress = _state.lifeProgress;
    final love = progress.love;

    if (!progress.flags.contains(SystemFlags.divorceFiledUnclear)) return;

    final id = love.partnerId;

    if (id == null || !love.isMarried) {
      // The flag is stale (no spouse any more). Drop it.
      _commit(
        _state.copyWith(
          lifeProgress: progress.copyWith(
            flags: {...progress.flags}
              ..remove(SystemFlags.divorceFiledUnclear),
          ),
        ),
      );
      return;
    }

    final (next, story) = _endMarriage(npcId: id, playerFiles: false);
    final year = _state.clock.currentYear;

    _commit(
      next.addEvent(
        SimulationEvent(
          id: 'divorce-${next.events.length + 1}-$year',
          type: SimulationEventType.npcInteraction,
          year: year,
          title: 'Divorce',
          description: story,
        ),
      ),
    );
  }

  Result<NpcInteractionOutcome> _socialOutcome({
    required String npcId,
    required String action,
    required String narrative,
    required int score,
    required String bond,
    WorldState? next,
    String romance = 'none',
    bool progressed = true,
    String? prompt,
    bool refused = false,
  }) {
    final year = _state.clock.currentYear;
    final state = (next ?? _state).copyWith(
      events: [
        ...(next ?? _state).events,
        SimulationEvent(
          id: 'npc-interaction-${_state.events.length + 1}-$year-$npcId',
          type: SimulationEventType.npcInteraction,
          year: year,
          title: action,
          description: narrative,
        ),
      ],
    );
    final committed = _commit(state);

    if (committed case Failure<void>(:final message)) return Failure(message);

    return Success(NpcInteractionOutcome(
      npcId: npcId,
      action: action,
      narrative: narrative,
      relationshipPercent: score,
      bond: bond,
      romance: romance,
      prompt: prompt,
      onBirthControl: state.lifeProgress.love.birthControl.contains(npcId),
      stage: state.lifeProgress.love.partnerId == npcId
          ? state.lifeProgress.love.stage
          : LoveRules.stageDating,
      refused: refused,
      progressed: progressed,
      year: year,
      age: (year - _state.player.birthYear).clamp(0, 150),
    ));
  }

  /// "Become Friends" with a classmate once the relationship is good enough.
  Result<NpcInteractionOutcome> _befriendNpc(String npcId) {
    final education = _state.lifeProgress.education;
    final friends = _state.lifeProgress.friends;

    if (friends.any((friend) => friend.id == npcId)) {
      return const Failure('We are already friends.');
    }

    final index = education.npcs.indexWhere((npc) => npc.id == npcId);

    if (index < 0 || !education.npcs[index].role.isStudent) {
      return const Failure('I cannot ask this person to be friends.');
    }

    final npc = education.npcs[index];

    if (npc.relationshipPercent < SocialRules.friendAt) {
      return const Failure(
        'We are not close enough yet. '
        'Let us spend more time together first.',
      );
    }

    final score = (npc.relationshipPercent + 5).clamp(-100, 100).toInt();
    final friend = npc.copyWith(relationshipPercent: score);
    final npcs = List.of(education.npcs);

    npcs[index] = friend;

    return _socialOutcome(
      npcId: npcId,
      action: 'Become Friends',
      narrative: SchoolNarratives.befriend(_random, npc.fullName),
      score: score,
      bond: 'friend',
      next: _state.copyWith(
        player: _state.player.copyWith(
          stats: _state.player.stats.copyWith(
            happiness: _state.player.stats.happiness + 3,
          ),
        ),
        lifeProgress: _state.lifeProgress.copyWith(
          education: education.copyWith(npcs: npcs),
          friends: [...friends, friend],
        ),
      ),
    );
  }

  /// The answer to "make this friend a best friend?".
  Result<NpcInteractionOutcome> _answerBestFriend(
    String npcId, {
    required bool yes,
  }) {
    final friends = _state.lifeProgress.friends;
    final index = friends.indexWhere((friend) => friend.id == npcId);

    if (index < 0) return const Failure('This person is not my friend.');

    final friend = friends[index];
    final updated = List.of(friends);

    if (!yes) {
      updated[index] = friend.copyWith(bestFriendAsked: true);

      return _socialOutcome(
        npcId: npcId,
        action: NpcInteractionOutcome.bestFriendNo,
        narrative: 'We are good friends, and that is plenty for now.',
        score: friend.relationshipPercent,
        bond: 'friend',
        next: _state.copyWith(
          lifeProgress: _state.lifeProgress.copyWith(friends: updated),
        ),
      );
    }

    // There is only one best friend at a time.
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(bestFriend: i == index);
    }

    final score = (friend.relationshipPercent + 5).clamp(-100, 100).toInt();

    updated[index] = updated[index].copyWith(relationshipPercent: score);

    return _socialOutcome(
      npcId: npcId,
      action: NpcInteractionOutcome.bestFriendYes,
      narrative: SchoolNarratives.bestFriend(_random, friend.fullName),
      score: score,
      bond: 'best friend',
      next: _state.copyWith(
        player: _state.player.copyWith(
          stats: _state.player.stats.copyWith(
            happiness: _state.player.stats.happiness + 5,
          ),
        ),
        lifeProgress: _state.lifeProgress.copyWith(friends: updated),
      ),
    );
  }

  Result<void> ageUp() {
    final tick = SimulationTick(
      id: _nextTickId,
      fromYear: _state.clock.currentYear,
      toYear: _state.clock.currentYear + 1,
    );

    if (!tick.isValid) {
      return const Failure(
        'Unable to create a valid simulation tick.',
      );
    }

    final result = execute(
      const AgeUpCommand(),
    );

    if (result case Success<void>()) {
      _nextTickId++;
      _newborn = null;
      ensureSchool();
      _resolvePregnancy();
      _decayRelationships();
      _recordCheckpoint();
    }

    return result;
  }

  // ---------------------------------------------------------------------
  // Time Machine: go back to an earlier age of this life.
  // ---------------------------------------------------------------------

  final List<_AgeCheckpoint> _checkpoints = <_AgeCheckpoint>[];
  int _rewindCount = 0;

  int get _currentAge => _state.player.ageAt(_state.clock.currentYear);

  /// Remembers the start of the age the player just reached.
  void _recordCheckpoint() {
    final age = _currentAge;

    _checkpoints.removeWhere((checkpoint) => checkpoint.age >= age);
    _checkpoints.add(
      _AgeCheckpoint(
        age: age,
        state: _state,
        randomState: _random.state,
        nextTickId: _nextTickId,
      ),
    );
  }

  /// Ages the player can travel back to, newest first. Only ages lived in
  /// this play session are remembered, and never the current one.
  List<int> get rewindableAges => [
        for (final checkpoint in _checkpoints.reversed)
          if (checkpoint.age < _currentAge) checkpoint.age,
      ];

  /// Goes back to the start of [age]. Everything that happened after it is
  /// undone. The dice are re-rolled so the same year can play out
  /// differently.
  Result<void> rewindToAge(int age) {
    if (age >= _currentAge) {
      return const Failure('The time machine only travels to the past.');
    }

    final index = _checkpoints.lastIndexWhere(
      (checkpoint) => checkpoint.age == age,
    );

    if (index < 0) {
      return const Failure('I cannot remember that age.');
    }

    final checkpoint = _checkpoints[index];

    _rewindCount++;
    _breakups.clear();
    _state = checkpoint.state;
    _nextTickId = checkpoint.nextTickId;
    _random.restoreState(
      (checkpoint.randomState + 104729 * _rewindCount) & 0x7fffffff,
    );
    _checkpoints.removeRange(index + 1, _checkpoints.length);

    return const Success(null);
  }

  static const int _maxStoredAges = 20;

  Future<void> _persistTimeline(SaveSlot slot) async {
    try {
      final start = _checkpoints.length > _maxStoredAges
          ? _checkpoints.length - _maxStoredAges
          : 0;

      await _saveManager.saveTimeline(
        [
          for (final checkpoint in _checkpoints.skip(start))
            TimelineEntry(
              age: checkpoint.age,
              state: checkpoint.state,
              randomState: checkpoint.randomState,
              nextTickId: checkpoint.nextTickId,
            ),
        ],
        slot: slot,
      );
    } catch (_) {
      // The Time Machine is a bonus; never fail a save because of it.
    }
  }

  Future<void> _restoreTimelineFrom(SaveSlot slot) async {
    try {
      final entries = await _saveManager.loadTimeline(slot);

      _checkpoints
        ..clear()
        ..addAll([
          for (final entry in entries)
            _AgeCheckpoint(
              age: entry.age,
              state: entry.state,
              randomState: entry.randomState,
              nextTickId: entry.nextTickId,
            ),
        ]);
    } catch (_) {
      _checkpoints.clear();
    }
  }

  /// Loads the saved Time Machine timeline of the active life (used right
  /// after the app opens a life without going through [loadFromSlot]).
  Future<void> restoreTimeline() async {
    final slot = _activeSlot;

    if (slot != null) {
      await _restoreTimelineFrom(slot);
    }
  }

  /// The Life Storage slot this life autosaves into (null until the first
  /// save picks a free slot).
  SaveSlot? get activeSlot => _activeSlot;

  set activeSlot(SaveSlot? slot) {
    _activeSlot = slot;
  }

  SaveSlot? _activeSlot;

  /// The first empty Life Storage slot, or null when storage is full.
  /// A slot that cannot be read counts as taken, so it is never overwritten.
  Future<SaveSlot?> firstFreeSlot() async {
    for (final slot in SaveSlot.values) {
      try {
        if (!await hasSave(slot)) {
          return slot;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  /// Autosaves this life into its own slot.
  Future<Result<void>> save() async {
    var slot = _activeSlot;

    if (slot == null) {
      slot = await firstFreeSlot();

      if (slot == null) {
        return const Failure(
          'Life Storage is full. Delete a life to make room.',
        );
      }
    }

    final result = await saveToSlot(slot);

    if (result.isSuccess) {
      _activeSlot = slot;
    }

    return result;
  }

  Future<Result<void>> saveToSlot(
    SaveSlot slot,
  ) async {
    try {
      final validation = _validator.validate(_state);

      if (validation
          case Failure<void>(
            :final message,
          )) {
        return Failure(
          'Save failed: invalid world state: $message',
        );
      }

      if (_nextTickId < 1) {
        return const Failure(
          'Save failed: next tick ID must be greater than zero.',
        );
      }

      final randomState = _random.state;

      if (randomState < 0 || randomState > 0x7fffffff) {
        return const Failure(
          'Save failed: random state is outside the valid range.',
        );
      }

      await _saveManager.save(
        _state,
        randomState: randomState,
        nextTickId: _nextTickId,
        slot: slot,
      );

      await _persistTimeline(slot);

      return const Success(null);
    } catch (error) {
      return Failure(
        'Save failed: $error',
      );
    }
  }

  Future<Result<void>> load() {
    return loadFromSlot(
      _activeSlot ?? SaveSlot.slot1,
    );
  }

  Future<Result<void>> loadFromSlot(
    SaveSlot slot,
  ) async {
    try {
      final data = await _saveManager.loadSlot(
        slot,
      );

      if (data == null) {
        return const Failure(
          'No save data exists in this slot.',
        );
      }

      final validation = _validator.validate(
        data.state,
      );

      if (validation
          case Failure<void>(
            :final message,
          )) {
        return Failure(
          'Loaded save is invalid: $message',
        );
      }

      if (data.randomState < 0 ||
          data.randomState > 0x7fffffff) {
        return const Failure(
          'Loaded save is invalid: random state is outside '
          'the valid range.',
        );
      }

      if (data.nextTickId < 1) {
        return const Failure(
          'Loaded save is invalid: next tick ID must be '
          'greater than zero.',
        );
      }

      // Restore the random generator only after all loaded data
      // has passed validation. The remaining assignments cannot
      // fail under normal Dart execution.
      _random.restoreState(
        data.randomState,
      );

      _breakups.clear();
      _state = data.state;
      _nextTickId = data.nextTickId;
      _activeSlot = slot;
      _checkpoints.clear();
      await _restoreTimelineFrom(slot);

      return const Success(null);
    } catch (error) {
      return Failure(
        'Load failed: $error',
      );
    }
  }

  Future<Result<void>> deleteSave(
    SaveSlot slot,
  ) async {
    try {
      await _saveManager.deleteSlot(
        slot,
      );

      try {
        await _saveManager.deleteTimeline(slot);
      } catch (_) {
        // A missing timeline is not worth failing the delete.
      }

      if (_activeSlot == slot) {
        _activeSlot = null;
      }

      return const Success(null);
    } catch (error) {
      return Failure(
        'Delete failed: $error',
      );
    }
  }

  Future<bool> hasSave(
    SaveSlot slot,
  ) {
    return _saveManager.hasSave(
      slot,
    );
  }

  Future<SaveData?> readSaveSlot(
    SaveSlot slot,
  ) {
    return _saveManager.loadSlot(
      slot,
    );
  }

  static SimulationEngine create({
    required Character player,
    required int seed,
    required SaveRepository saveRepository,
  }) {
    final random = SeededRandom(seed);

    final countryCode = player.location?.countryCode ?? 'ID';
    final familyHousehold = FamilyHouseholdGenerator.generate(
      random: random,
      birthYear: player.birthYear,
      familyName: player.resolvedLastName,
      countryCode: countryCode,
      childAppearance: player.appearance,
    );

    final startingLifeEvents = StartingLifeEventGenerator.generate(
      random: random,
      year: player.birthYear,
      household: familyHousehold,
      player: player,
    );

    final initialState = WorldState(
      clock: SimulationClock(
        currentYear: player.birthYear,
      ),
      player: player,
      events: [
        SimulationEvent(
          id: 'life-created',
          type: SimulationEventType.lifeCreated,
          year: player.birthYear,
          title: 'A new life begins',
          description: StartingLifeEventGenerator.birthNarrative(
            player: player,
            household: familyHousehold,
            random: random,
          ),
        ),
        ...startingLifeEvents,
      ],
      familyHousehold: familyHousehold,
    );

    return SimulationEngine(
      initialState: initialState,
      random: random,
      saveRepository: saveRepository,
    );
  }
}

/// The state of a life at the start of an age, kept for the Time Machine.
class _AgeCheckpoint {
  const _AgeCheckpoint({
    required this.age,
    required this.state,
    required this.randomState,
    required this.nextTickId,
  });

  final int age;
  final WorldState state;
  final int randomState;
  final int nextTickId;
}
