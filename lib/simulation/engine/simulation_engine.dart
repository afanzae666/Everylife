
import '../../data/repositories/timeline_store.dart';
import '../../core/random/seeded_random.dart';
import '../narrative/npc_interaction_narratives.dart';
import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';
import '../../data/services/save_manager.dart';
import '../../domain/character/character.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/character/life_stage.dart';
import '../../domain/event/life_event.dart';
import '../../domain/event/life_progress.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/social/social_rules.dart';
import '../narrative/school_narratives.dart';
import '../narrative/love_narratives.dart';
import '../school/school_appearance.dart';
import '../../domain/character/fertility.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/cultural_randomizer_catalog.dart';
import 'dart:math' as math;
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

  Result<String> applyForUniversity() => _commitAction(
        CareerActions.applyForUniversity(state: _state, random: _random),
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
    if (playerStage == LifeStage.infant) {
      return const Failure('NPC interactions are unavailable during infancy.');
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
        !const ['Talk', 'Spend Time', 'Compliment', 'Help'].contains(action)) {
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
    final narrative = NpcInteractionNarratives.pick(
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

    if (friendIndex >= 0) {
      final friend = friends[friendIndex];

      bond = friend.bestFriend ? 'best friend' : 'friend';

      if (progressed &&
          !friend.bestFriend &&
          !friend.bestFriendAsked &&
          nextScore >= SocialRules.bestFriendAt) {
        prompt = 'bestFriend';
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

  void declineFriendOffer() => _friendOffer = null;

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
    'Birth Control',
    NpcInteractionOutcome.pregnancyKeep,
    NpcInteractionOutcome.pregnancyEnd,
  };

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
          love: love.copyWith(partnerId: npcId, partnerSince: year),
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

    if (love.partnerId != npcId) {
      return const Failure('This person is not my partner.');
    }

    final key = '$year:$npcId:$action';
    final times = progress.interactionCounts[key] ?? 0;
    final first = times == 0;
    final counts = {
      for (final entry in progress.interactionCounts.entries)
        if (entry.key.startsWith('$year:')) entry.key: entry.value,
      key: times + 1,
    };

    if (action == 'Break Up') {
      final next = (score - 35).clamp(-100, 100).toInt();
      final updated = _scored(
        progress.copyWith(love: love.copyWith(clearPartner: true)),
        npcId,
        next,
      );

      return _socialOutcome(
        npcId: npcId,
        action: action,
        narrative: LoveNarratives.breakUp(_random, name),
        score: next,
        bond: 'friend',
        next: withStats(
          _state.copyWith(lifeProgress: updated),
          happiness: -6,
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
        romance: 'partner',
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
          var chance = (mine * theirs / 100 * 0.35).round();

          if (love.birthControl.contains(npcId)) chance = chance ~/ 10;

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
    };
    final change = changes[action];

    if (change == null) return const Failure('Unknown interaction.');

    final year = _state.clock.currentYear;
    final progress = _state.lifeProgress;
    final children = List.of(progress.love.children);
    final index = children.indexWhere((child) => child.id == childId);

    if (index < 0) return const Failure('I cannot find my child.');

    final child = children[index];
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
            'Spend Time' || 'Apologize' => 1,
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

  ChildNpc? _newborn;

  /// The baby born at the last birthday, once. The screen announces it.
  ChildNpc? takeNewborn() {
    final baby = _newborn;

    _newborn = null;

    return baby;
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

    return _commit(
      _state.copyWith(
        lifeProgress: progress.copyWith(
          love: progress.love.copyWith(children: children),
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
