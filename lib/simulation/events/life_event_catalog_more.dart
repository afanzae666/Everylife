import '../../domain/event/life_event.dart';

/// Extra life events: school, university, work, family, and later life.
///
/// Kept apart from the core catalog so both files stay readable.
abstract final class LifeEventCatalogMore {
  static const List<LifeEventDefinition> all = [
    LifeEventDefinition(
      id: 'school_play',
      title: 'School Play',
      description: 'The teacher announced auditions for the class play.',
      minAge: 6,
      maxAge: 11,
      requiredFlags: ['school_student'],
      weight: 12,
      choices: [
        LifeChoice(
          id: 'lead',
          label: 'Audition for the lead',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'I nailed it. The audience gave me a standing ovation.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3), StatEffect(StatKey.creativity, 2)],
            ),
            LifeOutcome(
              text: 'I froze on stage and forgot every line.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'tree',
          label: 'Volunteer to be a tree',
          outcomes: [
            LifeOutcome(
              text: 'I was the best tree this school has ever seen.',
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.creativity, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Say I am sick that day',
          outcomes: [
            LifeOutcome(
              text: 'I stayed home and ate cereal. Peaceful, but a bit lonely.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'science_fair',
      title: 'Science Fair',
      description: 'The school science fair was coming up, and I needed a project.',
      minAge: 8,
      maxAge: 13,
      choices: [
        LifeChoice(
          id: 'volcano',
          label: 'Build a volcano',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'It erupted perfectly. Judges loved the drama.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.creativity, 2), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              text: 'It erupted onto the judge. Sticky disaster.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'real',
          label: 'Do a real experiment',
          outcomes: [
            LifeOutcome(
              text: 'I won second place with actual science.',
              stats: [StatEffect(StatKey.intelligence, 4), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'copy',
          label: 'Copy an idea from the internet',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'Nobody noticed, but I felt like a fraud.',
              stats: [StatEffect(StatKey.intelligence, -1), StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              text: 'The teacher noticed. Detention for me.',
              stats: [StatEffect(StatKey.willpower, -3), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'lemonade_stand',
      title: 'Lemonade Stand',
      description: 'It was a hot summer day and I had a plastic table and a dream.',
      minAge: 7,
      maxAge: 12,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'sell',
          label: 'Open a lemonade stand',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Neighbors were generous. I earned a tidy sum!',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 2)],
              moneyBase: 2500,
            ),
            LifeOutcome(
              text: 'Rain started, and my profit melted.',
              stats: [StatEffect(StatKey.happiness, -2)],
              moneyBase: -500,
            ),
          ],
        ),
        LifeChoice(
          id: 'free',
          label: 'Give it away for free',
          outcomes: [
            LifeOutcome(
              text: 'Everybody loved me. Zero profit, plenty of friends.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 2)],
              moneyBase: -300,
            ),
          ],
        ),
        LifeChoice(
          id: 'play',
          label: 'Drink it all myself',
          outcomes: [
            LifeOutcome(
              text: 'Delicious. My stomach did not agree.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'sleepover',
      title: 'Sleepover',
      description: 'A friend invited me to a sleepover at their house.',
      minAge: 8,
      maxAge: 14,
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Go and have fun',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Pillow fights and horror stories until 3 AM. Legendary.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 2), StatEffect(StatKey.health, -1)],
            ),
            LifeOutcome(
              text: 'Someone told a ghost story and I did not sleep at all.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'host',
          label: 'Host it at my place',
          outcomes: [
            LifeOutcome(
              text: 'My parents were thrilled. Kind of.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 2)],
              parentRelation: -2,
            ),
          ],
        ),
        LifeChoice(
          id: 'decline',
          label: 'Stay home',
          outcomes: [
            LifeOutcome(
              text: 'Quiet night. I regretted it a little.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'bad_report_card',
      title: 'Bad Report Card',
      description: 'My report card arrived, and the numbers were not pretty.',
      minAge: 8,
      maxAge: 17,
      cooldownYears: 5,
      requiredFlags: ['school_student'],
      choices: [
        LifeChoice(
          id: 'study',
          label: 'Study harder',
          outcomes: [
            LifeOutcome(
              text: 'I buckled down and the next grades improved.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'hide',
          label: 'Hide the report card',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'Nobody found out. The guilt, however, stayed.',
              stats: [StatEffect(StatKey.willpower, -2), StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              text: 'My parents found it. Awkward dinner followed.',
              stats: [StatEffect(StatKey.happiness, -3)],
              parentRelation: -6,
            ),
          ],
        ),
        LifeChoice(
          id: 'blame',
          label: 'Blame the teacher',
          outcomes: [
            LifeOutcome(
              text: 'Nobody bought it.',
              stats: [StatEffect(StatKey.charisma, -1), StatEffect(StatKey.happiness, -1)],
              parentRelation: -3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parents_arguing',
      title: 'Thin Walls',
      description: 'I heard my parents arguing through the wall again.',
      minAge: 6,
      maxAge: 16,
      weight: 9,
      needsLivingParent: true,
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Listen quietly',
          outcomes: [
            LifeOutcome(
              text: 'It passed. I felt small, though.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'interrupt',
          label: 'Walk in and ask for a snack',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'Awkward silence, then they both laughed. Tension gone.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.charisma, 2)],
              parentRelation: 3,
            ),
            LifeOutcome(
              text: 'They both told me to go to bed.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'headphones',
          label: 'Put on headphones',
          outcomes: [
            LifeOutcome(
              text: 'Music saved me tonight.',
              stats: [StatEffect(StatKey.creativity, 1), StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'school_crush',
      title: 'First Crush',
      description: 'Someone in my class made my heart do backflips.',
      minAge: 10,
      maxAge: 15,
      requiredFlags: ['school_student'],
      weight: 14,
      oncePerLife: true,
      choices: [
        LifeChoice(
          id: 'confess',
          label: 'Write them a note',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'They said yes! My hands were sweating for a week.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              text: 'They laughed. I wanted the floor to swallow me.',
              stats: [StatEffect(StatKey.happiness, -5), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'stare',
          label: 'Just stare from a distance',
          outcomes: [
            LifeOutcome(
              text: 'Nothing happened. The mystery continues.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'friend',
          label: 'Ask a friend to ask for me',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'A classic move. The result was chaotic and funny.',
              stats: [StatEffect(StatKey.charisma, 1), StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              text: 'Everyone found out. I wanted to move countries.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.charisma, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'driving_lessons',
      title: 'Driving Lessons',
      description: 'I was finally old enough to learn how to drive.',
      minAge: 16,
      maxAge: 19,
      weight: 14,
      oncePerLife: true,
      choices: [
        LifeChoice(
          id: 'instructor',
          label: 'Take lessons with an instructor',
          requiresMoneyBase: 30000,
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'I passed the test on the first try.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 1)],
              moneyBase: -30000,
            ),
            LifeOutcome(
              text: 'I failed the test. Retake fee, ouch.',
              stats: [StatEffect(StatKey.happiness, -3)],
              moneyBase: -15000,
            ),
          ],
        ),
        LifeChoice(
          id: 'parent',
          label: 'Learn from my parents',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'We survived. Our friendship, mostly.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, 1)],
              parentRelation: 3,
            ),
            LifeOutcome(
              text: 'Dad screamed, I screamed, the mailbox screamed.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.health, -1)],
              parentRelation: -3,
            ),
          ],
        ),
        LifeChoice(
          id: 'later',
          label: 'Skip it for now',
          outcomes: [
            LifeOutcome(
              text: 'I will walk like a philosopher.',
              stats: [StatEffect(StatKey.fitness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'prom_night',
      title: 'Prom Night',
      description: 'Prom was around the corner, and the dress code mattered a lot.',
      minAge: 16,
      maxAge: 18,
      weight: 14,
      oncePerLife: true,
      choices: [
        LifeChoice(
          id: 'date',
          label: 'Ask someone special',
          requiresMoneyBase: 8000,
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'We danced all night. A perfect memory.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 2)],
              moneyBase: -8000,
            ),
            LifeOutcome(
              text: 'They already had a date. I danced with my friends instead.',
              stats: [StatEffect(StatKey.happiness, -1), StatEffect(StatKey.charisma, 1)],
              moneyBase: -8000,
            ),
          ],
        ),
        LifeChoice(
          id: 'group',
          label: 'Go with friends',
          requiresMoneyBase: 5000,
          outcomes: [
            LifeOutcome(
              text: 'Group photos, bad dancing, and endless laughter.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 2)],
              moneyBase: -5000,
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Skip prom entirely',
          outcomes: [
            LifeOutcome(
              text: 'Gaming night! Zero regret. Maybe a little.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'scholarship',
      title: 'Scholarship Chance',
      description: 'A teacher told me about a scholarship competition.',
      minAge: 16,
      maxAge: 19,
      oncePerLife: true,
      requiredFlags: ['school_student'],
      choices: [
        LifeChoice(
          id: 'apply',
          label: 'Apply with a heartfelt essay',
          outcomes: [
            LifeOutcome(
              text: 'I won! My future just got lighter.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 5)],
              moneyBase: 150000,
            ),
            LifeOutcome(
              weight: 3,
              text: 'I did not win, but the essay felt good to write.',
              stats: [StatEffect(StatKey.creativity, 2), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Skip it, too much work',
          outcomes: [
            LifeOutcome(
              text: 'Freedom! Ask me again when I am broke.',
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'dropout_temptation',
      title: 'Dropout Temptation',
      description: 'School felt endless, and a friend said real life starts outside it.',
      minAge: 14,
      maxAge: 20,
      cooldownYears: 6,
      requiredFlags: ['student'],
      choices: [
        LifeChoice(
          id: 'stay',
          label: 'Stay in school',
          outcomes: [
            LifeOutcome(
              text: 'I pushed through. Future me says thanks.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.intelligence, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'leave',
          label: 'Drop out',
          outcomes: [
            LifeOutcome(
              text: 'I walked out of the building and never looked back. Bold.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, -2)],
              addFlags: ['dropout'],
            ),
          ],
        ),
        LifeChoice(
          id: 'talk',
          label: 'Talk to a counselor',
          outcomes: [
            LifeOutcome(
              text: 'She helped me see a plan. Sometimes people just listen.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_grief',
      title: 'Missing Them',
      description: 'I kept thinking about the parent I lost.',
      minAge: 8,
      maxAge: 100,
      weight: 14,
      cooldownYears: 5,
      requiredFlags: ['lost_parent'],
      choices: [
        LifeChoice(
          id: 'talk',
          label: 'Talk about it with someone',
          outcomes: [
            LifeOutcome(
              text: 'It hurt, but it helped.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'hold',
          label: 'Keep it inside',
          outcomes: [
            LifeOutcome(
              text: 'The silence got louder every night.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.health, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'visit',
          label: 'Visit their grave with flowers',
          outcomes: [
            LifeOutcome(
              text: 'A quiet moment of peace.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, 1)],
              moneyBase: -1500,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_all_nighter',
      title: 'All-Nighter',
      description: 'An essay was due at 8 AM and I had written one sentence.',
      minAge: 18,
      maxAge: 24,
      weight: 14,
      requiredFlags: ['university_student'],
      choices: [
        LifeChoice(
          id: 'coffee',
          label: 'Coffee and panic',
          narration: 'I fueled up on coffee and panic.',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'I finished at 7:59. Barely alive, but it counts.',
              stats: [StatEffect(StatKey.intelligence, 1), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.health, -2)],
            ),
            LifeOutcome(
              text: 'I fell asleep on the keyboard. The essay said "ooooo".',
              stats: [StatEffect(StatKey.intelligence, -1), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'extension',
          label: 'Ask for an extension',
          outcomes: [
            LifeOutcome(
              text: 'The professor said yes with a sigh.',
              stats: [StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Sleep and accept the zero',
          outcomes: [
            LifeOutcome(
              text: 'The grade hurt. The sleep was divine.',
              stats: [StatEffect(StatKey.intelligence, -2), StatEffect(StatKey.health, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_party',
      title: 'Dorm Party',
      description: 'Music was blasting on my floor and everyone was invited.',
      minAge: 18,
      maxAge: 24,
      weight: 12,
      requiredFlags: ['university_student'],
      choices: [
        LifeChoice(
          id: 'dance',
          label: 'Dance all night',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'I became a campus legend for my moves.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 4), StatEffect(StatKey.health, -1)],
            ),
            LifeOutcome(
              text: 'I woke up with a headache and a traffic cone.',
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'study',
          label: 'Study in the library',
          outcomes: [
            LifeOutcome(
              text: 'Grades are great, social life is empty.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'friends',
          label: 'Chill with two close friends',
          outcomes: [
            LifeOutcome(
              text: 'We talked for hours. Best night of the semester.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_professor',
      title: 'Tough Professor',
      description: 'My professor was famous for failing half the class.',
      minAge: 18,
      maxAge: 24,
      requiredFlags: ['university_student'],
      choices: [
        LifeChoice(
          id: 'office',
          label: 'Attend office hours',
          outcomes: [
            LifeOutcome(
              text: 'He turned out to be nice. Strict, but nice.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'group',
          label: 'Form a study group',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Teamwork saved us. We even became friends.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              text: 'Everyone argued over snacks. Still, we learned a bit.',
              stats: [StatEffect(StatKey.intelligence, 1), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'wing',
          label: 'Wing it',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Disaster. I will not do that twice.',
              stats: [StatEffect(StatKey.intelligence, -2), StatEffect(StatKey.happiness, -3)],
            ),
            LifeOutcome(
              text: 'Miracle. I passed with luck alone.',
              stats: [StatEffect(StatKey.luck, 2), StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_internship',
      title: 'Internship Offer',
      description: 'A company offered a summer internship.',
      minAge: 19,
      maxAge: 23,
      requiredFlags: ['university_student'],
      choices: [
        LifeChoice(
          id: 'accept',
          label: 'Accept the internship',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Good experience, great coffee, and a recommendation letter.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.charisma, 2), StatEffect(StatKey.willpower, 2)],
              moneyBase: 60000,
            ),
            LifeOutcome(
              text: 'The boss only wanted free labor.',
              stats: [StatEffect(StatKey.willpower, 1), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'travel',
          label: 'Travel instead',
          requiresMoneyBase: 60000,
          outcomes: [
            LifeOutcome(
              text: 'I came back tanned and inspired.',
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.creativity, 2)],
              moneyBase: -60000,
            ),
          ],
        ),
        LifeChoice(
          id: 'rest',
          label: 'Rest and relax',
          outcomes: [
            LifeOutcome(
              text: 'Lazy summer, good vibes.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.health, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_roommate',
      title: 'The Roommate',
      description: 'My new roommate had very... particular habits.',
      minAge: 18,
      maxAge: 22,
      requiredFlags: ['university_student'],
      choices: [
        LifeChoice(
          id: 'talk',
          label: 'Set house rules',
          outcomes: [
            LifeOutcome(
              text: 'Surprisingly mature. It worked.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'endure',
          label: 'Endure in silence',
          outcomes: [
            LifeOutcome(
              text: 'My sleep schedule is permanently damaged.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'prank',
          label: 'Prank them back',
          outcomes: [
            LifeOutcome(
              text: 'War was declared. Everyone had fun except the cat.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_debt_worry',
      title: 'Tuition Worries',
      description: 'I looked at the tuition bill and my stomach dropped.',
      minAge: 18,
      maxAge: 24,
      weight: 8,
      requiredFlags: ['university_student'],
      choices: [
        LifeChoice(
          id: 'parttime',
          label: 'Take a part-time job',
          outcomes: [
            LifeOutcome(
              text: 'Busy weeks, but my wallet felt better.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.health, -1), StatEffect(StatKey.happiness, -1)],
              moneyBase: 40000,
            ),
          ],
        ),
        LifeChoice(
          id: 'loan',
          label: 'Take a student loan',
          outcomes: [
            LifeOutcome(
              text: 'The paperwork was easy. The future is a mystery.',
              stats: [StatEffect(StatKey.happiness, 1)],
              moneyBase: -100000,
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Ignore it',
          outcomes: [
            LifeOutcome(
              text: 'Ignoring bills never made them smaller.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, -1)],
              moneyBase: -20000,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_conflict',
      title: 'Office Conflict',
      description: 'A coworker kept taking credit for my ideas.',
      minAge: 20,
      maxAge: 60,
      weight: 14,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'confront',
          label: 'Confront them politely',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'They apologized. Awkward, but fair.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.willpower, 2)],
            ),
            LifeOutcome(
              text: 'They denied everything and rolled their eyes.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'manager',
          label: 'Tell the manager',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'My boss listened and fixed the problem.',
              stats: [StatEffect(StatKey.charisma, 1), StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              text: 'The boss shrugged. Great.',
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'swallow',
          label: 'Let it go',
          outcomes: [
            LifeOutcome(
              text: 'I swallowed my pride. It tasted bitter.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_deadline',
      title: 'Impossible Deadline',
      description: 'The client wanted everything by Friday. It was Thursday.',
      minAge: 20,
      maxAge: 62,
      weight: 14,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'crunch',
          label: 'Crunch all night',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'I delivered. Everyone clapped, and I slept for 14 hours.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.health, -3)],
              addFlags: ['overworked'],
            ),
            LifeOutcome(
              text: 'I delivered garbage. Everyone noticed.',
              stats: [StatEffect(StatKey.willpower, 1), StatEffect(StatKey.health, -3), StatEffect(StatKey.happiness, -3)],
              addFlags: ['overworked'],
            ),
          ],
        ),
        LifeChoice(
          id: 'negotiate',
          label: 'Negotiate the deadline',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'They gave me another week. Negotiation wins again.',
              stats: [StatEffect(StatKey.charisma, 3)],
            ),
            LifeOutcome(
              text: 'They said no, and now I am stressed anyway.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'team',
          label: 'Delegate to teammates',
          outcomes: [
            LifeOutcome(
              text: 'The team pulled together. We celebrated with pizza.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 2)],
              moneyBase: -2000,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_praise',
      title: 'Boss Praise',
      description: 'My boss mentioned my name in the all-hands meeting.',
      minAge: 20,
      maxAge: 64,
      requiredFlags: ['employed'],
      autoOutcomes: [
        LifeOutcome(
          text: 'My cheeks turned red, but my chest felt warm.',
          stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 1)],
        ),
        LifeOutcome(
          text: 'Someone clapped awkwardly and the meeting moved on, but I smiled all day.',
          stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, 1)],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_layoff_rumor',
      title: 'Layoff Rumors',
      description: 'The hallway whispered that layoffs were coming.',
      minAge: 22,
      maxAge: 64,
      weight: 9,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'overtime',
          label: 'Work extra hard',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'Management noticed. It paid off.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.health, -1), StatEffect(StatKey.happiness, -1)],
            ),
            LifeOutcome(
              text: 'Nothing changed, and I was tired for nothing.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'network',
          label: 'Update my resume',
          outcomes: [
            LifeOutcome(
              text: 'I felt prepared and calm.',
              stats: [StatEffect(StatKey.charisma, 1), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'panic',
          label: 'Spiral with coworkers',
          outcomes: [
            LifeOutcome(
              text: 'We drank coffee and doom-scrolled the whole day.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_burnout',
      title: 'Burnout',
      description: 'My body told me it had enough. My mind agreed.',
      minAge: 24,
      maxAge: 64,
      weight: 18,
      cooldownYears: 5,
      requiredFlags: ['overworked'],
      choices: [
        LifeChoice(
          id: 'vacation',
          label: 'Take a long vacation',
          requiresMoneyBase: 50000,
          outcomes: [
            LifeOutcome(
              text: 'Two weeks of sunshine fixed my soul.',
              stats: [StatEffect(StatKey.health, 3), StatEffect(StatKey.happiness, 5)],
              moneyBase: -50000,
              removeFlags: ['overworked'],
            ),
          ],
        ),
        LifeChoice(
          id: 'therapy',
          label: 'Talk to a professional',
          outcomes: [
            LifeOutcome(
              text: 'It was hard, but I am learning to say no.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, 3), StatEffect(StatKey.health, 1)],
              moneyBase: -12000,
              removeFlags: ['overworked'],
            ),
          ],
        ),
        LifeChoice(
          id: 'push',
          label: 'Push through',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'I collapsed on the stairs. A scary warning.',
              stats: [StatEffect(StatKey.health, -8), StatEffect(StatKey.happiness, -4)],
            ),
            LifeOutcome(
              text: 'I held on, barely. Coffee became my blood type.',
              stats: [StatEffect(StatKey.health, -4), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_raise_chance',
      title: 'Pay Review',
      description: 'It was salary review season.',
      minAge: 22,
      maxAge: 63,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'ask',
          label: 'Present my achievements',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'My manager nodded and approved a small bonus!',
              stats: [StatEffect(StatKey.charisma, 1), StatEffect(StatKey.happiness, 3)],
              moneyBase: 60000,
            ),
            LifeOutcome(
              text: 'They said the budget is frozen. Maybe next year.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'wait',
          label: 'Wait for them to notice',
          outcomes: [
            LifeOutcome(
              text: 'Nobody noticed. Shocking.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_team_trip',
      title: 'Team Retreat',
      description: 'The company organized a retreat in the mountains.',
      minAge: 22,
      maxAge: 60,
      weight: 8,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Join and socialize',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Bonfire stories and bad karaoke. We bonded.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              text: 'I got lost on a hike and found a bear. Just kidding. A goat.',
              stats: [StatEffect(StatKey.fitness, 1), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'hermit',
          label: 'Hide in the hotel room',
          outcomes: [
            LifeOutcome(
              text: 'Room service and Netflix. Zero regrets.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.charisma, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_promotion_offer',
      title: 'Management Offer',
      description: 'They asked me to lead a small team.',
      minAge: 26,
      maxAge: 60,
      weight: 8,
      requiredFlags: ['employed'],
      choices: [
        LifeChoice(
          id: 'accept',
          label: 'Accept the leadership role',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Meetings everywhere, but I grew into it.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.health, -1)],
            ),
            LifeOutcome(
              text: 'The team did not like me. Hard lessons.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'decline',
          label: 'Stay an individual contributor',
          outcomes: [
            LifeOutcome(
              text: 'I stayed in my lane and kept my peace.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'work_scam_email',
      title: 'Suspicious Email',
      description: 'An email said I won a prize in a contest I never entered.',
      minAge: 18,
      maxAge: 90,
      weight: 9,
      choices: [
        LifeChoice(
          id: 'click',
          label: 'Click the link',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'It was a scam. My bank account cried.',
              stats: [StatEffect(StatKey.willpower, -1), StatEffect(StatKey.happiness, -4)],
              moneyBase: -25000,
            ),
            LifeOutcome(
              text: 'It was just ads. Phew.',
              stats: [StatEffect(StatKey.luck, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'report',
          label: 'Report it as spam',
          outcomes: [
            LifeOutcome(
              text: 'Responsible and boring. I love it.',
              stats: [StatEffect(StatKey.intelligence, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'buy_home',
      title: 'Dream Home',
      description: 'I found a house that looked perfect on paper.',
      minAge: 26,
      maxAge: 60,
      weight: 8,
      cooldownYears: 8,
      choices: [
        LifeChoice(
          id: 'visit',
          label: 'Visit and inspect it',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'Perfect location, but it needed repairs. I let it go.',
              stats: [StatEffect(StatKey.intelligence, 1), StatEffect(StatKey.willpower, 1)],
            ),
            LifeOutcome(
              text: 'The owner offered a discount. I felt lucky.',
              stats: [StatEffect(StatKey.luck, 2), StatEffect(StatKey.happiness, 3)],
              moneyBase: -30000,
            ),
          ],
        ),
        LifeChoice(
          id: 'rent',
          label: 'Keep renting',
          outcomes: [
            LifeOutcome(
              text: 'Flexible and safe. No mortgage stress.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'dream',
          label: 'Daydream about it',
          outcomes: [
            LifeOutcome(
              text: 'Free daydreams, priceless.',
              stats: [StatEffect(StatKey.creativity, 1), StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'burglary',
      title: 'Break-in',
      description: 'I came home and the door was open.',
      minAge: 20,
      maxAge: 80,
      weight: 6,
      cooldownYears: 8,
      choices: [
        LifeChoice(
          id: 'police',
          label: 'Call the police',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'They took notes and wished me luck. Lost a few things.',
              stats: [StatEffect(StatKey.happiness, -3)],
              moneyBase: -40000,
            ),
            LifeOutcome(
              text: 'They caught the thief within a week. Justice!',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.luck, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'alarm',
          label: 'Install an alarm',
          requiresMoneyBase: 25000,
          outcomes: [
            LifeOutcome(
              text: 'Peace of mind, at a price.',
              stats: [StatEffect(StatKey.happiness, 2)],
              moneyBase: -25000,
            ),
          ],
        ),
        LifeChoice(
          id: 'shrug',
          label: 'Shrug and move on',
          outcomes: [
            LifeOutcome(
              text: 'I told myself it was only stuff. The stuff disagreed.',
              stats: [StatEffect(StatKey.happiness, -3)],
              moneyBase: -30000,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'windfall',
      title: 'Lucky Windfall',
      description: 'Mail arrived with a surprise: a small inheritance from a distant aunt.',
      minAge: 20,
      maxAge: 90,
      weight: 4,
      cooldownYears: 15,
      autoOutcomes: [
        LifeOutcome(
          text: 'Someone I barely remembered thought of me. I treated myself to a nice dinner.',
          stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.luck, 1)],
          moneyBase: 80000,
        ),
        LifeOutcome(
          text: 'A distant relative left me a modest sum and a ceramic cat.',
          stats: [StatEffect(StatKey.happiness, 2)],
          moneyBase: 40000,
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'class_reunion',
      title: 'Class Reunion',
      description: 'An invitation for a class reunion landed in my inbox.',
      minAge: 28,
      maxAge: 70,
      weight: 8,
      cooldownYears: 10,
      choices: [
        LifeChoice(
          id: 'attend',
          label: 'Attend with my best outfit',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Old friends, old stories, new connections.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
              moneyBase: -5000,
            ),
            LifeOutcome(
              text: 'Everyone compared salaries. Awkward night.',
              stats: [StatEffect(StatKey.happiness, -3)],
              moneyBase: -5000,
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Skip it',
          outcomes: [
            LifeOutcome(
              text: 'Memories stay best untouched.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'insomnia',
      title: 'Sleepless Nights',
      description: 'Sleep refused to find me for a whole week.',
      minAge: 22,
      maxAge: 90,
      weight: 9,
      choices: [
        LifeChoice(
          id: 'routine',
          label: 'Fix my sleep routine',
          outcomes: [
            LifeOutcome(
              text: 'No screens, early bed, and it worked.',
              stats: [StatEffect(StatKey.health, 2), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'pills',
          label: 'Try sleeping pills',
          outcomes: [
            LifeOutcome(
              text: 'They helped, but the haze lasted a while.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.happiness, 1)],
              moneyBase: -3000,
            ),
          ],
        ),
        LifeChoice(
          id: 'scroll',
          label: 'Doom scroll until sunrise',
          outcomes: [
            LifeOutcome(
              text: 'Terrible idea. I feel like a zombie.',
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'neighbor_noise',
      title: 'Noisy Neighbors',
      description: 'The people next door were practicing drums at midnight.',
      minAge: 20,
      maxAge: 80,
      weight: 9,
      choices: [
        LifeChoice(
          id: 'knock',
          label: 'Knock politely',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'They apologized and bought me cookies.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              text: 'They laughed and played louder.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'earplugs',
          label: 'Buy earplugs',
          outcomes: [
            LifeOutcome(
              text: 'Solved. Cheap and quiet.',
              stats: [StatEffect(StatKey.happiness, 1)],
              moneyBase: -1500,
            ),
          ],
        ),
        LifeChoice(
          id: 'revenge',
          label: 'Blast my own music at 6 AM',
          outcomes: [
            LifeOutcome(
              text: 'A war of speakers began.',
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.charisma, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'side_hustle',
      title: 'Side Hustle Idea',
      description: 'I had a clever idea to earn some extra money.',
      minAge: 20,
      maxAge: 60,
      weight: 9,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'start',
          label: 'Start it after work',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'It grew into a decent side income.',
              stats: [StatEffect(StatKey.creativity, 2), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.health, -1)],
              moneyBase: 50000,
            ),
            LifeOutcome(
              text: 'Nobody wanted what I was selling.',
              stats: [StatEffect(StatKey.happiness, -2)],
              moneyBase: -20000,
            ),
          ],
        ),
        LifeChoice(
          id: 'think',
          label: 'Think about it for a few years',
          outcomes: [
            LifeOutcome(
              text: 'The idea evaporated like steam.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'wedding_invite',
      title: 'Wedding Invitation',
      description: 'A close friend invited me to their wedding.',
      minAge: 22,
      maxAge: 70,
      cooldownYears: 5,
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Go and dance',
          outcomes: [
            LifeOutcome(
              text: 'Open bar, good music, and tears of joy.',
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
              moneyBase: -8000,
            ),
          ],
        ),
        LifeChoice(
          id: 'gift',
          label: 'Send a gift only',
          outcomes: [
            LifeOutcome(
              text: 'Thoughtful and cheap. They were touched.',
              stats: [StatEffect(StatKey.happiness, 1)],
              moneyBase: -4000,
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Skip it',
          outcomes: [
            LifeOutcome(
              text: 'I stayed home. The group chat wrote essays about my absence.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'family_dinner',
      title: 'Family Dinner',
      description: 'The whole family gathered for a loud and chaotic dinner. {Role} {first} sat right next to me.',
      minAge: 14,
      maxAge: 90,
      about: EventSubjectKind.parent,
      weight: 14,
      cooldownYears: 3,
      needsLivingParent: true,
      choices: [
        LifeChoice(
          id: 'cook',
          label: 'Help in the kitchen',
          outcomes: [
            LifeOutcome(
              text: 'We laughed while cooking. A warm memory.',
              stats: [StatEffect(StatKey.happiness, 3)],
              subjectRelation: 4,
            ),
          ],
        ),
        LifeChoice(
          id: 'phone',
          label: 'Stay on my phone',
          outcomes: [
            LifeOutcome(
              text: 'Nobody said anything. That was the problem.',
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: -4,
            ),
          ],
        ),
        LifeChoice(
          id: 'toast',
          label: 'Make a toast',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Everyone cried a little. I became the family poet.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 3)],
              subjectRelation: 5,
            ),
            LifeOutcome(
              text: 'I stumbled on my words. They clapped anyway.',
              stats: [StatEffect(StatKey.happiness, 1)],
              subjectRelation: 2,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'sibling_help',
      title: 'Sibling in Need',
      description: '{Role} {first} called, sounding stressed.',
      minAge: 16,
      maxAge: 80,
      about: EventSubjectKind.sibling,
      weight: 12,
      needsLivingSibling: true,
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Listen and support them',
          outcomes: [
            LifeOutcome(
              text: 'They felt heard. We grew closer.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, 1)],
              subjectRelation: 8,
            ),
          ],
        ),
        LifeChoice(
          id: 'money',
          label: 'Lend a bit of money',
          requiresMoneyBase: 10000,
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'They paid me back. Trust built.',
              stats: [StatEffect(StatKey.happiness, 1)],
              moneyBase: -10000,
              subjectRelation: 6,
            ),
            LifeOutcome(
              text: 'They forgot to pay me back. Awkward.',
              stats: [StatEffect(StatKey.happiness, -2)],
              moneyBase: -10000,
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'busy',
          label: 'Say I am busy',
          outcomes: [
            LifeOutcome(
              text: 'I felt guilty for days.',
              stats: [StatEffect(StatKey.happiness, -2)],
              subjectRelation: -6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'sibling_celebration',
      title: 'Sibling Milestone',
      description: '{Role} {first} reached a big milestone and invited me to celebrate.',
      minAge: 16,
      maxAge: 80,
      about: EventSubjectKind.sibling,
      weight: 9,
      needsLivingSibling: true,
      choices: [
        LifeChoice(
          id: 'party',
          label: 'Throw them a party',
          outcomes: [
            LifeOutcome(
              text: 'Cake, balloons, and bad jokes. Perfect.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 1)],
              moneyBase: -5000,
              subjectRelation: 8,
            ),
          ],
        ),
        LifeChoice(
          id: 'card',
          label: 'Send a card',
          outcomes: [
            LifeOutcome(
              text: 'Simple and sweet.',
              stats: [StatEffect(StatKey.happiness, 1)],
              subjectRelation: 3,
            ),
          ],
        ),
        LifeChoice(
          id: 'forget',
          label: 'Forget about it',
          outcomes: [
            LifeOutcome(
              text: 'I remembered two days later. Ouch.',
              stats: [StatEffect(StatKey.happiness, -2)],
              subjectRelation: -6,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_visit',
      title: 'Visiting Home',
      description: 'I had a free weekend and thought of home. {Role} {first} was waiting for me.',
      minAge: 18,
      maxAge: 70,
      about: EventSubjectKind.parent,
      weight: 12,
      needsLivingParent: true,
      choices: [
        LifeChoice(
          id: 'visit',
          label: 'Visit my parents',
          outcomes: [
            LifeOutcome(
              text: '{first} stuffed me with food and told the same old jokes.',
              stats: [StatEffect(StatKey.happiness, 4)],
              subjectRelation: 6,
            ),
          ],
        ),
        LifeChoice(
          id: 'call',
          label: 'Call them instead',
          outcomes: [
            LifeOutcome(
              text: 'A short call, a long smile.',
              stats: [StatEffect(StatKey.happiness, 1)],
              subjectRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Stay in and relax',
          outcomes: [
            LifeOutcome(
              text: 'I got my rest, and a worried text later.',
              stats: [StatEffect(StatKey.happiness, -1)],
              subjectRelation: -3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'parent_health_scare',
      title: 'Parent Health Scare',
      description: 'I got a call: {role} {first} was in the hospital.',
      minAge: 30,
      maxAge: 80,
      about: EventSubjectKind.parent,
      weight: 8,
      cooldownYears: 6,
      needsLivingParent: true,
      choices: [
        LifeChoice(
          id: 'hospital',
          label: 'Rush to the hospital',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'They recovered. I held their hand all night.',
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.health, -1)],
              subjectRelation: 8,
            ),
            LifeOutcome(
              text: 'It was serious. We spent weeks in worry.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.health, -2)],
              subjectRelation: 6,
            ),
          ],
        ),
        LifeChoice(
          id: 'pay',
          label: 'Pay for better treatment',
          requiresMoneyBase: 60000,
          outcomes: [
            LifeOutcome(
              text: 'Money cannot buy everything, but it helped.',
              stats: [StatEffect(StatKey.happiness, 2)],
              moneyBase: -60000,
              subjectRelation: 10,
            ),
          ],
        ),
        LifeChoice(
          id: 'later',
          label: 'Visit later when I have time',
          outcomes: [
            LifeOutcome(
              text: 'That "later" haunted me for months.',
              stats: [StatEffect(StatKey.happiness, -4)],
              subjectRelation: -10,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'midlife_doubts',
      title: 'Midlife Doubts',
      description: 'I looked in the mirror and asked what I had done with my life.',
      minAge: 38,
      maxAge: 55,
      oncePerLife: true,
      choices: [
        LifeChoice(
          id: 'sports',
          label: 'Buy a sports bike',
          requiresMoneyBase: 90000,
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'I felt twenty again. My back disagreed.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.fitness, 1), StatEffect(StatKey.health, -2)],
              moneyBase: -90000,
            ),
            LifeOutcome(
              text: 'I crashed within the first week. Embarrassing.',
              stats: [StatEffect(StatKey.health, -6), StatEffect(StatKey.happiness, -3)],
              moneyBase: -90000,
            ),
          ],
        ),
        LifeChoice(
          id: 'hobby',
          label: 'Start a creative hobby',
          outcomes: [
            LifeOutcome(
              text: 'Painting, writing, or pottery, it felt like home.',
              stats: [StatEffect(StatKey.creativity, 4), StatEffect(StatKey.happiness, 4)],
            ),
          ],
        ),
        LifeChoice(
          id: 'shrug',
          label: 'Shrug and keep going',
          outcomes: [
            LifeOutcome(
              text: 'It passed in a few weeks. Probably.',
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'gym_goals',
      title: 'New Year Gym Plan',
      description: 'I swore this year would be different.',
      minAge: 20,
      maxAge: 60,
      weight: 12,
      cooldownYears: 3,
      choices: [
        LifeChoice(
          id: 'commit',
          label: 'Commit to a routine',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Three months later, I feel stronger.',
              stats: [StatEffect(StatKey.fitness, 4), StatEffect(StatKey.health, 2), StatEffect(StatKey.willpower, 2)],
              moneyBase: -6000,
            ),
            LifeOutcome(
              text: 'I quit after two weeks like always.',
              stats: [StatEffect(StatKey.happiness, -1)],
              moneyBase: -6000,
            ),
          ],
        ),
        LifeChoice(
          id: 'home',
          label: 'Exercise at home',
          outcomes: [
            LifeOutcome(
              text: 'Free, simple, and surprisingly effective.',
              stats: [StatEffect(StatKey.fitness, 2), StatEffect(StatKey.health, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'couch',
          label: 'Promise myself I will start tomorrow',
          outcomes: [
            LifeOutcome(
              text: 'Tomorrow is a very busy day.',
              stats: [StatEffect(StatKey.fitness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'doctor_checkup',
      title: 'Annual Checkup',
      description: 'My doctor suggested a full checkup.',
      minAge: 30,
      maxAge: 90,
      weight: 12,
      cooldownYears: 3,
      choices: [
        LifeChoice(
          id: 'go',
          label: 'Get the checkup',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'All good, mostly. A few small tips.',
              stats: [StatEffect(StatKey.health, 3)],
              moneyBase: -8000,
            ),
            LifeOutcome(
              text: 'They caught something early. A lucky save.',
              stats: [StatEffect(StatKey.health, 2), StatEffect(StatKey.luck, 1)],
              moneyBase: -8000,
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Skip it',
          outcomes: [
            LifeOutcome(
              text: 'Nothing happened. Yet.',
              stats: [StatEffect(StatKey.health, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'retire_hobby',
      title: 'Retirement Hobby',
      description: 'Now that I had free time, I needed something to fill my days.',
      minAge: 60,
      maxAge: 100,
      weight: 12,
      choices: [
        LifeChoice(
          id: 'garden',
          label: 'Start a garden',
          outcomes: [
            LifeOutcome(
              text: 'Tomatoes, flowers, and peace.',
              stats: [StatEffect(StatKey.health, 2), StatEffect(StatKey.happiness, 3), StatEffect(StatKey.fitness, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'volunteer',
          label: 'Volunteer at the community center',
          outcomes: [
            LifeOutcome(
              text: 'I felt useful and loved.',
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'tv',
          label: 'Watch TV all day',
          outcomes: [
            LifeOutcome(
              text: 'Comfy, but my knees complained.',
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.fitness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'grandkid_visit',
      title: 'Grandkids Visit',
      description: 'A little voice shouted my name at the door.',
      minAge: 55,
      maxAge: 100,
      choices: [
        LifeChoice(
          id: 'play',
          label: 'Play on the floor',
          outcomes: [
            LifeOutcome(
              text: 'My back hurt, but my heart sang.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.fitness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'stories',
          label: 'Tell old stories',
          outcomes: [
            LifeOutcome(
              text: 'Their eyes sparkled. I may have exaggerated a little.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'nap',
          label: 'Take a nap in the armchair',
          outcomes: [
            LifeOutcome(
              text: 'They drew on my face. Nobody regrets it.',
              stats: [StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'senior_memory',
      title: 'Memory Lapse',
      description: 'I forgot where I put my glasses. They were on my head.',
      minAge: 62,
      maxAge: 100,
      choices: [
        LifeChoice(
          id: 'puzzle',
          label: 'Do crossword puzzles daily',
          outcomes: [
            LifeOutcome(
              text: 'Mind sharp as a pin.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'laugh',
          label: 'Laugh it off',
          outcomes: [
            LifeOutcome(
              text: 'Laughing keeps the worry away.',
              stats: [StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'worry',
          label: 'Worry about it for days',
          outcomes: [
            LifeOutcome(
              text: 'Worry does not help memory, apparently.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.health, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'old_friend',
      title: 'An Old Friend',
      description: 'A friend I had not seen in decades called out of the blue.',
      minAge: 50,
      maxAge: 100,
      weight: 8,
      cooldownYears: 8,
      choices: [
        LifeChoice(
          id: 'meet',
          label: 'Meet for coffee',
          outcomes: [
            LifeOutcome(
              text: 'Three hours flew by. We promised to repeat it.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.charisma, 1)],
              moneyBase: -2000,
            ),
          ],
        ),
        LifeChoice(
          id: 'phone',
          label: 'Talk on the phone',
          outcomes: [
            LifeOutcome(
              text: 'We laughed until our throats hurt.',
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Ignore the call',
          outcomes: [
            LifeOutcome(
              text: 'I wondered about it for weeks.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'senior_fall',
      title: 'A Slippery Step',
      description: 'The stairs were slick, and my foot slipped.',
      minAge: 65,
      maxAge: 100,
      weight: 8,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'doctor',
          label: 'Go straight to the doctor',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'A bruise and a warning. I will use the handrail now.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.happiness, -1)],
              moneyBase: -8000,
            ),
            LifeOutcome(
              text: 'A sprain. Rest and ice.',
              stats: [StatEffect(StatKey.health, -3), StatEffect(StatKey.fitness, -2)],
              moneyBase: -8000,
            ),
          ],
        ),
        LifeChoice(
          id: 'tough',
          label: 'Tough it out',
          outcomes: [
            LifeOutcome(
              text: 'It healed slowly, and I got grumpy.',
              stats: [StatEffect(StatKey.health, -5), StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              text: 'I was fine after a week. Lucky me.',
              stats: [StatEffect(StatKey.luck, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'pension_stress',
      title: 'Rising Prices',
      description: 'Groceries cost more than I remembered.',
      minAge: 60,
      maxAge: 100,
      weight: 8,
      choices: [
        LifeChoice(
          id: 'coupon',
          label: 'Cut coupons and plan meals',
          outcomes: [
            LifeOutcome(
              text: 'I became a coupon wizard.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, 1)],
              moneyBase: 5000,
            ),
          ],
        ),
        LifeChoice(
          id: 'family',
          label: 'Ask family for help',
          outcomes: [
            LifeOutcome(
              text: 'They did not mind at all. I minded a little.',
              stats: [StatEffect(StatKey.happiness, -1)],
              siblingRelation: 3,
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Pretend nothing changed',
          outcomes: [
            LifeOutcome(
              text: 'My wallet noticed anyway.',
              stats: [StatEffect(StatKey.happiness, -2)],
              moneyBase: -8000,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'life_story',
      title: 'Telling My Story',
      description: 'My family asked me to tell them about my life.',
      minAge: 65,
      maxAge: 100,
      weight: 7,
      cooldownYears: 10,
      autoOutcomes: [
        LifeOutcome(
          text: 'I talked for hours. They listened with wide eyes and warm tea.',
          stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
        ),
        LifeOutcome(
          text: 'I told embarrassing stories and everyone cried laughing.',
          stats: [StatEffect(StatKey.happiness, 3)],
        ),
      ],
    ),
  ];
}
