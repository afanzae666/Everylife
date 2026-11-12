import '../../domain/event/life_event.dart';

/// University events that belong to one field of study. A student only sees
/// the events of the major they study. Flags are set by the education system
/// (see `SystemFlags.studying`).
abstract final class LifeEventCatalogMajors {
  static const List<LifeEventDefinition> all = [
    LifeEventDefinition(
      id: 'uni_business_pitch',
      title: 'The Pitch Competition',
      description:
          'Our class entered a startup pitch competition. Three minutes, one slide deck, a panel of very serious people in blazers.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_business'],
      choices: [
        LifeChoice(
          id: 'lead',
          label: 'Lead the pitch',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'I owned the room. The panel asked real questions, and I had real answers.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I froze on slide two and improvised the rest. Somehow it still got a polite clap.',
              stats: [StatEffect(StatKey.charisma, 1), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'behind',
          label: 'Build the slides, stay behind the scenes',
          outcomes: [
            LifeOutcome(
              text:
                  'The slides were gorgeous and my teammate got the applause. I got the satisfaction.',
              stats: [StatEffect(StatKey.intelligence, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'skip',
          label: 'Let the team handle it',
          outcomes: [
            LifeOutcome(
              text:
                  'They placed third without me. I told myself I did not mind.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_business_stock_game',
      title: 'Stock Market Game',
      description:
          'The professor handed every student a pretend portfolio and a deadline.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_business'],
      choices: [
        LifeChoice(
          id: 'bold',
          label: 'Bet everything on one hot stock',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'It tripled. I told everyone I had always known it would.',
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.intelligence, 1)],
            ),
            LifeOutcome(
              weight: 3,
              text:
                  'It crashed on Tuesday. Good thing the money was fake.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'safe',
          label: 'Spread it out and stay boring',
          outcomes: [
            LifeOutcome(
              text:
                  'My boring portfolio finished above average. Boring pays, apparently.',
              stats: [StatEffect(StatKey.intelligence, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_engineering_bridge',
      title: 'The Bridge Project',
      description:
          'Our team had to build a bridge out of spaghetti and glue, then watch a machine try to break it.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_engineering'],
      choices: [
        LifeChoice(
          id: 'calc',
          label: 'Calculate every load twice',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'The bridge held more weight than anyone expected. The professor looked genuinely surprised.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              text:
                  'My math was right. My glue was not. It collapsed gracefully.',
              stats: [StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'wing',
          label: 'Trust the gut and glue it',
          outcomes: [
            LifeOutcome(
              text:
                  'It held, and nobody could explain why. I am not going to ask.',
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              text:
                  'It sagged like a sad hammock, and the whole class laughed.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_engineering_lab_smoke',
      title: 'Smoke in the Lab',
      description:
          'During a lab session, a circuit started smoking and the fire alarm joined in.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_engineering'],
      choices: [
        LifeChoice(
          id: 'calm',
          label: 'Stay calm and cut the power',
          outcomes: [
            LifeOutcome(
              text:
                  'I flipped the right switch. The lab tech gave me a nod I will remember for years.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.intelligence, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'run',
          label: 'Run for the door',
          outcomes: [
            LifeOutcome(
              text:
                  'Running was a sensible decision, until I tripped on the stairs. The circuit and I both needed a break.',
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.health, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_cs_hackathon',
      title: 'The Hackathon',
      description:
          'A weekend hackathon: free pizza, no sleep and a prize for whoever ships something that works.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_computerScience'],
      choices: [
        LifeChoice(
          id: 'all_in',
          label: 'Go all in and code all weekend',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'We shipped a working demo at 5 AM and won a trophy shaped like a USB stick.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, 3), StatEffect(StatKey.health, -2)],
            ),
            LifeOutcome(
              weight: 3,
              text:
                  'The demo crashed on stage. The pizza was still great.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.health, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'pizza',
          label: 'Show up for the pizza',
          outcomes: [
            LifeOutcome(
              text:
                  'I made friends over the last slice and wrote about forty lines of code.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_cs_bug_hunt',
      title: 'The Bug',
      description:
          'My program worked on my laptop and nowhere else. The deadline was tonight.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_computerScience'],
      choices: [
        LifeChoice(
          id: 'debug',
          label: 'Debug it line by line',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'It was a missing semicolon. Of course it was.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.willpower, 2)],
            ),
            LifeOutcome(
              text:
                  'Six hours later I found the bug in a file I had not touched. I do not want to talk about it.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'rewrite',
          label: 'Delete everything and rewrite it',
          outcomes: [
            LifeOutcome(
              text:
                  'The rewrite took an hour and ran perfectly. A little humbling.',
              stats: [StatEffect(StatKey.intelligence, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_law_moot_court',
      title: 'Moot Court',
      description:
          'The class staged a mock trial. I was assigned the side nobody wanted.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_law'],
      choices: [
        LifeChoice(
          id: 'argue',
          label: 'Argue like my life depends on it',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'The judge said my closing was the best of the semester. I walked home a few inches taller.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I lost, but I lost with style. The judge said so herself. My pride still hurt.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'prepare',
          label: 'Prepare quietly and let my partner speak',
          outcomes: [
            LifeOutcome(
              text:
                  'Our research was flawless, and my partner did the talking. We split the credit.',
              stats: [StatEffect(StatKey.intelligence, 3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_law_case_reading',
      title: 'The Reading List',
      description:
          'The weekly reading list was 400 pages of old court cases, written by people who hated short sentences.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_law'],
      choices: [
        LifeChoice(
          id: 'read',
          label: 'Read all of it',
          outcomes: [
            LifeOutcome(
              text:
                  'It took the whole weekend, and I finally understood why the rule exists. Annoying, but true.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'summary',
          label: 'Read a classmate\'s summary instead',
          outcomes: [
            LifeOutcome(
              text:
                  'The summary was wrong in one important place. The professor found it. So did my grade.',
              stats: [StatEffect(StatKey.intelligence, -1), StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              text:
                  'The summary was perfect. I owe that classmate a coffee.',
              stats: [StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_education_practicum',
      title: 'Teaching Practicum',
      description:
          'For the first time I stood in front of a real classroom, with a real teacher watching from the back.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_education'],
      choices: [
        LifeChoice(
          id: 'plan',
          label: 'Follow my lesson plan exactly',
          outcomes: [
            LifeOutcome(
              text:
                  'The lesson ran to the minute. The kids looked politely bored. The teacher smiled.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'improv',
          label: 'Toss the plan and improvise',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'A child asked a wild question and the whole class ran with it. Best lesson I have taught.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              text:
                  'The improvisation ended with chalk on the ceiling. The teacher took notes, and my confidence took a small hit.',
              stats: [StatEffect(StatKey.charisma, 1), StatEffect(StatKey.willpower, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_education_tutoring',
      title: 'Tutoring a Struggling Kid',
      description:
          'The university paired me with a kid who hated maths with an almost scientific passion.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_education'],
      choices: [
        LifeChoice(
          id: 'patient',
          label: 'Be patient, one problem at a time',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'After a month, the kid solved a problem alone and shouted about it. I got teary behind my notebook.',
              stats: [StatEffect(StatKey.happiness, 5), StatEffect(StatKey.willpower, 2)],
            ),
            LifeOutcome(
              text:
                  'Progress was slow, but we both kept showing up. That counts for something.',
              stats: [StatEffect(StatKey.willpower, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'quit',
          label: 'Ask for a different student',
          outcomes: [
            LifeOutcome(
              text:
                  'They gave me a different student. I still think about the first one.',
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_arts_exhibition',
      title: 'The Student Exhibition',
      description:
          'The department invited everyone to show one piece in the end-of-term exhibition.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_artsDesign'],
      choices: [
        LifeChoice(
          id: 'bold',
          label: 'Show my boldest, strangest piece',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'People stood in front of it for a long time. Someone asked the price.',
              stats: [StatEffect(StatKey.happiness, 4), StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'Half the visitors loved it, half walked away. The walking away stung more than I admitted.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'safe',
          label: 'Show something safe and polished',
          outcomes: [
            LifeOutcome(
              text:
                  'It looked lovely and nobody remembered it by the weekend.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_arts_critique',
      title: 'Brutal Critique',
      description:
          'Critique day. Every student pins their work on the wall and the professor says exactly what she thinks.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_artsDesign'],
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Listen and take notes',
          outcomes: [
            LifeOutcome(
              text:
                  'It stung, but every sentence she said was true. My next piece was a lot better.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.willpower, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'defend',
          label: 'Defend my work out loud',
          outcomes: [
            LifeOutcome(
              text:
                  'We argued for twenty minutes. She grinned and said that was the most honest thing I had said all term.',
              stats: [StatEffect(StatKey.charisma, 2)],
            ),
            LifeOutcome(
              text:
                  'I sounded defensive, and everyone could tell. Lesson learned.',
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
  ];
}
