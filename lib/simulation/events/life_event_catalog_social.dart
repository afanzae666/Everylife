import '../../domain/event/life_event.dart';

/// New events about specific people: classmates, teachers, strangers,
/// coworkers and family. Each names the person and shows their avatar.
abstract final class LifeEventCatalogSocial {
  static const List<LifeEventDefinition> all = [
    LifeEventDefinition(
      id: 'school_new_friend',
      title: 'A New Friend',
      description: '{Name} plopped down next to me at lunch and asked, "Want to trade snacks?"',
      minAge: 6,
      maxAge: 17,
      about: EventSubjectKind.classmate,
      weight: 16,
      cooldownYears: 3,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'trade',
          label: 'Trade snacks',
          outcomes: [
            LifeOutcome(
              text: '{first} and I swapped a sad sandwich for a legendary cookie. We have been inseparable since.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 3)],
              subjectRelation: 14,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
          ],
        ),
        LifeChoice(
          id: 'share',
          label: 'Share my whole lunch',
          outcomes: [
            LifeOutcome(
              text: '{first} was stunned that someone was that generous. Instant friends.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
              moneyBase: -100,
              subjectRelation: 12,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} ate everything and wandered off. I am still hungry and slightly betrayed.',
              stats: [StatEffect(StatKey.happiness, -2)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'quiet',
          label: 'Stay quiet and eat alone',
          outcomes: [
            LifeOutcome(
              text: '{first} shrugged and left. Maybe next time.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, -1)],
              subjectRelation: -3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_study_buddy',
      title: 'Study Buddy',
      description: '{Name} asked if I wanted to study together before the big test.',
      minAge: 8,
      maxAge: 18,
      about: EventSubjectKind.classmate,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'accept',
          label: 'Study together',
          outcomes: [
            LifeOutcome(
              text: 'We quizzed each other until midnight. Both of us aced it.',
              weight: 3,
              stats: [StatEffect(StatKey.intelligence, 4), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 10,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: 'We mostly gossiped and ate chips. The test did not go great, but the chips were excellent.',
              weight: 2,
              stats: [StatEffect(StatKey.intelligence, 1), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 8,
            ),
          ],
        ),
        LifeChoice(
          id: 'decline',
          label: 'Study alone',
          outcomes: [
            LifeOutcome(
              text: 'I got a decent grade and zero distractions. {first} seemed a bit hurt.',
              stats: [StatEffect(StatKey.intelligence, 3)],
              subjectRelation: -4,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_lonely_lunch',
      title: 'Empty Seat',
      description: 'I was eating alone again when I noticed {name} sitting by themselves too.',
      minAge: 7,
      maxAge: 18,
      about: EventSubjectKind.classmate,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'join',
          label: 'Go sit with {first}',
          outcomes: [
            LifeOutcome(
              text: 'It was awkward for about four minutes, then we found out we love the same show.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 3)],
              subjectRelation: 14,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} was not in the mood to talk. I ate in respectful silence.',
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'wave',
          label: 'Just wave and keep going',
          outcomes: [
            LifeOutcome(
              text: 'A wave is better than nothing, right? I still felt a little bad.',
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: 1,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_group_project',
      title: 'Group Project',
      description: 'The teacher paired me with {name} for a group project.',
      minAge: 8,
      maxAge: 18,
      about: EventSubjectKind.classmate,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'lead',
          label: 'Take charge',
          outcomes: [
            LifeOutcome(
              text: 'I made a plan and {first} followed it. We got an A and a mild lecture about bossiness.',
              weight: 3,
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.willpower, 2)],
              subjectRelation: 6,
            ),
            LifeOutcome(
              text: 'I over-managed, {first} got annoyed, and we argued over font choices.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.charisma, -1)],
              subjectRelation: -6,
            ),
          ],
        ),
        LifeChoice(
          id: 'split',
          label: 'Split the work evenly',
          outcomes: [
            LifeOutcome(
              text: 'Fair and simple. We both did our half and high-fived at the end.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 8,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
          ],
        ),
        LifeChoice(
          id: 'slack',
          label: 'Let {first} do most of it',
          outcomes: [
            LifeOutcome(
              text: 'It worked, but {first} knows exactly what I did. Their silence is loud.',
              stats: [StatEffect(StatKey.intelligence, -1), StatEffect(StatKey.charisma, -3)],
              subjectRelation: -12,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_best_friend_fight',
      title: 'Friendship Crack',
      description: 'I had a loud argument with {name}, who I thought was my friend.',
      minAge: 8,
      maxAge: 18,
      about: EventSubjectKind.classmate,
      weight: 8,
      cooldownYears: 5,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'apologize',
          label: 'Apologize first',
          outcomes: [
            LifeOutcome(
              text: 'Swallowing my pride was painful, but {first} laughed and hugged it out.',
              weight: 4,
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 2)],
              subjectRelation: 12,
            ),
            LifeOutcome(
              text: '{first} needed more time. We are in the cold-war stage.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -2)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'wait',
          label: 'Wait for {first} to come around',
          outcomes: [
            LifeOutcome(
              text: 'Three weeks of silence. Eventually {first} sent a meme and all was forgiven.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: 4,
            ),
            LifeOutcome(
              text: 'We drifted apart and that was that.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -4)],
              subjectRelation: -15,
            ),
          ],
        ),
        LifeChoice(
          id: 'rival',
          label: 'Make it a feud',
          outcomes: [
            LifeOutcome(
              text: 'I started a rivalry. Honestly it made school more exciting, but exhausting.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, -3)],
              subjectRelation: -20,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_birthday_invite',
      title: 'Birthday Invite',
      description: '{Name} handed me a glittery invitation to {his} birthday party.',
      minAge: 6,
      maxAge: 14,
      about: EventSubjectKind.classmate,
      weight: 12,
      cooldownYears: 4,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Go to the party',
          outcomes: [
            LifeOutcome(
              text: 'There was cake, a clown who was clearly done with life, and a sugar crash I will never forget.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 2)],
              moneyBase: -300,
              subjectRelation: 10,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: 'The party was boring and I spent it hiding in the bathroom. {first} noticed.',
              stats: [StatEffect(StatKey.happiness, -1)],
              moneyBase: -300,
              subjectRelation: -2,
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Politely decline',
          outcomes: [
            LifeOutcome(
              text: '{first} said it was fine, but {his} smile said otherwise.',
              stats: [StatEffect(StatKey.happiness, 0)],
              subjectRelation: -6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_bully_shove',
      title: 'Hallway Shove',
      description: '{Name} slammed into me in the hallway and everybody laughed.',
      minAge: 7,
      maxAge: 16,
      about: EventSubjectKind.classmate,
      weight: 14,
      cooldownYears: 4,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'shove',
          label: 'Shove back',
          outcomes: [
            LifeOutcome(
              text: 'A teacher saw only my part of it. Detention, but {first} thinks twice now.',
              weight: 3,
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, -3)],
              subjectRelation: -8,
            ),
            LifeOutcome(
              text: '{first} was stronger than expected. I ended up on the floor, again.',
              weight: 2,
              stats: [StatEffect(StatKey.health, -5), StatEffect(StatKey.happiness, -5)],
              subjectRelation: -8,
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'report',
          label: 'Report it to a teacher',
          outcomes: [
            LifeOutcome(
              text: '{first} got a stern talking-to and left me alone for a while.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 3)],
              subjectRelation: -10,
            ),
            LifeOutcome(
              text: 'Nothing happened except {first} calling me a snitch for weeks.',
              weight: 2,
              stats: [StatEffect(StatKey.charisma, -3), StatEffect(StatKey.happiness, -3)],
              subjectRelation: -10,
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Pretend it never happened',
          outcomes: [
            LifeOutcome(
              text: 'I walked away with burning ears. It did not stop.',
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.willpower, -2)],
              subjectRelation: -4,
              addFlags: ['bullied'],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_bully_rumor',
      title: 'Nasty Rumor',
      description: '{Name} started a rumor about me, and it is spreading around school.',
      minAge: 9,
      maxAge: 18,
      about: EventSubjectKind.classmate,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'confront',
          label: 'Confront {first} in front of everyone',
          outcomes: [
            LifeOutcome(
              text: 'I called {first} out and the rumor lost its power. Bold, but it worked.',
              weight: 3,
              stats: [StatEffect(StatKey.willpower, 4), StatEffect(StatKey.charisma, 3)],
              subjectRelation: -10,
            ),
            LifeOutcome(
              text: 'It escalated into a shouting match. Now there are two rumors.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.charisma, -2)],
              subjectRelation: -10,
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'laugh',
          label: 'Laugh it off',
          outcomes: [
            LifeOutcome(
              text: 'My friends joined in laughing. The rumor died of boredom.',
              weight: 3,
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 2)],
              subjectRelation: -3,
            ),
            LifeOutcome(
              text: 'Laughing did not help. It hurt more than I let on.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -5)],
              subjectRelation: -3,
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'tell',
          label: 'Tell the counselor',
          outcomes: [
            LifeOutcome(
              text: 'The counselor handled it quietly. Things calmed down.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, 1)],
              subjectRelation: -8,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_bully_lunch_money',
      title: 'Lunch Money',
      description: '{Name} cornered me and demanded my lunch money.',
      minAge: 7,
      maxAge: 15,
      about: EventSubjectKind.classmate,
      weight: 9,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'pay',
          label: 'Hand it over',
          outcomes: [
            LifeOutcome(
              text: 'I went hungry that day, and the next, and the next.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.health, -2)],
              moneyBase: -200,
              subjectRelation: -4,
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'refuse',
          label: 'Refuse and walk away',
          outcomes: [
            LifeOutcome(
              text: '{first} looked surprised. I got away with it this time.',
              weight: 3,
              stats: [StatEffect(StatKey.willpower, 4), StatEffect(StatKey.happiness, 2)],
              subjectRelation: -6,
            ),
            LifeOutcome(
              text: '{first} made me regret it. Bruised, but I kept my money.',
              weight: 2,
              stats: [StatEffect(StatKey.health, -5), StatEffect(StatKey.willpower, 3)],
              subjectRelation: -8,
              addFlags: ['bullied'],
            ),
          ],
        ),
        LifeChoice(
          id: 'teacher',
          label: 'Tell a teacher right away',
          outcomes: [
            LifeOutcome(
              text: '{first} got a week of detention. Justice, school-style.',
              stats: [StatEffect(StatKey.happiness, 4)],
              subjectRelation: -10,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_bully_witness',
      title: 'Someone Else Is Getting Bullied',
      description: 'I saw other kids pick on {name} behind the gym.',
      minAge: 8,
      maxAge: 17,
      about: EventSubjectKind.classmate,
      weight: 9,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'help',
          label: 'Step in and help',
          outcomes: [
            LifeOutcome(
              text: '{first} looked at me like I was a superhero. We became friends.',
              weight: 3,
              stats: [StatEffect(StatKey.willpower, 4), StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 16,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: 'I got shoved around a bit too, but {first} was grateful.',
              weight: 2,
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.willpower, 3)],
              subjectRelation: 12,
            ),
          ],
        ),
        LifeChoice(
          id: 'adult',
          label: 'Go get a teacher',
          outcomes: [
            LifeOutcome(
              text: 'A teacher broke it up. {first} mouthed a quiet thank you.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 2)],
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'walk',
          label: 'Keep walking',
          outcomes: [
            LifeOutcome(
              text: 'I told myself it was not my business. The guilt lasted a while.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.willpower, -2)],
              subjectRelation: -2,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_cheat_offer',
      title: 'Copy My Homework?',
      description: '{Name} begged me to let {him} copy my homework.',
      minAge: 8,
      maxAge: 18,
      about: EventSubjectKind.classmate,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'allow',
          label: 'Let {first} copy',
          outcomes: [
            LifeOutcome(
              text: '{first} owes me one. Neither of us got caught.',
              weight: 3,
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.willpower, -1)],
              subjectRelation: 8,
            ),
            LifeOutcome(
              text: 'The teacher noticed identical mistakes. We both got zeros.',
              weight: 2,
              stats: [StatEffect(StatKey.intelligence, -2), StatEffect(StatKey.happiness, -4)],
              subjectRelation: -2,
            ),
          ],
        ),
        LifeChoice(
          id: 'refuse',
          label: 'Say no',
          outcomes: [
            LifeOutcome(
              text: '{first} sulked, but I slept well.',
              stats: [StatEffect(StatKey.willpower, 3)],
              subjectRelation: -4,
            ),
          ],
        ),
        LifeChoice(
          id: 'teach',
          label: 'Offer to explain it instead',
          outcomes: [
            LifeOutcome(
              text: 'It took an hour, but {first} finally got it. A proud moment.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 10,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_prank',
      title: 'The Great Prank',
      description: '{Name} whispered a plan: put a rubber snake in the teacher\'s desk.',
      minAge: 8,
      maxAge: 16,
      about: EventSubjectKind.classmate,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'join',
          label: 'Join in',
          outcomes: [
            LifeOutcome(
              text: 'The teacher screamed so loud that the whole floor heard it. Legendary. We were never caught.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 6), StatEffect(StatKey.charisma, 3)],
              subjectRelation: 12,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: 'We were caught in about nine seconds. Detention for both.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, 1)],
              subjectRelation: 4,
            ),
          ],
        ),
        LifeChoice(
          id: 'lookout',
          label: 'Be the lookout',
          outcomes: [
            LifeOutcome(
              text: 'I stood guard like a professional. {first} was impressed.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 1)],
              subjectRelation: 6,
            ),
          ],
        ),
        LifeChoice(
          id: 'refuse',
          label: 'Refuse',
          outcomes: [
            LifeOutcome(
              text: '{first} called me boring. I was fine with that.',
              stats: [StatEffect(StatKey.willpower, 2)],
              subjectRelation: -3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_classmate_crush',
      title: 'Butterflies',
      description: '{Name} smiled at me during class, and my brain stopped working.',
      minAge: 12,
      maxAge: 18,
      about: EventSubjectKind.classmate,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'talk',
          label: 'Start a conversation',
          outcomes: [
            LifeOutcome(
              text: 'We talked until the bell rang. Things are looking promising.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 3)],
              subjectRelation: 14,
            ),
            LifeOutcome(
              text: 'I said something weird about my cat. {first} laughed, kindly.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -1), StatEffect(StatKey.charisma, -1)],
              subjectRelation: 3,
            ),
          ],
        ),
        LifeChoice(
          id: 'note',
          label: 'Pass a note',
          outcomes: [
            LifeOutcome(
              text: '{first} wrote back. My heart did gymnastics.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.creativity, 2)],
              subjectRelation: 10,
            ),
            LifeOutcome(
              text: 'The note was intercepted by the whole class. I wish for the ground to swallow me.',
              stats: [StatEffect(StatKey.happiness, -6), StatEffect(StatKey.charisma, -2)],
              subjectRelation: -3,
            ),
          ],
        ),
        LifeChoice(
          id: 'hide',
          label: 'Hide behind my textbook',
          outcomes: [
            LifeOutcome(
              text: 'Safe, embarrassed, and still wondering what could have been.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_sports_pick',
      title: 'Picking Teams',
      description: 'In PE, {name} was team captain, and I was waiting to be picked.',
      minAge: 7,
      maxAge: 16,
      about: EventSubjectKind.classmate,
      weight: 12,
      cooldownYears: 5,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'pick',
          label: 'Hope to get picked',
          outcomes: [
            LifeOutcome(
              text: '{first} picked me second! I played way better than expected.',
              weight: 2,
              stats: [StatEffect(StatKey.fitness, 3), StatEffect(StatKey.happiness, 4)],
              subjectRelation: 8,
            ),
            LifeOutcome(
              text: 'I was picked last. Again. The bench and I are old friends.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -4)],
              subjectRelation: -1,
            ),
          ],
        ),
        LifeChoice(
          id: 'volunteer',
          label: 'Volunteer as goalkeeper',
          outcomes: [
            LifeOutcome(
              text: 'I saved three goals and became a hero for a day.',
              stats: [StatEffect(StatKey.fitness, 3), StatEffect(StatKey.charisma, 3)],
              subjectRelation: 8,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_secret',
      title: 'A Secret',
      description: '{Name} told me a secret and made me swear not to tell anyone.',
      minAge: 8,
      maxAge: 17,
      about: EventSubjectKind.classmate,
      weight: 8,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'keep',
          label: 'Keep it to myself',
          outcomes: [
            LifeOutcome(
              text: 'It was heavy, but {first} noticed and trusted me even more.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, 2)],
              subjectRelation: 14,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
          ],
        ),
        LifeChoice(
          id: 'tell',
          label: 'Tell one other friend',
          outcomes: [
            LifeOutcome(
              text: 'The secret was out by lunch. {first} will never trust me again.',
              stats: [StatEffect(StatKey.charisma, -4), StatEffect(StatKey.happiness, -3)],
              subjectRelation: -25,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_teacher_praise',
      title: 'Teacher\'s Pet?',
      description: '{Role} {name} praised my work in front of the whole class.',
      minAge: 6,
      maxAge: 18,
      about: EventSubjectKind.teacher,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'humble',
          label: 'Smile and say thanks',
          outcomes: [
            LifeOutcome(
              text: 'Some kids rolled their eyes, but I felt great.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 4)],
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'bask',
          label: 'Soak it in dramatically',
          outcomes: [
            LifeOutcome(
              text: 'I took a bow. The class laughed, and {role} laughed too.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_teacher_detention',
      title: 'Detention',
      description: '{Role} {name} handed me a detention slip for talking in class.',
      minAge: 7,
      maxAge: 17,
      about: EventSubjectKind.teacher,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'accept',
          label: 'Accept it quietly',
          outcomes: [
            LifeOutcome(
              text: 'I sat there for an hour and read a book. It was weirdly peaceful.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.intelligence, 1)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'argue',
          label: 'Argue that it was unfair',
          outcomes: [
            LifeOutcome(
              text: '{Role} was not amused. The slip became two.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, 1)],
              subjectRelation: -8,
            ),
            LifeOutcome(
              text: 'My argument was so good that {role} cancelled it. Respect.',
              stats: [StatEffect(StatKey.charisma, 4)],
              subjectRelation: 6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_teacher_help',
      title: 'Extra Help',
      description: '{Role} {name} noticed I was struggling and offered to help after class.',
      minAge: 6,
      maxAge: 18,
      about: EventSubjectKind.teacher,
      weight: 11,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'accept',
          label: 'Gratefully accept',
          outcomes: [
            LifeOutcome(
              text: 'A few sessions later, things finally clicked. Thank you, {first}.',
              stats: [StatEffect(StatKey.intelligence, 5), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 12,
            ),
          ],
        ),
        LifeChoice(
          id: 'pride',
          label: 'Say I am fine',
          outcomes: [
            LifeOutcome(
              text: 'I struggled on my own. It built character but not grades.',
              stats: [StatEffect(StatKey.intelligence, 1), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, -2)],
              subjectRelation: -3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_teacher_late',
      title: 'Missing Homework',
      description: '{Role} {name} asked where my homework was. I had absolutely nothing.',
      minAge: 7,
      maxAge: 18,
      about: EventSubjectKind.teacher,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'truth',
          label: 'Admit I forgot',
          outcomes: [
            LifeOutcome(
              text: '{Role} respected the honesty and gave me one more day.',
              stats: [StatEffect(StatKey.willpower, 3)],
              subjectRelation: 6,
            ),
          ],
        ),
        LifeChoice(
          id: 'excuse',
          label: 'Blame my dog',
          outcomes: [
            LifeOutcome(
              text: '{Role} raised an eyebrow, since I do not own a dog. Zero points.',
              weight: 3,
              stats: [StatEffect(StatKey.charisma, -2), StatEffect(StatKey.intelligence, -2)],
              subjectRelation: -8,
            ),
            LifeOutcome(
              text: 'The dog excuse worked. I do not know how.',
              stats: [StatEffect(StatKey.luck, 3)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'rush',
          label: 'Promise it by tomorrow',
          outcomes: [
            LifeOutcome(
              text: 'I stayed up all night, but delivered. {Role} gave a rare nod.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.health, -2), StatEffect(StatKey.willpower, 2)],
              subjectRelation: 6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_teacher_recommend',
      title: 'A Letter of Recommendation',
      description: '{Role} {name} offered to write me a recommendation letter.',
      minAge: 15,
      maxAge: 18,
      about: EventSubjectKind.teacher,
      weight: 9,
      cooldownYears: 10,
      oncePerLife: true,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'thanks',
          label: 'Accept with deep gratitude',
          outcomes: [
            LifeOutcome(
              text: 'The letter was glowing. My future looks brighter.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.luck, 3), StatEffect(StatKey.happiness, 4)],
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'gift',
          label: 'Bring {him} a thank-you gift',
          outcomes: [
            LifeOutcome(
              text: '{Role} was touched by the small gesture.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
              moneyBase: -1000,
              subjectRelation: 14,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_teacher_scolding',
      title: 'Caught Sleeping',
      description: '{Role} {name} caught me dozing off in class.',
      minAge: 7,
      maxAge: 18,
      about: EventSubjectKind.teacher,
      weight: 12,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'sorry',
          label: 'Apologize and sit up',
          outcomes: [
            LifeOutcome(
              text: '{Role} let it slide this once.',
              stats: [StatEffect(StatKey.willpower, 1)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'joke',
          label: 'Joke that the lesson was a lullaby',
          outcomes: [
            LifeOutcome(
              text: 'The class howled. {Role} did not, and sent me to the principal.',
              weight: 2,
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, -2)],
              subjectRelation: -8,
            ),
            LifeOutcome(
              text: 'Even {role} cracked a smile.',
              stats: [StatEffect(StatKey.charisma, 4), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 4,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_prof_research',
      title: 'Research Offer',
      description: '{Role} {name} said I have potential and invited me to join {his} research project.',
      minAge: 18,
      maxAge: 26,
      about: EventSubjectKind.teacher,
      weight: 8,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'join',
          label: 'Join the project',
          outcomes: [
            LifeOutcome(
              text: 'Long hours, tiny salary, and priceless experience.',
              weight: 3,
              stats: [StatEffect(StatKey.intelligence, 5), StatEffect(StatKey.willpower, 3), StatEffect(StatKey.health, -2)],
              moneyBase: 300000,
              subjectRelation: 12,
            ),
            LifeOutcome(
              text: 'The project collapsed. At least the coffee was free.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.intelligence, 2)],
              subjectRelation: 4,
            ),
          ],
        ),
        LifeChoice(
          id: 'decline',
          label: 'Politely decline',
          outcomes: [
            LifeOutcome(
              text: 'I wanted a social life. {Role} understood.',
              stats: [StatEffect(StatKey.happiness, 3)],
              subjectRelation: -2,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_study_group',
      title: 'Study Group',
      description: '{Name} invited me to join a study group that meets at midnight.',
      minAge: 18,
      maxAge: 26,
      about: EventSubjectKind.classmate,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'join',
          label: 'Join the group',
          outcomes: [
            LifeOutcome(
              text: 'We learned things and shared pizza. Mostly pizza.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
              moneyBase: -500,
              subjectRelation: 12,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
          ],
        ),
        LifeChoice(
          id: 'solo',
          label: 'Study alone',
          outcomes: [
            LifeOutcome(
              text: 'Quiet and efficient, but a bit lonely.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, -2)],
              subjectRelation: -2,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_party_friend',
      title: 'Dorm Party',
      description: '{Name} dragged me to a dorm party that everyone swears is legendary.',
      minAge: 18,
      maxAge: 25,
      about: EventSubjectKind.classmate,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'dance',
          label: 'Dance like nobody is watching',
          outcomes: [
            LifeOutcome(
              text: 'Everybody was watching. It was the best night of my semester.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 6), StatEffect(StatKey.charisma, 4), StatEffect(StatKey.health, -1)],
              subjectRelation: 12,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: 'I tripped over a speaker. Someone filmed it.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.charisma, -3)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'corner',
          label: 'Hide in a corner with snacks',
          outcomes: [
            LifeOutcome(
              text: 'I met no one, but the snack table and I are now best friends.',
              stats: [StatEffect(StatKey.happiness, 1)],
              subjectRelation: 3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_park_friend',
      title: 'New Kid at the Park',
      description: 'A kid I had never seen, {name}, asked if I wanted to play on the swings.',
      minAge: 4,
      maxAge: 12,
      about: EventSubjectKind.stranger,
      weight: 14,
      cooldownYears: 3,
      choices: [
        LifeChoice(
          id: 'play',
          label: 'Play together',
          outcomes: [
            LifeOutcome(
              text: 'We played until the streetlights came on. A new friend!',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 6), StatEffect(StatKey.charisma, 2)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} had to leave after five minutes. Maybe we will meet again.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'shy',
          label: 'Hide behind my parent',
          outcomes: [
            LifeOutcome(
              text: '{first} waved and left. I felt shy and a little sad.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_new_neighbor',
      title: 'The New Neighbor',
      description: 'A new neighbor, {name}, moved in next door and waved at me.',
      minAge: 8,
      maxAge: 70,
      about: EventSubjectKind.stranger,
      weight: 12,
      cooldownYears: 8,
      choices: [
        LifeChoice(
          id: 'welcome',
          label: 'Bring a welcome gift',
          outcomes: [
            LifeOutcome(
              text: '{first} loved it. We have been chatting over the fence ever since.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 3)],
              moneyBase: -800,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} is allergic to the cookies. Not a great first impression.',
              stats: [StatEffect(StatKey.happiness, -1)],
              moneyBase: -800,
            ),
          ],
        ),
        LifeChoice(
          id: 'wave',
          label: 'Just wave back',
          outcomes: [
            LifeOutcome(
              text: 'Friendly enough. Maybe more later.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'avoid',
          label: 'Avoid eye contact',
          outcomes: [
            LifeOutcome(
              text: 'Turns out avoiding a neighbor requires a lot of planning.',
              stats: [StatEffect(StatKey.happiness, -1), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_online_friend',
      title: 'Online Friend',
      description: 'A player named {name} kept joining my online matches, and we started chatting.',
      minAge: 11,
      maxAge: 60,
      about: EventSubjectKind.stranger,
      weight: 12,
      cooldownYears: 5,
      choices: [
        LifeChoice(
          id: 'friend',
          label: 'Add {him} as a friend',
          outcomes: [
            LifeOutcome(
              text: 'We play every evening now. Voice chat is chaos, but the fun kind.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 2)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} turned out to be a toxic teammate. Blocked and relieved.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Ignore the messages',
          outcomes: [
            LifeOutcome(
              text: 'I stayed safe, but missed a potential friendship.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_bus_chat',
      title: 'Bus Conversation',
      description: '{Name} sat next to me on the bus and said, "Great jacket."',
      minAge: 14,
      maxAge: 80,
      about: EventSubjectKind.stranger,
      weight: 11,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'chat',
          label: 'Start a conversation',
          outcomes: [
            LifeOutcome(
              text: 'We talked all the way to my stop. We swapped numbers.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 3)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} was just being polite. Awkward silence for six stops.',
              stats: [StatEffect(StatKey.happiness, -1), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'headphones',
          label: 'Put on my headphones',
          outcomes: [
            LifeOutcome(
              text: 'A safe move. Solitude is peaceful too.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_gym_buddy',
      title: 'Gym Buddy',
      description: '{Name} at the gym offered to spot me on my set.',
      minAge: 16,
      maxAge: 65,
      about: EventSubjectKind.stranger,
      weight: 10,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'accept',
          label: 'Say yes',
          outcomes: [
            LifeOutcome(
              text: 'A solid spot and a new workout partner.',
              weight: 3,
              stats: [StatEffect(StatKey.fitness, 3), StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 2)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} spent the whole time criticizing my form. Helpful, but painful.',
              stats: [StatEffect(StatKey.fitness, 2), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'decline',
          label: 'Say I am fine',
          outcomes: [
            LifeOutcome(
              text: 'I struggled alone, but I made it.',
              stats: [StatEffect(StatKey.fitness, 1), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_cafe_chat',
      title: 'Cafe Conversation',
      description: 'A stranger, {name}, asked if the seat across from me was free at the cafe.',
      minAge: 16,
      maxAge: 80,
      about: EventSubjectKind.stranger,
      weight: 10,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'invite',
          label: 'Invite {him} to sit',
          outcomes: [
            LifeOutcome(
              text: 'We talked for two hours. I think I just made a new friend.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 3)],
              moneyBase: -400,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} just wanted the chair. We sat in silence.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'decline',
          label: 'Say it is taken',
          outcomes: [
            LifeOutcome(
              text: 'I lied about an imaginary friend. I felt a bit silly.',
              stats: [StatEffect(StatKey.happiness, -1), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_lost_wallet',
      title: 'Lost Wallet',
      description: 'I found a wallet on the street. ID says its owner is {name}.',
      minAge: 12,
      maxAge: 80,
      about: EventSubjectKind.stranger,
      weight: 8,
      cooldownYears: 10,
      choices: [
        LifeChoice(
          id: 'return',
          label: 'Track {him} down and return it',
          outcomes: [
            LifeOutcome(
              text: '{first} was overjoyed, treated me to lunch and became a friend.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 3), StatEffect(StatKey.luck, 2)],
              moneyBase: 800,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} thanked me and hurried away. Good karma, though.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'keep',
          label: 'Keep the cash',
          outcomes: [
            LifeOutcome(
              text: 'I felt guilty about it for weeks.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, -3)],
              moneyBase: 2500,
            ),
            LifeOutcome(
              text: 'I got caught on camera. That was embarrassing.',
              stats: [StatEffect(StatKey.charisma, -4), StatEffect(StatKey.happiness, -5)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_flat_tire',
      title: 'Roadside Trouble',
      description: '{Name} was stuck on the side of the road with a flat tire.',
      minAge: 18,
      maxAge: 75,
      about: EventSubjectKind.stranger,
      weight: 8,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'help',
          label: 'Stop and help',
          outcomes: [
            LifeOutcome(
              text: 'We changed the tire together. {first} insisted on exchanging numbers.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2), StatEffect(StatKey.willpower, 2)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: 'It took forever and I got my shirt ruined. But {first} was thankful.',
              stats: [StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'call',
          label: 'Call a tow truck for {him}',
          outcomes: [
            LifeOutcome(
              text: 'A small act of kindness that I never heard about again.',
              stats: [StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'drive',
          label: 'Drive past',
          outcomes: [
            LifeOutcome(
              text: 'I told myself someone else would help. The guilt followed me for miles.',
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_scam',
      title: 'Too Friendly',
      description: '{Name}, a very charming stranger, asked me for a small "temporary" loan.',
      minAge: 18,
      maxAge: 80,
      about: EventSubjectKind.stranger,
      weight: 8,
      cooldownYears: 8,
      choices: [
        LifeChoice(
          id: 'lend',
          label: 'Lend the money',
          outcomes: [
            LifeOutcome(
              text: '{first} vanished, and so did my cash.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.willpower, -2)],
              moneyBase: -5000,
            ),
            LifeOutcome(
              text: '{first} paid me back with interest. Wow.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.luck, 3)],
              moneyBase: 500,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
          ],
        ),
        LifeChoice(
          id: 'refuse',
          label: 'Say no politely',
          outcomes: [
            LifeOutcome(
              text: '{first} left immediately. That says a lot.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.intelligence, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_concert_friend',
      title: 'Concert Fan',
      description: '{Name} and I realized we were singing every lyric at the concert.',
      minAge: 16,
      maxAge: 60,
      about: EventSubjectKind.stranger,
      weight: 9,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'hang',
          label: 'Hang out after the show',
          outcomes: [
            LifeOutcome(
              text: 'We screamed the encore together. A friend for life.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 6), StatEffect(StatKey.charisma, 3)],
              moneyBase: -1500,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} had to leave early. A fun memory anyway.',
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'leave',
          label: 'Say goodbye and go home',
          outcomes: [
            LifeOutcome(
              text: 'A great night, but a missed opportunity.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_dog_walk',
      title: 'Dog Walker',
      description: '{Name}\'s dog tugged me into a conversation at the park.',
      minAge: 10,
      maxAge: 85,
      about: EventSubjectKind.stranger,
      weight: 9,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'pet',
          label: 'Pet the dog and chat',
          outcomes: [
            LifeOutcome(
              text: 'The dog loved me and {first} liked me too. We now walk together on weekends.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.fitness, 2)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: 'The dog slobbered on my shirt. {first} apologized endlessly.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'politely',
          label: 'Politely continue on my way',
          outcomes: [
            LifeOutcome(
              text: 'Dogs are better than people sometimes. I walked on, feeling slightly empty.',
              stats: [StatEffect(StatKey.happiness, 0)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'stranger_travel_friend',
      title: 'Hostel Buddy',
      description: '{Name} in my hostel dorm invited me to explore the city together.',
      minAge: 19,
      maxAge: 60,
      about: EventSubjectKind.stranger,
      weight: 7,
      cooldownYears: 5,
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Go exploring',
          outcomes: [
            LifeOutcome(
              text: 'We got lost, found a hidden cafe and made stories I will tell forever.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 6), StatEffect(StatKey.charisma, 3)],
              moneyBase: -3000,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} walked too fast and I was exhausted. Still fun.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.fitness, 1)],
              moneyBase: -3000,
            ),
          ],
        ),
        LifeChoice(
          id: 'stay',
          label: 'Stay at the hostel',
          outcomes: [
            LifeOutcome(
              text: 'A quiet day with a book. Peaceful but uneventful.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_new_coworker',
      title: 'The New Hire',
      description: '{Name} just started at my workplace and looked completely lost.',
      minAge: 18,
      maxAge: 65,
      about: EventSubjectKind.coworker,
      weight: 12,
      cooldownYears: 3,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'help',
          label: 'Show {him} around',
          outcomes: [
            LifeOutcome(
              text: '{first} was so relieved. Lunch together became our daily routine.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 3)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} turned out to be a gossip. I regret the tour.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Mind my own work',
          outcomes: [
            LifeOutcome(
              text: 'I stayed productive. {first} found someone else to ask.',
              stats: [StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_credit_stealer',
      title: 'Stolen Credit',
      description: '{Name} presented my idea in the meeting as if it were {his} own.',
      minAge: 20,
      maxAge: 65,
      about: EventSubjectKind.coworker,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'speak',
          label: 'Speak up right then',
          outcomes: [
            LifeOutcome(
              text: 'I corrected {first} in front of everyone. Tense, but my boss noticed.',
              weight: 3,
              stats: [StatEffect(StatKey.willpower, 4), StatEffect(StatKey.charisma, 3)],
            ),
            LifeOutcome(
              text: 'It turned into an argument. Neither of us looked great.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.charisma, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'boss',
          label: 'Tell my boss privately',
          outcomes: [
            LifeOutcome(
              text: 'My boss made sure the credit went where it should.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'swallow',
          label: 'Swallow my pride',
          outcomes: [
            LifeOutcome(
              text: 'I stewed in silence for weeks.',
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.willpower, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_lunch_buddy',
      title: 'Lunch Invitation',
      description: '{Name} from the office asked if I wanted to grab lunch.',
      minAge: 18,
      maxAge: 65,
      about: EventSubjectKind.coworker,
      weight: 12,
      cooldownYears: 4,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Go along',
          outcomes: [
            LifeOutcome(
              text: 'Good food, better gossip. I like {first} more than I expected.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
              moneyBase: -1200,
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
            LifeOutcome(
              text: '{first} talked about work the whole time. Not exactly relaxing.',
              stats: [StatEffect(StatKey.happiness, -1)],
              moneyBase: -1200,
            ),
          ],
        ),
        LifeChoice(
          id: 'desk',
          label: 'Eat at my desk',
          outcomes: [
            LifeOutcome(
              text: 'A sad salad and a spreadsheet. Efficient, I guess.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_mentor',
      title: 'Unofficial Mentor',
      description: '{Name} offered to show me the unwritten rules of the office.',
      minAge: 18,
      maxAge: 50,
      about: EventSubjectKind.coworker,
      weight: 9,
      cooldownYears: 8,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Take notes',
          outcomes: [
            LifeOutcome(
              text: '{first}\'s advice saved me from three disasters already.',
              weight: 3,
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              text: 'Half the advice was outdated, but the other half was gold.',
              weight: 2,
              stats: [StatEffect(StatKey.intelligence, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'own',
          label: 'Figure it out myself',
          outcomes: [
            LifeOutcome(
              text: 'I learned the hard way. It took a while.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_gossip',
      title: 'Office Gossip',
      description: '{Name} leaned over and whispered some juicy gossip about our boss.',
      minAge: 18,
      maxAge: 65,
      about: EventSubjectKind.coworker,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Listen with interest',
          outcomes: [
            LifeOutcome(
              text: 'It was entertaining, until I realized the boss was standing behind me.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.charisma, -2)],
            ),
            LifeOutcome(
              text: 'I learned a lot, and {first} and I grew closer.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, 3)],
              makesFriend: true,
              addFlags: ['made_friend'],
            ),
          ],
        ),
        LifeChoice(
          id: 'shut',
          label: 'Change the subject',
          outcomes: [
            LifeOutcome(
              text: '{first} looked disappointed, but I earned some respect.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_cake',
      title: 'Birthday Cake',
      description: '{Name} brought a cake for the office to celebrate {his} birthday.',
      minAge: 18,
      maxAge: 65,
      about: EventSubjectKind.coworker,
      weight: 9,
      cooldownYears: 3,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'sing',
          label: 'Lead the birthday song',
          outcomes: [
            LifeOutcome(
              text: 'My terrible singing made {first} laugh so hard {he} cried. A great moment.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'eat',
          label: 'Quietly take two slices',
          outcomes: [
            LifeOutcome(
              text: 'I was not seen. The cake was very good.',
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_advice',
      title: 'Parental Advice',
      description: '{Role} {first} pulled me aside for a serious talk.',
      minAge: 10,
      maxAge: 40,
      about: EventSubjectKind.parent,
      weight: 11,
      cooldownYears: 4,
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Listen carefully',
          outcomes: [
            LifeOutcome(
              text: 'It sounded like a lecture, but there was real wisdom in it.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, 2)],
              subjectRelation: 8,
            ),
          ],
        ),
        LifeChoice(
          id: 'eyeroll',
          label: 'Roll my eyes',
          outcomes: [
            LifeOutcome(
              text: '{first} sighed deeply. The atmosphere got heavy.',
              stats: [StatEffect(StatKey.happiness, -2)],
              subjectRelation: -6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_embarrass',
      title: 'Embarrassing Parent',
      description: '{Role} {first} showed up at my school and shouted my nickname across the yard.',
      minAge: 7,
      maxAge: 15,
      about: EventSubjectKind.parent,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'laugh',
          label: 'Laugh it off',
          outcomes: [
            LifeOutcome(
              text: 'Everyone cracked up. Somehow it made me more popular.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 6,
            ),
          ],
        ),
        LifeChoice(
          id: 'mortified',
          label: 'Pretend I do not know {him}',
          outcomes: [
            LifeOutcome(
              text: '{first} looked hurt. I felt guilty for days.',
              stats: [StatEffect(StatKey.happiness, -3)],
              subjectRelation: -8,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_homework_help',
      title: 'Homework Help',
      description: 'I got stuck on my homework and {role} {first} offered to help.',
      minAge: 6,
      maxAge: 16,
      about: EventSubjectKind.parent,
      weight: 10,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'accept',
          label: 'Accept the help',
          outcomes: [
            LifeOutcome(
              text: '{first} explained it in a way that made sense. I got an A.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 8,
            ),
          ],
        ),
        LifeChoice(
          id: 'alone',
          label: 'Do it on my own',
          outcomes: [
            LifeOutcome(
              text: 'I figured it out eventually. {first} watched proudly from the doorway.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.willpower, 3)],
              subjectRelation: 2,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_gift',
      title: 'A Surprise Gift',
      description: '{Role} {first} surprised me with a gift for no reason.',
      minAge: 10,
      maxAge: 50,
      about: EventSubjectKind.parent,
      weight: 9,
      cooldownYears: 5,
      choices: [
        LifeChoice(
          id: 'thanks',
          label: 'Hug {him} tightly',
          outcomes: [
            LifeOutcome(
              text: 'It was a small thing, but it meant the world.',
              stats: [StatEffect(StatKey.happiness, 5)],
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'return',
          label: 'Ask for the receipt',
          outcomes: [
            LifeOutcome(
              text: '{first} looked so crushed that I never did that again.',
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: -6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'sibling_borrow',
      title: 'Borrowed Without Asking',
      description: '{Role} {first} borrowed my stuff without asking, and now it is broken.',
      minAge: 8,
      maxAge: 35,
      about: EventSubjectKind.sibling,
      weight: 10,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'shout',
          label: 'Yell at {him}',
          outcomes: [
            LifeOutcome(
              text: 'The house shook. We both got grounded.',
              stats: [StatEffect(StatKey.happiness, -3)],
              subjectRelation: -8,
            ),
          ],
        ),
        LifeChoice(
          id: 'forgive',
          label: 'Let it go',
          outcomes: [
            LifeOutcome(
              text: '{first} bought me a replacement the next week. Growth!',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 2)],
              subjectRelation: 8,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'sibling_secret',
      title: 'Sibling Secret',
      description: '{Role} {first} confessed a secret to me and asked me not to tell our parents.',
      minAge: 10,
      maxAge: 35,
      about: EventSubjectKind.sibling,
      weight: 8,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'keep',
          label: 'Keep the secret',
          outcomes: [
            LifeOutcome(
              text: 'It was heavy, but {first} trusted me more than ever.',
              stats: [StatEffect(StatKey.willpower, 3)],
              subjectRelation: 14,
            ),
          ],
        ),
        LifeChoice(
          id: 'tell',
          label: 'Tell our parents',
          outcomes: [
            LifeOutcome(
              text: '{first} stopped talking to me for weeks.',
              stats: [StatEffect(StatKey.happiness, -3)],
              subjectRelation: -18,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'sibling_game_night',
      title: 'Game Night',
      description: '{Role} {first} challenged me to a video game match.',
      minAge: 8,
      maxAge: 50,
      about: EventSubjectKind.sibling,
      weight: 10,
      cooldownYears: 3,
      choices: [
        LifeChoice(
          id: 'win',
          label: 'Play to win',
          outcomes: [
            LifeOutcome(
              text: 'I crushed {him}. {first} demanded a rematch.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 1)],
              subjectRelation: 2,
            ),
            LifeOutcome(
              text: '{first} destroyed me. I will be hearing about it forever.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: 4,
            ),
          ],
        ),
        LifeChoice(
          id: 'let',
          label: 'Let {him} win',
          outcomes: [
            LifeOutcome(
              text: '{first} was so happy. It was worth it.',
              stats: [StatEffect(StatKey.happiness, 3)],
              subjectRelation: 8,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_hangout',
      title: 'Hangout',
      description: '{Name} texted me: "Free today? Let\'s do something."',
      minAge: 8,
      maxAge: 85,
      about: EventSubjectKind.friend,
      weight: 14,
      cooldownYears: 2,
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Go out together',
          outcomes: [
            LifeOutcome(
              text: 'We wandered around, ate too much and laughed until it hurt.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 1)],
              moneyBase: -1000,
              subjectRelation: 8,
            ),
          ],
        ),
        LifeChoice(
          id: 'home',
          label: 'Invite {him} over',
          outcomes: [
            LifeOutcome(
              text: 'Snacks, games and terrible movies. A perfect day.',
              stats: [StatEffect(StatKey.happiness, 4)],
              moneyBase: -400,
              subjectRelation: 7,
            ),
          ],
        ),
        LifeChoice(
          id: 'busy',
          label: 'Say I am busy',
          outcomes: [
            LifeOutcome(
              text: '{first} said no worries, but the reply took a while.',
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: -5,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_needs_help',
      title: 'Friend in Trouble',
      description: '{Name} called me at night, clearly upset and needing someone to talk to.',
      minAge: 10,
      maxAge: 85,
      about: EventSubjectKind.friend,
      weight: 10,
      cooldownYears: 4,
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Listen all night',
          outcomes: [
            LifeOutcome(
              text: '{first} felt so much better. Our bond got stronger.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, 2)],
              subjectRelation: 12,
            ),
            LifeOutcome(
              text: 'I was exhausted the next day, but it was worth it.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.willpower, 2)],
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'advice',
          label: 'Give quick advice and hang up',
          outcomes: [
            LifeOutcome(
              text: 'Meh. {first} said thanks but sounded unconvinced.',
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: -3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_birthday',
      title: 'Friend\'s Birthday',
      description: 'It is {name}\'s birthday today.',
      minAge: 8,
      maxAge: 90,
      about: EventSubjectKind.friend,
      weight: 10,
      cooldownYears: 2,
      choices: [
        LifeChoice(
          id: 'gift',
          label: 'Buy a thoughtful gift',
          outcomes: [
            LifeOutcome(
              text: '{first} loved it! It will be on display for years.',
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
              moneyBase: -2500,
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'card',
          label: 'Write a heartfelt message',
          outcomes: [
            LifeOutcome(
              text: 'A simple message, but {first} replied with a dozen hearts.',
              stats: [StatEffect(StatKey.happiness, 3)],
              subjectRelation: 6,
            ),
          ],
        ),
        LifeChoice(
          id: 'forget',
          label: 'Forget until tomorrow',
          outcomes: [
            LifeOutcome(
              text: '{first} acted like it was fine. It was not fine.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, -1)],
              subjectRelation: -10,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_betrayal',
      title: 'Broken Trust',
      description: 'I found out {name} had been talking behind my back.',
      minAge: 12,
      maxAge: 85,
      about: EventSubjectKind.friend,
      weight: 7,
      cooldownYears: 8,
      choices: [
        LifeChoice(
          id: 'confront',
          label: 'Confront {him}',
          outcomes: [
            LifeOutcome(
              text: 'It was a tough talk, but {first} apologized sincerely.',
              weight: 3,
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, 1)],
              subjectRelation: -4,
            ),
            LifeOutcome(
              text: 'It ended in a screaming match. We are no longer friends.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -5)],
              subjectRelation: -30,
              losesFriend: true,
            ),
          ],
        ),
        LifeChoice(
          id: 'cut',
          label: 'Cut {him} off',
          outcomes: [
            LifeOutcome(
              text: 'I blocked {first} everywhere. Quiet, but a bit lonely.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, 2)],
              subjectRelation: -40,
              losesFriend: true,
            ),
          ],
        ),
        LifeChoice(
          id: 'forgive',
          label: 'Let it slide',
          outcomes: [
            LifeOutcome(
              text: 'I decided the friendship mattered more than the gossip.',
              stats: [StatEffect(StatKey.willpower, 1), StatEffect(StatKey.happiness, -1)],
              subjectRelation: -5,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_drifting',
      title: 'Drifting Apart',
      description: 'I realized I had not talked to {name} in months.',
      minAge: 14,
      maxAge: 85,
      about: EventSubjectKind.friend,
      weight: 8,
      cooldownYears: 5,
      choices: [
        LifeChoice(
          id: 'call',
          label: 'Call {him} right now',
          outcomes: [
            LifeOutcome(
              text: 'We talked for hours, as if no time had passed.',
              stats: [StatEffect(StatKey.happiness, 5)],
              subjectRelation: 14,
            ),
          ],
        ),
        LifeChoice(
          id: 'later',
          label: 'Tell myself I will call later',
          outcomes: [
            LifeOutcome(
              text: 'Later never came. The silence grew.',
              stats: [StatEffect(StatKey.happiness, -2)],
              subjectRelation: -12,
            ),
          ],
        ),
        LifeChoice(
          id: 'let',
          label: 'Let the friendship fade',
          outcomes: [
            LifeOutcome(
              text: 'Some friendships just run their course.',
              stats: [StatEffect(StatKey.happiness, -3)],
              subjectRelation: -25,
              losesFriend: true,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_loan',
      title: 'Friend Asks for Money',
      description: '{Name} asked to borrow some money until payday.',
      minAge: 16,
      maxAge: 85,
      about: EventSubjectKind.friend,
      weight: 9,
      cooldownYears: 5,
      choices: [
        LifeChoice(
          id: 'lend',
          label: 'Lend it',
          outcomes: [
            LifeOutcome(
              text: '{first} paid me back on time and bought lunch.',
              weight: 3,
              stats: [StatEffect(StatKey.happiness, 3)],
              moneyBase: -3000,
              subjectRelation: 8,
            ),
            LifeOutcome(
              text: '{first} "forgot" to pay me back. Awkward every time we meet.',
              weight: 2,
              stats: [StatEffect(StatKey.happiness, -4)],
              moneyBase: -6000,
              subjectRelation: -12,
            ),
          ],
        ),
        LifeChoice(
          id: 'refuse',
          label: 'Say no politely',
          outcomes: [
            LifeOutcome(
              text: '{first} understood. Mostly.',
              stats: [StatEffect(StatKey.willpower, 2)],
              subjectRelation: -6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_success',
      title: 'Friend\'s Big News',
      description: '{Name} told me about a big success in {his} life.',
      minAge: 14,
      maxAge: 85,
      about: EventSubjectKind.friend,
      weight: 9,
      cooldownYears: 4,
      choices: [
        LifeChoice(
          id: 'cheer',
          label: 'Celebrate loudly',
          outcomes: [
            LifeOutcome(
              text: 'We celebrated like champions. I am genuinely proud of {first}.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 2)],
              moneyBase: -1500,
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'jealous',
          label: 'Feel quietly jealous',
          outcomes: [
            LifeOutcome(
              text: 'I smiled, but part of me stung. Ugh, human nature.',
              stats: [StatEffect(StatKey.happiness, -3)],
              subjectRelation: -4,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'friend_road_trip',
      title: 'Road Trip',
      description: '{Name} suggested a spontaneous weekend road trip.',
      minAge: 18,
      maxAge: 70,
      about: EventSubjectKind.friend,
      weight: 7,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Pack the car and go',
          outcomes: [
            LifeOutcome(
              text: 'We got lost twice, sang badly and made memories for life.',
              stats: [StatEffect(StatKey.happiness, 7), StatEffect(StatKey.charisma, 2)],
              moneyBase: -6000,
              subjectRelation: 14,
            ),
            LifeOutcome(
              text: 'The car broke down. Still, we laughed about it for years.',
              stats: [StatEffect(StatKey.happiness, 4)],
              moneyBase: -9000,
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'stay',
          label: 'Stay home',
          outcomes: [
            LifeOutcome(
              text: 'I stayed home. My phone buzzed with trip photos all weekend.',
              stats: [StatEffect(StatKey.happiness, -3)],
              subjectRelation: -4,
            ),
          ],
        ),
      ],
    ),
  ];
}
