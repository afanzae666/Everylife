import '../../domain/event/life_event.dart';

/// University events for the newer fields of study. A student only sees the
/// events of the major they study (see `LifeEventCatalogMajors`).
abstract final class LifeEventCatalogMoreMajors {
  static const List<LifeEventDefinition> all = [
    LifeEventDefinition(
      id: 'uni_psychology_experiment',
      title: 'The Class Experiment',
      description:
          'The professor needed volunteers for a study on how people make decisions. Free coffee was mentioned.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_psychology'],
      choices: [
        LifeChoice(
          id: 'volunteer',
          label: 'Volunteer as a subject',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'I learned a lot about myself, mostly that I am very easy to predict.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'The coffee was cold and the study took three hours. I did learn something.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'run',
          label: 'Help run the experiment',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'Running it showed me how careful real research has to be.',
              stats: [StatEffect(StatKey.intelligence, 3)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I mixed up two groups of data and we had to start over.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_psychology_counseling',
      title: 'The Late Night Talk',
      description:
          'A classmate asked if I had a minute. It turned into two hours on a bench outside the library.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_psychology'],
      choices: [
        LifeChoice(
          id: 'listen',
          label: 'Just listen',
          outcomes: [
            LifeOutcome(
              text:
                  'They said it helped more than they expected. I felt strangely proud.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'advise',
          label: 'Give advice like a real psychologist',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'My advice actually worked, and they thanked me the next day.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I said something textbook-ish and it did not land at all.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_science_lab',
      title: 'The Lab Accident',
      description:
          'Something in my beaker turned a colour that is not in the lab manual.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_science'],
      choices: [
        LifeChoice(
          id: 'report',
          label: 'Call the lab assistant right away',
          outcomes: [
            LifeOutcome(
              text:
                  'Everyone was calm, I got a lecture on safety, and a gold star for honesty.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'fix',
          label: 'Try to fix it myself',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'It cleared up and I wrote it up as a discovery. The professor smiled.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'It fizzed over the bench and I spent two hours mopping.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.health, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_science_fieldtrip',
      title: 'The Field Trip',
      description:
          'The whole class was driven out to a muddy field to measure things with expensive instruments.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_science'],
      choices: [
        LifeChoice(
          id: 'dive',
          label: 'Dive in, get muddy',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'I found the sample the professor was looking for. Mud and all.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.fitness, 1), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I slipped into a stream. The instrument survived. My dignity did not.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.health, -1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'notes',
          label: 'Stay clean and take careful notes',
          outcomes: [
            LifeOutcome(
              text:
                  'My notes were the only ones that were readable. I became very popular before exams.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_architecture_model',
      title: 'The Scale Model',
      description:
          'The studio deadline was tomorrow, and my cardboard tower was still leaning slightly to the left.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_architecture'],
      choices: [
        LifeChoice(
          id: 'allnighter',
          label: 'Pull an all-nighter',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'The tower stood straight at dawn. I looked terrible, but so did everyone.',
              stats: [StatEffect(StatKey.creativity, 3), StatEffect(StatKey.willpower, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I fell asleep with glue in my hair and the tower fell over too.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'redesign',
          label: 'Redesign it as a bold lean',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'The critic called it intentional. I nodded like it was.',
              stats: [StatEffect(StatKey.creativity, 3), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'The critic called it a crime against gravity.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.creativity, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_architecture_critique',
      title: 'The Studio Critique',
      description:
          'My design was pinned on the wall, and a visiting architect was walking toward it with a very sharp pencil.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_architecture'],
      choices: [
        LifeChoice(
          id: 'defend',
          label: 'Defend every line',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'I argued my case and the visitor changed their mind.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.creativity, 1)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'My defence fell apart at the second question.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'listen',
          label: 'Listen and take notes',
          outcomes: [
            LifeOutcome(
              text:
                  'Their notes made my next design much better.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.creativity, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_communications_podcast',
      title: 'The Campus Podcast',
      description:
          'The class had to make a podcast episode. Ours was supposed to be about tuition, but it got interesting.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_communications'],
      choices: [
        LifeChoice(
          id: 'host',
          label: 'Be the host',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'My voice sounded better than I thought and strangers started to recognise it.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I said "um" forty-two times. Someone counted.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'edit',
          label: 'Edit in the background',
          outcomes: [
            LifeOutcome(
              text:
                  'The episode sounded smooth because of me. Only I knew.',
              stats: [StatEffect(StatKey.creativity, 2), StatEffect(StatKey.intelligence, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_communications_interview',
      title: 'The Big Interview',
      description:
          'My assignment: interview a real local business owner for the student magazine.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_communications'],
      choices: [
        LifeChoice(
          id: 'prepared',
          label: 'Prepare twenty questions',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'The owner opened up and I got a story the teacher wanted to print.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.intelligence, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'The owner answered every question with one word.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'wing',
          label: 'Wing it and see where it goes',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'It turned into a wonderful conversation.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I forgot to press record.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_pharmacy_compounding',
      title: 'Compounding Class',
      description:
          'We had to mix a medicine from scratch, and the grams on the scale mattered more than anyone else\'s opinion.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_pharmacy'],
      choices: [
        LifeChoice(
          id: 'precise',
          label: 'Measure everything three times',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'Perfect result. The instructor called it a textbook example.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.willpower, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'So careful that I ran out of time and handed in half.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'fast',
          label: 'Work fast and trust the maths',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'I finished first and got it right.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'A decimal point slipped, and I had to redo the whole batch.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.intelligence, 1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_pharmacy_interactions',
      title: 'The Drug Interaction Quiz',
      description:
          'A surprise quiz on which medicines should never meet. The list was very long.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_pharmacy'],
      choices: [
        LifeChoice(
          id: 'study',
          label: 'Memorise the list the night before',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'I remembered nearly all of it. My head hurt, but it worked.',
              stats: [StatEffect(StatKey.intelligence, 3), StatEffect(StatKey.willpower, 1)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I mixed up two names and lost a lot of points.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.intelligence, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'group',
          label: 'Study together in a group',
          outcomes: [
            LifeOutcome(
              text:
                  'We quizzed each other until we all knew it. A great evening.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.charisma, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_dentistry_models',
      title: 'The Plastic Teeth',
      description:
          'We practised on plastic teeth first. The instructor said real patients do not hold still politely either.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_dentistry'],
      choices: [
        LifeChoice(
          id: 'steady',
          label: 'Slow and careful',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'My filling was flawless. The instructor nodded, which is rare.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.willpower, 3)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'Too slow. The clock ran out before the tooth was finished.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'bold',
          label: 'Speed through it',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'Fast and clean. Perhaps I was born for this.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.intelligence, 1)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I drilled where I should not have. The plastic did not mind. The grade did.',
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_dentistry_patient',
      title: 'First Real Patient',
      description:
          'My first real patient sat down in the chair and asked me how many people I had done this on. I said "a few".',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_dentistry'],
      choices: [
        LifeChoice(
          id: 'honest',
          label: 'Tell the truth, supervised by the instructor',
          outcomes: [
            LifeOutcome(
              text:
                  'The patient laughed, and the instructor stayed close. All went fine.',
              stats: [StatEffect(StatKey.willpower, 2), StatEffect(StatKey.charisma, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'confident',
          label: 'Act confident and get on with it',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'My steady hands surprised even me. The patient smiled afterwards.',
              stats: [StatEffect(StatKey.charisma, 3), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'My hands shook so much the instructor took over.',
              stats: [StatEffect(StatKey.happiness, -4), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_aviation_simulator',
      title: 'The Flight Simulator',
      description:
          'My first hour in the flight simulator. Everything looked like a lot of buttons.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_aviation'],
      choices: [
        LifeChoice(
          id: 'manual',
          label: 'Follow the manual exactly',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'A smooth take-off and a smoother landing. The instructor said I was a natural.',
              stats: [StatEffect(StatKey.intelligence, 2), StatEffect(StatKey.willpower, 2), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'Too much reading, not enough flying. I overshot the runway.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.willpower, 1)],
            ),
          ],
        ),
        LifeChoice(
          id: 'feel',
          label: 'Fly by feel',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'It worked, and I felt like a real pilot.',
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.luck, 1)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'I landed in a field. A virtual field, thankfully.',
              stats: [StatEffect(StatKey.happiness, -3), StatEffect(StatKey.luck, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'uni_aviation_checkride',
      title: 'The First Real Flight',
      description:
          'My first flight with an instructor in a tiny plane. The ground looked very far away.',
      minAge: 18,
      maxAge: 30,
      weight: 12,
      requiredFlags: ['university_student', 'studying_aviation'],
      choices: [
        LifeChoice(
          id: 'calm',
          label: 'Stay calm and focus',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text:
                  'The flight was perfect. I almost forgot to be scared.',
              stats: [StatEffect(StatKey.willpower, 3), StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'Turbulence made me sick before we landed. Still, I finished the lesson.',
              stats: [StatEffect(StatKey.health, -2), StatEffect(StatKey.willpower, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'talk',
          label: 'Talk the whole time to calm my nerves',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text:
                  'The instructor laughed and we both enjoyed it.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 2)],
            ),
            LifeOutcome(
              weight: 2,
              text:
                  'The instructor asked me to please be quiet, politely.',
              stats: [StatEffect(StatKey.happiness, -2), StatEffect(StatKey.charisma, 1)],
            ),
          ],
        ),
      ],
    ),
  ];
}
