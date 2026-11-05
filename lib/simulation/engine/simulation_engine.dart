
import '../../core/random/seeded_random.dart';
import '../../core/result/result.dart';
import '../../data/repositories/save_repository.dart';
import '../../data/services/save_manager.dart';
import '../../domain/character/character.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/character/life_stage.dart';
import '../../domain/event/life_event.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/time/simulation_clock.dart';
import '../../domain/world/world_state.dart';
import '../commands/age_up_command.dart';
import '../commands/simulation_command.dart';
import '../career/career_actions.dart';
import '../events/life_effect_applier.dart';
import '../events/life_event_catalog.dart';
import '../generation/family_household_generator.dart';
import '../generation/starting_background_generator.dart';
import '../generation/starting_life_event_generator.dart';
import '../systems/career_system.dart';
import '../systems/character_system.dart';
import '../systems/education_system.dart';
import '../systems/family_mortality_system.dart';
import '../systems/event_system.dart';
import '../systems/mortality_system.dart';
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

    return LifeText.fill(event.description, pendingSubject);
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

    final applied = LifeEffectApplier.applyOutcome(
      state: _state,
      outcome: outcome,
    );

    final progress = applied.lifeProgress.copyWith(
      choices: {
        ...applied.lifeProgress.choices,
        definition.id: choice.id,
      },
      clearPending: true,
    );

    // One flowing paragraph: the scene, what I did, and what happened.
    final story = LifeText.fill(choice.story, pending.subject);
    final result = LifeText.fill(outcome.text, pending.subject);
    final scene = LifeText.fill(definition.description, pending.subject);

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
    if ((playerStage == LifeStage.toddler || playerStage == LifeStage.child) &&
        !const ['Talk', 'Spend Time', 'Compliment', 'Help'].contains(action)) {
      return const Failure('This interaction is not available at your current life stage.');
    }

    final household = _state.familyHousehold;
    if (household == null) {
      return const Failure('No NPC household is available.');
    }

    final parentIndex = household.parents.indexWhere((npc) => npc.id == npcId);
    final siblingIndex = household.siblings.indexWhere((npc) => npc.id == npcId);
    if (parentIndex < 0 && siblingIndex < 0) {
      return const Failure('NPC could not be found.');
    }

    final isParent = parentIndex >= 0;
    final alive = isParent
        ? household.parents[parentIndex].isAlive
        : household.siblings[siblingIndex].isAlive;
    if (!alive) return const Failure('A deceased NPC cannot be interacted with.');

    final currentScore = isParent
        ? household.parents[parentIndex].relationshipPercent
        : household.siblings[siblingIndex].relationshipPercent;
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
        ? household.parents[parentIndex].fullName
        : household.siblings[siblingIndex].fullName;
    final narrative = _interactionNarrative(
      action: action,
      npcName: npcName,
      stage: playerStage,
    );

    final parents = List.of(household.parents);
    final siblings = List.of(household.siblings);
    if (isParent) {
      parents[parentIndex] = parents[parentIndex].copyWith(relationshipPercent: nextScore);
    } else {
      siblings[siblingIndex] = siblings[siblingIndex].copyWith(relationshipPercent: nextScore);
    }
    final nextHousehold = household.copyWith(
      parents: parents,
      siblings: siblings,
    );
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

    return Success(NpcInteractionOutcome(
      npcId: npcId,
      action: action,
      narrative: narrative,
      relationshipPercent: nextScore,
      progressed: progressed,
      year: _state.clock.currentYear,
      age: (_state.clock.currentYear - _state.player.birthYear).clamp(0, 150),
    ));
  }

  String _interactionNarrative({
    required String action,
    required String npcName,
    required LifeStage stage,
  }) {
    final child = stage == LifeStage.toddler || stage == LifeStage.child;
    final teen = stage == LifeStage.teen;
    final senior = stage == LifeStage.senior;

    final options = switch (action) {
      'Talk' => child
          ? <String>[
              'I told $npcName about something that happened today.',
              'I chatted with $npcName and shared what was on my mind.',
              'I talked with $npcName and enjoyed having someone listen.',
            ]
          : teen
              ? <String>[
                  'I talked with $npcName about school, friends, and what comes next.',
                  'I opened up to $npcName about a few things on my mind.',
                  'I caught up with $npcName and exchanged thoughts about life.',
                ]
              : senior
                  ? <String>[
                      'I had a thoughtful conversation with $npcName and shared a few memories.',
                      'I caught up with $npcName and enjoyed hearing their perspective.',
                      'I talked with $npcName about life and the things that matter most.',
                    ]
                  : <String>[
                      'I caught up with $npcName and talked about what has been happening lately.',
                      'I shared my thoughts with $npcName and listened to theirs.',
                      'I had a meaningful conversation with $npcName.',
                    ],
      'Spend Time' => child
          ? <String>[
              'I played and spent some happy time with $npcName.',
              'I spent time with $npcName doing something we both enjoyed.',
              'I stayed with $npcName for a while, and we had fun together.',
            ]
          : <String>[
              'I spent time with $npcName, and we felt a little closer afterward.',
              'I shared some time with $npcName and made a good memory.',
              'I enjoyed being around $npcName and strengthening our bond.',
            ],
      'Compliment' => child
          ? <String>[
              'I told $npcName something I liked about them, and they smiled.',
              'I said something nice to $npcName and could tell it cheered them up.',
              'I let $npcName know I thought they did a great job.',
            ]
          : senior
              ? <String>[
                  'I told $npcName how much I valued them and the memories we share.',
                  'I praised something about $npcName that I have always admired.',
                  'I reminded $npcName that their kindness means a lot to me.',
                ]
              : <String>[
                  'I said something kind to $npcName, and they seemed pleased.',
                  'I complimented $npcName and made sure they knew I appreciated them.',
                  'I pointed out something I admired about $npcName.',
                ],
      'Help' => child
          ? <String>[
              'I helped $npcName with a small task and felt useful.',
              'I offered $npcName a hand with something they were doing.',
              'I helped $npcName tidy up and finish what they were working on.',
            ]
          : senior
              ? <String>[
                  'I helped $npcName with something difficult and was glad I could support them.',
                  'I offered practical help to $npcName when they needed it.',
                  'I made time to help $npcName and ease some of their burden.',
                ]
              : <String>[
                  'I helped $npcName with something they needed to get done.',
                  'I offered support to $npcName when they could use a hand.',
                  'I stepped in to help $npcName, showing that they could count on me.',
                ],
      'Argue' => teen
          ? <String>[
              'I argued with $npcName after we disagreed, and things felt awkward afterward.',
              'I let a disagreement with $npcName turn into an argument.',
              'I lost my patience with $npcName, and our disagreement became heated.',
            ]
          : senior
              ? <String>[
                  'I had a disagreement with $npcName, and it left a distance between us.',
                  'I argued with $npcName, wishing afterward that we had handled it more calmly.',
                  'I let tension grow between me and $npcName after we exchanged harsh words.',
                ]
              : <String>[
                  'I argued with $npcName, and the disagreement put a strain on our relationship.',
                  'I noticed things getting tense between me and $npcName after we disagreed.',
                  'I clashed with $npcName, leaving both of us frustrated.',
                ],
      'Apologize' => teen
          ? <String>[
              'I apologized to $npcName and tried to clear the air.',
              'I admitted my mistake to $npcName and hoped we could move on.',
              'I reached out to $npcName to make peace after our argument.',
            ]
          : senior
              ? <String>[
                  'I apologized to $npcName and hoped we could put the disagreement behind us.',
                  'I spoke sincerely with $npcName and tried to mend our relationship.',
                  'I asked $npcName to forgive me and made an effort to make things right.',
                ]
              : <String>[
                  'I apologized to $npcName and tried to make things right.',
                  'I admitted I was wrong to $npcName and made an effort to repair our bond.',
                  'I reached out to $npcName with an apology and hoped we could move forward.',
                ],
      _ => <String>['I interacted with $npcName.'],
    };

    return options[_random.nextInt(options.length)];
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
    final startingBackground = StartingBackgroundGenerator.generate(
      random,
      countryCode: countryCode,
    );

    final familyHousehold = FamilyHouseholdGenerator.generate(
      random: random,
      birthYear: player.birthYear,
      background: startingBackground,
      familyName: player.resolvedLastName,
      countryCode: countryCode,
      childAppearance: player.appearance,
    );

    final startingLifeEvents = StartingLifeEventGenerator.generate(
      random: random,
      year: player.birthYear,
      background: startingBackground,
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
      startingBackground: startingBackground,
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
