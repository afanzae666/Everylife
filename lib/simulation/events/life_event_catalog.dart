import '../../domain/event/life_event.dart';
import '../../domain/world/world_state.dart';
import 'event_subjects.dart';
import 'life_event_catalog_more.dart';
import 'life_event_catalog_social.dart';
import 'scripted_events.dart';

/// The built-in life events (all player-facing text is English).
///
/// Money amounts are baseline US cents and are scaled by the player's
/// country cost of living when applied.
abstract final class LifeEventCatalog {
  static LifeEventDefinition? byId(String id) {
    for (final event in all) {
      if (event.id == id) return event;
    }

    return null;
  }

  /// Events that can appear for this player right now.
  static List<LifeEventDefinition> eligible({
    required WorldState state,
    required int age,
  }) {
    final progress = state.lifeProgress;
    final year = state.clock.currentYear;
    final household = state.familyHousehold;

    final hasLivingParent =
        household?.parents.any((parent) => parent.isAlive) ?? false;
    final hasLivingSibling = household?.siblings.any(
          (sibling) => sibling.isAlive && sibling.birthYear <= year,
        ) ??
        false;

    return [
      for (final event in all)
        if (!event.scripted &&
            age >= event.minAge &&
            age <= event.maxAge &&
            !(event.oncePerLife &&
                progress.lastSeenYear.containsKey(event.id)) &&
            !_isCoolingDown(event, progress.lastSeenYear[event.id], year) &&
            event.requiredFlags.every(progress.flags.contains) &&
            !event.forbiddenFlags.any(progress.flags.contains) &&
            event.statRequirements
                .every((rule) => rule.isMetBy(state.player.stats)) &&
            (!event.needsLivingParent || hasLivingParent) &&
            (!event.needsLivingSibling || hasLivingSibling) &&
            EventSubjects.isAvailable(event.about, state))
          event,
    ];
  }

  static bool _isCoolingDown(
    LifeEventDefinition event,
    int? lastSeen,
    int year,
  ) {
    if (lastSeen == null) return false;

    return year - lastSeen < event.cooldownYears;
  }

  static const List<LifeEventDefinition> all = [
    ..._core,
    ...LifeEventCatalogMore.all,
    ...LifeEventCatalogSocial.all,
    ...ScriptedEvents.all,
  ];

  static const List<LifeEventDefinition> _core = [
    // ---------------------------------------------------------------- Infancy
    LifeEventDefinition(
      id: 'first_steps',
      title: 'First Steps',
      description: 'I let go of the couch and wobbled across the living room.',
      minAge: 1,
      maxAge: 2,
      oncePerLife: true,
      weight: 30,
      autoOutcomes: [
        LifeOutcome(
          text: 'Everyone cheered, and I fell on my bottom, proud as ever.',
          stats: [StatEffect(StatKey.fitness, 2), StatEffect(StatKey.happiness, 2)],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'first_word',
      title: 'First Word',
      description: 'The whole family held its breath as I opened my mouth.',
      minAge: 1,
      maxAge: 3,
      oncePerLife: true,
      weight: 30,
      autoOutcomes: [
        LifeOutcome(
          text: 'My first word was "mama". Cue the happy tears.',
          stats: [StatEffect(StatKey.intelligence, 2)],
        ),
        LifeOutcome(
          text: 'My first word was "no". It would not be my last.',
          stats: [StatEffect(StatKey.willpower, 2)],
        ),
        LifeOutcome(
          text: 'My first word was the dog\'s name. The dog was thrilled.',
          stats: [StatEffect(StatKey.charisma, 2)],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'baby_fever',
      title: 'A Rough Night',
      description: 'I woke up burning hot and cranky.',
      minAge: 1,
      maxAge: 4,
      weight: 8,
      autoOutcomes: [
        LifeOutcome(
          weight: 3,
          text: 'A cool cloth and a lullaby fixed everything by morning.',
          stats: [StatEffect(StatKey.happiness, 1)],
        ),
        LifeOutcome(
          weight: 2,
          text: 'It took a doctor visit and a week of rest to shake it off.',
          stats: [StatEffect(StatKey.health, -4), StatEffect(StatKey.happiness, -2)],
        ),
      ],
    ),
    // ----------------------------------------------------------------- Toddler
    LifeEventDefinition(
      id: 'toddler_tantrum',
      title: 'Supermarket Meltdown',
      description: 'I wanted the shiny cereal box. I was told no.',
      minAge: 3,
      maxAge: 5,
      weight: 14,
      choices: [
        LifeChoice(
          id: 'scream',
          label: 'Throw the loudest tantrum in history',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: 'The whole aisle stared. I got the cereal, but also a lecture.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, -2)],
            ),
            LifeOutcome(
              weight: 6,
              text: 'No cereal, no dessert, and an early bedtime.',
              stats: [StatEffect(StatKey.happiness, -4)],
            ),
          ],
        ),
        LifeChoice(
          id: 'breathe',
          label: 'Take a deep breath and let it go',
          outcomes: [
            LifeOutcome(
              text: 'I held it together. A neighbour told my parent I was an angel.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'hide',
          label: 'Hide inside the cereal display',
          outcomes: [
            LifeOutcome(
              text: 'The display collapsed. It was the most fun I had all year.',
              stats: [StatEffect(StatKey.creativity, 2), StatEffect(StatKey.happiness, 2), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'imaginary_friend',
      title: 'Mr. Biscuit',
      description: 'I made a new best friend, and nobody else can see him.',
      minAge: 3,
      maxAge: 6,
      oncePerLife: true,
      choices: [
        LifeChoice(
          id: 'embrace',
          label: 'Set a place for him at dinner',
          outcomes: [
            LifeOutcome(
              text: 'Mr. Biscuit and I invented a whole kingdom together.',
              stats: [StatEffect(StatKey.creativity, 4), StatEffect(StatKey.happiness, 2)],
              addFlags: ['imaginary_friend'],
            ),
          ],
        ),
        LifeChoice(
          id: 'tell_everyone',
          label: 'Introduce him to the whole kindergarten',
          outcomes: [
            LifeOutcome(
              weight: 1,
              text: 'The other kids loved the idea and joined in.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.creativity, 2)],
            ),
            LifeOutcome(
              weight: 1,
              text: 'A few kids laughed at me. Mr. Biscuit was offended.',
              stats: [StatEffect(StatKey.charisma, -2), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'first_day_school',
      title: 'First Day of School',
      description: 'My backpack was bigger than my back, and the classroom was full of strangers.',
      minAge: 5,
      maxAge: 6,
      oncePerLife: true,
      weight: 40,
      choices: [
        LifeChoice(
          id: 'make_friend',
          label: 'Share my crayons with the kid next to me',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: 'We have been inseparable ever since.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
              addFlags: ['childhood_friend'],
            ),
            LifeOutcome(
              weight: 1,
              text: 'They snatched the whole box and ran away. Lesson learned.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'cry',
          label: 'Cling to the gate and cry',
          outcomes: [
            LifeOutcome(
              text: 'The teacher coaxed me in with stickers. It took all morning.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'explore',
          label: 'Ignore everyone and explore the classroom',
          outcomes: [
            LifeOutcome(
              text: 'I found the reading corner and refused to leave.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
      ],
    ),
    // ------------------------------------------------------------------- Child
    LifeEventDefinition(
      id: 'school_bully',
      title: 'The Bully',
      description: '{name}, a bigger kid in my class, keeps taking my lunch money and laughing about it.',
      minAge: 7,
      maxAge: 14,
      requiredFlags: ['school_student'],
      cooldownYears: 6,
      about: EventSubjectKind.classmate,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'stand_up',
          label: 'Stand up to them',
          outcomes: [
            LifeOutcome(
              subjectRelation: -6,
              weight: 5,
              text: 'My voice shook, but they backed down. Word spread fast.',
              stats: [StatEffect(StatKey.willpower, 4), StatEffect(StatKey.charisma, 3)],
              addFlags: ['stood_up_to_bully'],
            ),
            LifeOutcome(
              subjectRelation: -6,
              weight: 5,
              text: 'It turned into a scuffle, and I lost. I limped home with a bruised lip.',
              stats: [StatEffect(StatKey.health, -6), StatEffect(StatKey.happiness, -5), StatEffect(StatKey.willpower, 2)],
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'tell_teacher',
          label: 'Tell a teacher',
          outcomes: [
            LifeOutcome(
              subjectRelation: -6,
              weight: 7,
              text: 'The teacher stepped in and the bully was moved to another class.',
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              subjectRelation: -6,
              weight: 3,
              text: 'Someone called me a snitch, and that stuck for months.',
              stats: [StatEffect(StatKey.charisma, -4), StatEffect(StatKey.happiness, -3)],
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'avoid',
          label: 'Avoid them and keep quiet',
          outcomes: [
            LifeOutcome(
              subjectRelation: -6,
              text: 'I took the long way around school every day. It was exhausting.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.willpower, -2)],
              addFlags: ['bullied'],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'bully_aftermath',
      title: 'Finding My Spine',
      description: 'The memory of being picked on still follows me around school.',
      minAge: 9,
      maxAge: 18,
      oncePerLife: true,
      requiredFlags: ['bullied'],
      weight: 25,
      choices: [
        LifeChoice(
          id: 'self_defense',
          label: 'Sign up for a martial arts class',
          outcomes: [
            LifeOutcome(
              text: 'Every bruise taught me something. I walk taller now.',
              stats: [StatEffect(StatKey.fitness, 4), StatEffect(StatKey.willpower, 4), StatEffect(StatKey.health, -2)],
              removeFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'new_club',
          label: 'Join a club and make new friends',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'I found people who liked me exactly as I am.',
              stats: [StatEffect(StatKey.charisma, 4), StatEffect(StatKey.happiness, 5)],
              removeFlags: ['bullied'],
            ),
            LifeOutcome(
              weight: 1,
              text: 'The club was a bit dull, but at least I tried.',
              stats: [StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_test',
      title: 'The Big Test',
      description: 'A huge test is tomorrow and I have barely opened the book.',
      minAge: 7,
      maxAge: 18,
      requiredFlags: ['school_student'],
      cooldownYears: 3,
      weight: 16,
      choices: [
        LifeChoice(
          id: 'study',
          label: 'Study all night',
          outcomes: [
            LifeOutcome(
              weight: 8,
              text: 'I aced it, though I looked like a zombie.',
              stats: [StatEffect(StatKey.intelligence, 4), StatEffect(StatKey.health, -2), StatEffect(StatKey.happiness, -1)],
            ),
            LifeOutcome(
              weight: 2,
              text: 'I fell asleep on the exam paper. Still passed, barely.',
              stats: [StatEffect(StatKey.intelligence, 1), StatEffect(StatKey.health, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'wing_it',
          label: 'Wing it',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: 'Somehow every guess was right. Pure luck.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.luck, 1)],
            ),
            LifeOutcome(
              weight: 6,
              text: 'I stared at the paper like it was written in an alien language.',
              stats: [StatEffect(StatKey.intelligence, -2), StatEffect(StatKey.happiness, -4)],
              addFlags: ['failed_test'],
            ),
          ],
        ),
        LifeChoice(
          id: 'cheat',
          label: 'Copy from the smart kid',
          outcomes: [
            LifeOutcome(
              weight: 5,
              text: 'Nobody noticed. My conscience noticed, though.',
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.willpower, -3)],
            ),
            LifeOutcome(
              weight: 5,
              text: 'The teacher caught me. My parents heard about it before I got home.',
              parentRelation: -5,
              stats: [StatEffect(StatKey.charisma, -3), StatEffect(StatKey.happiness, -5)],
              addFlags: ['caught_cheating'],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'pet_request',
      title: 'Can We Get a Pet?',
      description: 'I have been dreaming about having a pet for months.',
      minAge: 6,
      maxAge: 13,
      oncePerLife: true,
      needsLivingParent: true,
      weight: 14,
      choices: [
        LifeChoice(
          id: 'ask_puppy',
          label: 'Beg for a puppy',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: 'They said yes! A tiny puppy now chews all my socks.',
              parentRelation: 5,
              stats: [StatEffect(StatKey.happiness, 8), StatEffect(StatKey.fitness, 2)],
              addFlags: ['has_pet'],
            ),
            LifeOutcome(
              weight: 6,
              text: 'They said "maybe when you are older". I sulked for a week.',
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ask_fish',
          label: 'Settle for a goldfish',
          outcomes: [
            LifeOutcome(
              text: 'Sir Bubbles lived a long, quiet life in a tiny bowl.',
              stats: [StatEffect(StatKey.happiness, 3)],
              addFlags: ['has_pet'],
            ),
          ],
        ),
        LifeChoice(
          id: 'dont_ask',
          label: 'Do not ask. Save my allowance instead',
          narration: 'I did not ask. I saved my allowance instead.',
          outcomes: [
            LifeOutcome(
              text: 'I learned patience, and found a nice stray cat to feed outside.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'playground_climb',
      title: 'The Tallest Bar',
      description: 'The older kids dared me to climb to the top of the jungle gym.',
      minAge: 5,
      maxAge: 12,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'climb',
          label: 'Climb it',
          outcomes: [
            LifeOutcome(
              weight: 6,
              text: 'I reached the top and the whole playground cheered.',
              stats: [StatEffect(StatKey.fitness, 3), StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              weight: 4,
              text: 'My hand slipped. I landed hard and spent the afternoon in the nurse\'s office.',
              stats: [StatEffect(StatKey.health, -8), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'play_safe',
          label: 'Stay on the swings',
          outcomes: [
            LifeOutcome(
              text: 'Safe, but I heard the word "chicken" more than once.',
              stats: [StatEffect(StatKey.fitness, 1), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'sibling_squabble',
      title: 'Sibling Rivalry',
      description: '{Role} {first} broke my favourite toy and swears {he} did not.',
      minAge: 6,
      maxAge: 17,
      needsLivingSibling: true,
      about: EventSubjectKind.sibling,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'fight_back',
          label: 'Break one of theirs',
          outcomes: [
            LifeOutcome(
              text: 'We both got grounded. The house was very quiet for a week.',
              subjectRelation: -8,
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'truce',
          label: 'Offer a truce',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'We shook hands and built a blanket fort together.',
              subjectRelation: 8,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              weight: 1,
              text: 'They laughed in my face and kept the toy.',
              subjectRelation: -3,
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'tell_parent',
          label: 'Tell our parents',
          outcomes: [
            LifeOutcome(
              text: 'Justice was served, but I was labelled a tattletale for a while.',
              subjectRelation: -4,
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.charisma, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'after_school_activity',
      title: 'After-School Activities',
      description: 'The school is recruiting for clubs and teams this term.',
      minAge: 8,
      maxAge: 17,
      cooldownYears: 5,
      weight: 14,
      choices: [
        LifeChoice(
          id: 'join_team',
          label: 'Try out for the sports team',
          outcomes: [
            LifeOutcome(
              weight: 6,
              text: 'I made the team! Practice is brutal, but I love it.',
              stats: [StatEffect(StatKey.fitness, 5), StatEffect(StatKey.charisma, 3)],
              addFlags: ['athlete'],
            ),
            LifeOutcome(
              weight: 4,
              text: 'I got cut in the first round. It stung more than I admitted.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'join_arts',
          label: 'Join the art or music club',
          outcomes: [
            LifeOutcome(
              text: 'I discovered I actually have some talent.',
              stats: [StatEffect(StatKey.creativity, 5), StatEffect(StatKey.happiness, 2)],
              addFlags: ['artistic'],
            ),
          ],
        ),
        LifeChoice(
          id: 'stay_home',
          label: 'Go home and play video games',
          outcomes: [
            LifeOutcome(
              text: 'Great time, but my legs forgot what stairs are.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.fitness, -3)],
            ),
          ],
        ),
      ],
    ),
    // ------------------------------------------------------------------- Teen
    LifeEventDefinition(
      id: 'first_crush',
      title: 'Butterflies',
      description: 'My heart skips a beat every time a certain classmate walks by.',
      minAge: 12,
      maxAge: 17,
      oncePerLife: true,
      weight: 18,
      choices: [
        LifeChoice(
          id: 'confess',
          label: 'Confess my feelings',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: 'They smiled and said yes. I floated for a week.',
              stats: [StatEffect(StatKey.happiness, 8), StatEffect(StatKey.charisma, 2)],
              addFlags: ['first_love'],
            ),
            LifeOutcome(
              weight: 6,
              text: 'They gently said no. It hurt, but I survived.',
              stats: [StatEffect(StatKey.happiness, -6), StatEffect(StatKey.willpower, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'letter',
          label: 'Write an anonymous letter',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'They worked out it was me and found it adorable.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.creativity, 2)],
              addFlags: ['first_love'],
            ),
            LifeOutcome(
              weight: 7,
              text: 'The letter got passed around the class. I wanted to disappear.',
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.charisma, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'keep_secret',
          label: 'Keep it to myself',
          outcomes: [
            LifeOutcome(
              text: 'I admired from afar. Safe, but a little lonely.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'peer_pressure_cigarette',
      title: 'Behind the Gym',
      description: 'A few older kids pass around a cigarette and look my way.',
      minAge: 13,
      maxAge: 19,
      cooldownYears: 5,
      forbiddenFlags: ['smoker'],
      weight: 10,
      choices: [
        LifeChoice(
          id: 'try_it',
          label: 'Take a puff to fit in',
          outcomes: [
            LifeOutcome(
              weight: 6,
              text: 'I coughed for a minute straight. Never again... I hoped.',
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              weight: 4,
              text: 'One puff turned into a habit. Now I need one every day.',
              stats: [StatEffect(StatKey.health, -6), StatEffect(StatKey.charisma, 1)],
              addFlags: ['smoker'],
            ),
          ],
        ),
        LifeChoice(
          id: 'refuse',
          label: 'Say no and walk away',
          outcomes: [
            LifeOutcome(
              weight: 7,
              text: 'A few of them respected it. Others kept their distance.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.charisma, 1)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'They called me a baby for weeks. I held my ground.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'quit_smoking',
      title: 'The Cough',
      description: 'The stairs leave me gasping, and I know why.',
      minAge: 16,
      maxAge: 90,
      cooldownYears: 3,
      requiredFlags: ['smoker'],
      weight: 20,
      choices: [
        LifeChoice(
          id: 'quit',
          label: 'Quit for good',
          outcomes: [
            LifeOutcome(
              weight: 5,
              text: 'The first weeks were hell, but I did it.',
              stats: [StatEffect(StatKey.health, 5), StatEffect(StatKey.willpower, 4)],
              removeFlags: ['smoker'],
            ),
            LifeOutcome(
              weight: 5,
              text: 'I lasted nine days before a stressful afternoon undid everything.',
              stats: [StatEffect(StatKey.willpower, -2), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'keep_smoking',
          label: 'Light up another one',
          outcomes: [
            LifeOutcome(
              text: 'It calms me down today. My lungs will send the bill later.',
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'party_invite',
      title: 'The Party',
      description: 'The coolest kid in school is throwing a party tonight.',
      minAge: 14,
      maxAge: 24,
      cooldownYears: 3,
      weight: 14,
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Go and have fun',
          outcomes: [
            LifeOutcome(
              weight: 5,
              text: 'Best night of the year. I made a dozen new friends.',
              stats: [StatEffect(StatKey.happiness, 6), StatEffect(StatKey.charisma, 3)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'Someone spiked the punch and I paid for it the next morning.',
              stats: [StatEffect(StatKey.health, -4), StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              weight: 2,
              text: 'The police shut the party down. My parents were furious.',
              parentRelation: -8,
              stats: [StatEffect(StatKey.happiness, -6), StatEffect(StatKey.willpower, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'study',
          label: 'Stay home and study',
          outcomes: [
            LifeOutcome(
              text: 'The notes made sense. My social life did not.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'quiet_hangout',
          label: 'Hang out with two close friends instead',
          outcomes: [
            LifeOutcome(
              text: 'We ate instant noodles and talked until sunrise.',
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'teen_summer_job',
      title: 'Summer Job',
      description: 'School is out and my wallet is empty.',
      minAge: 15,
      maxAge: 18,
      oncePerLife: true,
      weight: 16,
      choices: [
        LifeChoice(
          id: 'work',
          label: 'Take a summer job',
          outcomes: [
            LifeOutcome(
              text: 'Long days and sore feet, but I got my first real paycheck.',
              moneyBase: 80000,
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.fitness, 1), StatEffect(StatKey.happiness, -1)],
              addFlags: ['early_worker'],
            ),
          ],
        ),
        LifeChoice(
          id: 'friends',
          label: 'Spend the whole summer with friends',
          outcomes: [
            LifeOutcome(
              text: 'Sunburns, road trips, terrible jokes. Perfect.',
              stats: [StatEffect(StatKey.happiness, 6), StatEffect(StatKey.charisma, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'learn_instrument',
          label: 'Teach myself an instrument',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'By August I could play three whole songs.',
              stats: [StatEffect(StatKey.creativity, 5), StatEffect(StatKey.willpower, 2)],
              addFlags: ['artistic'],
            ),
            LifeOutcome(
              weight: 1,
              text: 'I gave up in week two. The guitar became a very nice coat rack.',
              stats: [StatEffect(StatKey.creativity, 1), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'viral_video',
      title: 'Going Viral?',
      description: 'I have a wild idea for a video. Posting it could go either way.',
      minAge: 13,
      maxAge: 30,
      cooldownYears: 5,
      weight: 8,
      choices: [
        LifeChoice(
          id: 'post',
          label: 'Hit the post button',
          outcomes: [
            LifeOutcome(
              weight: 1,
              text: 'It exploded overnight. Strangers recognise me now.',
              stats: [StatEffect(StatKey.charisma, 6), StatEffect(StatKey.happiness, 6)],
              moneyBase: 20000,
              addFlags: ['internet_famous'],
            ),
            LifeOutcome(
              weight: 5,
              text: 'Seven views. Four were me.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'It went viral for all the wrong reasons.',
              stats: [StatEffect(StatKey.happiness, -6), StatEffect(StatKey.charisma, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'delete',
          label: 'Delete the draft',
          outcomes: [
            LifeOutcome(
              text: 'Safe choice. I will wonder what could have been.',
              stats: [StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
      ],
    ),
    // ------------------------------------------------------------ Young adult
    LifeEventDefinition(
      id: 'after_school_path',
      title: 'What Now?',
      description: 'Graduation is behind me, and everyone keeps asking about my plans.',
      minAge: 18,
      maxAge: 19,
      oncePerLife: true,
      weight: 60,
      choices: [
        LifeChoice(
          id: 'university',
          label: 'Apply to university',
          outcomes: [
            LifeOutcome(
              weight: 7,
              text: 'The acceptance letter arrived. The next chapter begins.',
              stats: [StatEffect(StatKey.intelligence, 5), StatEffect(StatKey.happiness, 3)],
              addFlags: ['university'],
            ),
            LifeOutcome(
              weight: 3,
              text: 'They turned me down. I had to rethink everything.',
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'work',
          label: 'Start working right away',
          outcomes: [
            LifeOutcome(
              text: 'I traded lectures for a time clock and earned real money.',
              moneyBase: 120000,
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, 1)],
              addFlags: ['early_worker'],
            ),
          ],
        ),
        LifeChoice(
          id: 'gap_year',
          label: 'Travel for a year',
          requiresMoneyBase: 100000,
          outcomes: [
            LifeOutcome(
              text: 'I saw ten countries and returned with a bag full of stories.',
              moneyBase: -80000,
              stats: [StatEffect(StatKey.happiness, 8), StatEffect(StatKey.creativity, 3), StatEffect(StatKey.charisma, 2)],
              addFlags: ['traveler'],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'lottery_ticket',
      title: 'Lucky Ticket',
      description: 'The corner store is selling lottery tickets, and the jackpot is huge.',
      minAge: 18,
      maxAge: 100,
      cooldownYears: 6,
      weight: 8,
      choices: [
        LifeChoice(
          id: 'buy',
          label: 'Buy a ticket',
          requiresMoneyBase: 500,
          outcomes: [
            LifeOutcome(
              weight: 960,
              text: 'Not a single matching number. Back to normal life.',
              moneyBase: -500,
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
            LifeOutcome(
              weight: 35,
              text: 'Three numbers matched! A small prize, but a big smile.',
              moneyBase: 20000,
              stats: [StatEffect(StatKey.happiness, 5)],
            ),
            LifeOutcome(
              weight: 5,
              text: 'ALL SIX NUMBERS. I read the ticket five times before screaming.',
              moneyBase: 10000000,
              stats: [StatEffect(StatKey.happiness, 15)],
              addFlags: ['lottery_winner'],
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Keep my money',
          outcomes: [
            LifeOutcome(
              text: 'Sensible. The odds were not on my side anyway.',
              stats: [StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'gym_membership',
      title: 'New Year, New Me',
      description: 'The gym is running a membership promotion that feels like a sign.',
      minAge: 18,
      maxAge: 55,
      cooldownYears: 5,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'sign_up',
          label: 'Sign up for a year',
          requiresMoneyBase: 30000,
          outcomes: [
            LifeOutcome(
              weight: 6,
              text: 'I stuck with it. My body noticed before the mirror did.',
              moneyBase: -30000,
              stats: [StatEffect(StatKey.fitness, 6), StatEffect(StatKey.health, 3)],
            ),
            LifeOutcome(
              weight: 4,
              text: 'I went for three weeks, then the card became a bookmark.',
              moneyBase: -30000,
              stats: [StatEffect(StatKey.fitness, 1), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'run_outside',
          label: 'Jog around the neighbourhood for free',
          outcomes: [
            LifeOutcome(
              text: 'Not glamorous, but my knees and my budget agree.',
              stats: [StatEffect(StatKey.fitness, 3), StatEffect(StatKey.health, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'fast_food',
          label: 'Celebrate with a giant burger instead',
          outcomes: [
            LifeOutcome(
              text: 'Delicious. My doctor would sigh.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.health, -3), StatEffect(StatKey.fitness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'dating_app',
      title: 'Swipe Right',
      description: 'A friend convinced me to try a dating app and now I have a match.',
      minAge: 18,
      maxAge: 50,
      cooldownYears: 4,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'date',
          label: 'Go on the date',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'We talked for hours, and the second date is already planned.',
              stats: [StatEffect(StatKey.happiness, 7), StatEffect(StatKey.charisma, 2)],
              addFlags: ['dating'],
            ),
            LifeOutcome(
              weight: 4,
              text: 'Polite, awkward, and forgettable.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
            LifeOutcome(
              weight: 2,
              text: 'They spent the whole dinner talking about their ex.',
              stats: [StatEffect(StatKey.happiness, -4)],
            ),
          ],
        ),
        LifeChoice(
          id: 'delete_app',
          label: 'Delete the app and focus on myself',
          outcomes: [
            LifeOutcome(
              text: 'Peaceful. I picked up a hobby and stopped refreshing my phone.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.creativity, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_needs_loan',
      title: 'A Favour',
      description: 'A good friend asks to borrow a chunk of money, just until next month.',
      minAge: 18,
      maxAge: 70,
      cooldownYears: 6,
      weight: 10,
      choices: [
        LifeChoice(
          id: 'lend',
          label: 'Lend the money',
          requiresMoneyBase: 50000,
          outcomes: [
            LifeOutcome(
              weight: 11,
              text: 'They paid me back early with a thank-you dinner.',
              moneyBase: 5000,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              weight: 9,
              text: 'They stopped answering my calls. The money is gone.',
              moneyBase: -50000,
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'decline',
          label: 'Say no, politely',
          outcomes: [
            LifeOutcome(
              text: 'It was an awkward conversation, but my savings are safe.',
              stats: [StatEffect(StatKey.charisma, -2), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'help_job',
          label: 'Help them find work instead',
          outcomes: [
            LifeOutcome(
              text: 'It took effort, but they got back on their feet.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
      ],
    ),
    // ------------------------------------------------------------------ Adult
    LifeEventDefinition(
      id: 'job_offer',
      title: 'A Tempting Offer',
      description: 'A recruiter calls with a dream salary, but the hours sound brutal.',
      minAge: 22,
      maxAge: 58,
      cooldownYears: 6,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'take_job',
          label: 'Accept the high-paying job',
          outcomes: [
            LifeOutcome(
              text: 'The money is great. I barely see sunlight.',
              moneyBase: 300000,
              stats: [StatEffect(StatKey.health, -4), StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, 2)],
              addFlags: ['overworked'],
            ),
          ],
        ),
        LifeChoice(
          id: 'stay',
          label: 'Stay where I am',
          outcomes: [
            LifeOutcome(
              text: 'Less money, more evenings. I do not regret it.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.health, 1)],
              removeFlags: ['overworked'],
            ),
          ],
        ),
        LifeChoice(
          id: 'start_business',
          label: 'Quit and start my own business',
          requiresMoneyBase: 100000,
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Against all odds, customers loved it. I am my own boss now.',
              moneyBase: 400000,
              stats: [StatEffect(StatKey.willpower, 4), StatEffect(StatKey.happiness, 5)],
              addFlags: ['entrepreneur'],
            ),
            LifeOutcome(
              weight: 7,
              text: 'The business folded within a year. I lost my savings but gained scars and stories.',
              moneyBase: -150000,
              stats: [StatEffect(StatKey.happiness, -6), StatEffect(StatKey.willpower, 3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'business_growth',
      title: 'Room to Grow',
      description: 'My business is doing well, and an investor wants in.',
      minAge: 25,
      maxAge: 70,
      oncePerLife: true,
      requiredFlags: ['entrepreneur'],
      weight: 30,
      choices: [
        LifeChoice(
          id: 'expand',
          label: 'Take the investment and expand',
          outcomes: [
            LifeOutcome(
              weight: 5,
              text: 'We opened three new branches. It was exhausting and thrilling.',
              moneyBase: 800000,
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.happiness, 4)],
            ),
            LifeOutcome(
              weight: 5,
              text: 'We grew too fast and had to close half of it.',
              moneyBase: -200000,
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'stay_small',
          label: 'Stay small and keep control',
          outcomes: [
            LifeOutcome(
              text: 'Steady income, no sleepless nights.',
              moneyBase: 150000,
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'car_trouble',
      title: 'Wrong Place, Wrong Time',
      description: 'Rain, a slippery road, and a truck that was a little too close.',
      minAge: 18,
      maxAge: 85,
      cooldownYears: 8,
      weight: 6,
      autoOutcomes: [
        LifeOutcome(
          weight: 5,
          text: 'I braked in time. My heart raced, but nothing happened.',
          stats: [StatEffect(StatKey.luck, 1)],
        ),
        LifeOutcome(
          weight: 3,
          text: 'A fender bender. Annoying paperwork and an expensive repair.',
          moneyBase: -80000,
          stats: [StatEffect(StatKey.happiness, -3)],
        ),
        LifeOutcome(
          weight: 2,
          text: 'The crash put me in the hospital for weeks.',
          moneyBase: -150000,
          stats: [StatEffect(StatKey.health, -14), StatEffect(StatKey.happiness, -5)],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'midlife_crisis',
      title: 'Midlife Crisis',
      description: 'I looked in the mirror and wondered where all the years went.',
      minAge: 40,
      maxAge: 55,
      oncePerLife: true,
      weight: 20,
      choices: [
        LifeChoice(
          id: 'sports_car',
          label: 'Buy a flashy sports car',
          requiresMoneyBase: 500000,
          outcomes: [
            LifeOutcome(
              text: 'It is loud, red, and completely impractical. I adore it.',
              moneyBase: -500000,
              stats: [StatEffect(StatKey.happiness, 8), StatEffect(StatKey.charisma, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'marathon',
          label: 'Train for a marathon',
          outcomes: [
            LifeOutcome(
              weight: 7,
              text: 'I crossed the finish line in tears and aching legs. Totally worth it.',
              stats: [StatEffect(StatKey.fitness, 6), StatEffect(StatKey.health, 3), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'I pulled a knee in week six and had to quit.',
              stats: [StatEffect(StatKey.health, -5), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'brood',
          label: 'Mope and eat ice cream',
          outcomes: [
            LifeOutcome(
              text: 'I spent months feeling stuck. The ice cream did not help.',
              stats: [StatEffect(StatKey.happiness, -6), StatEffect(StatKey.fitness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'health_checkup',
      title: 'Annual Checkup',
      description: 'My doctor\'s office has sent three reminders about a checkup.',
      minAge: 35,
      maxAge: 90,
      cooldownYears: 4,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'go_doctor',
          label: 'Book the appointment',
          requiresMoneyBase: 20000,
          outcomes: [
            LifeOutcome(
              weight: 7,
              text: 'All clear. The doctor told me to keep doing what I am doing.',
              moneyBase: -20000,
              stats: [StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'They caught something early. Treatment was easy because of it.',
              moneyBase: -20000,
              stats: [StatEffect(StatKey.health, 6)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Ignore the reminders',
          outcomes: [
            LifeOutcome(
              weight: 17,
              text: 'Nothing happened. Probably.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'A small problem grew into a big one before I noticed.',
              stats: [StatEffect(StatKey.health, -12), StatEffect(StatKey.happiness, -3)],
              addFlags: ['chronic_condition'],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'manage_condition',
      title: 'Living With It',
      description: 'My health condition flares up whenever I am stressed.',
      minAge: 30,
      maxAge: 110,
      cooldownYears: 4,
      requiredFlags: ['chronic_condition'],
      weight: 25,
      choices: [
        LifeChoice(
          id: 'follow_plan',
          label: 'Follow the treatment plan strictly',
          outcomes: [
            LifeOutcome(
              text: 'It is a chore, but I feel stronger.',
              moneyBase: -30000,
              stats: [StatEffect(StatKey.health, 4), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore_plan',
          label: 'Skip the pills when I feel fine',
          outcomes: [
            LifeOutcome(
              weight: 1,
              text: 'I felt fine until I did not.',
              stats: [StatEffect(StatKey.health, -7), StatEffect(StatKey.happiness, -3)],
            ),
            LifeOutcome(
              weight: 1,
              text: 'Nothing bad happened this year. I know I am gambling.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_needs_care',
      title: 'A Parent in Need',
      description: '{Role} {first} has been getting frail, and the family needs a plan.',
      minAge: 30,
      maxAge: 70,
      cooldownYears: 8,
      needsLivingParent: true,
      about: EventSubjectKind.parent,
      weight: 10,
      choices: [
        LifeChoice(
          id: 'care_myself',
          label: 'Take care of them myself',
          outcomes: [
            LifeOutcome(
              text: 'It is tiring, but the stories they tell me are priceless.',
              subjectRelation: 10,
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.health, -2), StatEffect(StatKey.willpower, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'hire_caregiver',
          label: 'Hire a professional caregiver',
          requiresMoneyBase: 200000,
          outcomes: [
            LifeOutcome(
              text: 'It costs a lot, but they are in good hands and I can breathe.',
              subjectRelation: 4,
              moneyBase: -200000,
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'visit_sometimes',
          label: 'Visit on holidays only',
          outcomes: [
            LifeOutcome(
              text: 'I told myself I was too busy. The guilt followed me home.',
              subjectRelation: -10,
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'investment_tip',
      title: 'A Hot Tip',
      description: 'A coworker swears they know the next big investment.',
      minAge: 25,
      maxAge: 75,
      cooldownYears: 6,
      weight: 10,
      choices: [
        LifeChoice(
          id: 'gamble',
          label: 'Put a big chunk into the hot tip',
          requiresMoneyBase: 100000,
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'It doubled in a few months. I felt like a genius.',
              moneyBase: 100000,
              stats: [StatEffect(StatKey.happiness, 5)],
            ),
            LifeOutcome(
              weight: 4,
              text: 'The price tanked and I sold in a panic.',
              moneyBase: -50000,
              stats: [StatEffect(StatKey.happiness, -4)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'It turned out to be a scam. Every cent vanished.',
              moneyBase: -100000,
              stats: [StatEffect(StatKey.happiness, -7), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'index_fund',
          label: 'Quietly put some in a boring index fund',
          requiresMoneyBase: 50000,
          outcomes: [
            LifeOutcome(
              weight: 17,
              text: 'Boring, steady growth. Just how I like it.',
              moneyBase: 10000,
              stats: [StatEffect(StatKey.willpower, 1)],
            ),
            LifeOutcome(
              weight: 3,
              text: 'The market dipped this year, but I held on.',
              moneyBase: -10000,
              stats: [StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore_tip',
          label: 'Smile and change the subject',
          outcomes: [
            LifeOutcome(
              text: 'I slept well, and never heard about that tip again.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    // ------------------------------------------------------------------ Senior
    LifeEventDefinition(
      id: 'retirement_decision',
      title: 'Retirement Day',
      description: 'My coworkers baked a cake and the boss asked what comes next.',
      minAge: 60,
      maxAge: 70,
      oncePerLife: true,
      weight: 60,
      choices: [
        LifeChoice(
          id: 'retire',
          label: 'Retire and enjoy life',
          outcomes: [
            LifeOutcome(
              text: 'Mornings are slow now, and I love every single one.',
              stats: [StatEffect(StatKey.happiness, 8), StatEffect(StatKey.fitness, -2)],
              addFlags: ['retired'],
            ),
          ],
        ),
        LifeChoice(
          id: 'keep_working',
          label: 'Keep working a few more years',
          outcomes: [
            LifeOutcome(
              text: 'The paycheck is nice. My knees are less excited.',
              moneyBase: 150000,
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.willpower, 2)],
              addFlags: ['works_in_old_age'],
            ),
          ],
        ),
        LifeChoice(
          id: 'small_business',
          label: 'Turn a hobby into a tiny business',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: 'People actually pay for my homemade jam. I am delighted.',
              moneyBase: 40000,
              stats: [StatEffect(StatKey.creativity, 4), StatEffect(StatKey.happiness, 4)],
            ),
            LifeOutcome(
              weight: 1,
              text: 'No one bought a single jar. My pantry is very full.',
              stats: [StatEffect(StatKey.happiness, -1), StatEffect(StatKey.creativity, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'fall_at_home',
      title: 'A Slippery Floor',
      description: 'I reached for something on the top shelf and the floor tilted.',
      minAge: 65,
      maxAge: 120,
      cooldownYears: 5,
      weight: 8,
      autoOutcomes: [
        LifeOutcome(
          weight: 5,
          text: 'I caught the counter just in time. I sat down for a while afterwards.',
          stats: [StatEffect(StatKey.luck, 1)],
        ),
        LifeOutcome(
          weight: 3,
          text: 'I fell and bruised everything I own.',
          stats: [StatEffect(StatKey.health, -4), StatEffect(StatKey.happiness, -2)],
        ),
        LifeOutcome(
          weight: 2,
          text: 'I broke my hip. Recovery will be long and slow.',
          moneyBase: -100000,
          stats: [StatEffect(StatKey.health, -15), StatEffect(StatKey.fitness, -6), StatEffect(StatKey.happiness, -5)],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'memoir',
      title: 'What To Do With My Time',
      description: 'The days feel long, and I have decades of stories to tell.',
      minAge: 60,
      maxAge: 110,
      oncePerLife: true,
      weight: 14,
      choices: [
        LifeChoice(
          id: 'write_memoir',
          label: 'Write my memoir',
          outcomes: [
            LifeOutcome(
              text: 'The words came easier than expected. My family cried reading it.',
              stats: [StatEffect(StatKey.creativity, 5), StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'teach_kids',
          label: 'Volunteer to tutor children',
          outcomes: [
            LifeOutcome(
              text: 'Their questions keep my mind sharp, and their laughter is contagious.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 5)],
            ),
          ],
        ),
        LifeChoice(
          id: 'relax',
          label: 'Do nothing. I earned it',
          narration: 'I did nothing, because I earned it.',
          outcomes: [
            LifeOutcome(
              text: 'A quiet porch, a warm cup of tea, and no schedule.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.health, 1), StatEffect(StatKey.fitness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'old_friends_reunion',
      title: 'Old Friends',
      description: 'An old friend tracked me down and invited me to a reunion.',
      minAge: 55,
      maxAge: 120,
      cooldownYears: 8,
      weight: 8,
      autoOutcomes: [
        LifeOutcome(
          text: 'We laughed until our sides hurt, and swapped our medical complaints too.',
          stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 1)],
        ),
      ],
    ),
    // ------------------------------------------------------ Stat-triggered
    LifeEventDefinition(
      id: 'feeling_down',
      title: 'A Heavy Season',
      description: 'Everything feels grey lately, and even small things take effort.',
      minAge: 13,
      maxAge: 120,
      cooldownYears: 3,
      statRequirements: [StatRequirement(StatKey.happiness, max: 25)],
      weight: 80,
      choices: [
        LifeChoice(
          id: 'talk',
          label: 'Talk to a friend, family member, or counselor',
          outcomes: [
            LifeOutcome(
              text: 'Saying it out loud lifted a weight I did not know I was carrying.',
              stats: [StatEffect(StatKey.happiness, 8), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'hobby',
          label: 'Throw myself into a hobby',
          outcomes: [
            LifeOutcome(
              text: 'Creating something gave my days some shape again.',
              stats: [StatEffect(StatKey.creativity, 3), StatEffect(StatKey.happiness, 4)],
            ),
          ],
        ),
        LifeChoice(
          id: 'push_through',
          label: 'Push through it alone',
          outcomes: [
            LifeOutcome(
              weight: 1,
              text: 'The fog slowly lifted on its own.',
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              weight: 1,
              text: 'Bottling it up made everything heavier.',
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.health, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'health_scare',
      title: 'A Worrying Symptom',
      description: 'My body has been sending warning signals for weeks.',
      minAge: 18,
      maxAge: 120,
      cooldownYears: 3,
      statRequirements: [StatRequirement(StatKey.health, max: 35)],
      weight: 80,
      choices: [
        LifeChoice(
          id: 'specialist',
          label: 'See a specialist right away',
          requiresMoneyBase: 30000,
          outcomes: [
            LifeOutcome(
              text: 'Treatment started in time, and I felt better within months.',
              moneyBase: -30000,
              stats: [StatEffect(StatKey.health, 12), StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'rest',
          label: 'Rest at home and change my habits',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Sleep, vegetables, and fewer excuses helped a lot.',
              stats: [StatEffect(StatKey.health, 6), StatEffect(StatKey.willpower, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text: 'It only helped a little. I should probably see someone.',
              stats: [StatEffect(StatKey.health, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore_symptom',
          label: 'Tell myself it is nothing',
          outcomes: [
            LifeOutcome(
              text: 'It got worse, as these things do.',
              stats: [StatEffect(StatKey.health, -8), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
  ];
}
