import '../../domain/event/life_event.dart';

/// How a partner reacts when an affair comes out, by temperament. The
/// game picks the scene that fits the partner right after "Have Sex" with
/// someone else gets found out (see `Temperament`). The calm version is
/// `cheating_caught` / `marriage_caught` in the marriage catalog.
///
/// A hothead explodes and is more likely to leave. A tender partner is
/// crushed but easier to win back.
abstract final class LifeEventCatalogCaught {
  static const List<LifeEventDefinition> all = [
    LifeEventDefinition(
      id: 'cheating_caught_hothead',
      title: 'Caught Cheating',
      description:
          '{Name} burst in, waving a phone like a weapon. "EXPLAIN THIS. '
          'RIGHT NOW!" The whole street heard it.',
      minAge: 18,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['player_cheated'],
      forbiddenFlags: ['married'],
      scripted: true,
      choices: [
        LifeChoice(
          id: 'apologize',
          label: 'Apologize sincerely',
          outcomes: [
            LifeOutcome(
              text: '{first} screamed for ten minutes, cried for ten more, '
                  'and then slowly, painfully, forgave me. One chance.',
              removeFlags: ['player_cheated'],
              subjectRelation: -25,
              stats: [StatEffect(StatKey.happiness, -6)],
            ),
            LifeOutcome(
              weight: 3,
              text: '"Do not you DARE say sorry!" {first} threw my things '
                  'into the street. We are done.',
              addFlags: ['breakup_filed'],
            ),
          ],
        ),
        LifeChoice(
          id: 'flowers',
          label: 'Beg with flowers and a gift',
          requiresMoneyBase: 10000,
          outcomes: [
            LifeOutcome(
              text: '{first} hit me with the bouquet, twice, then burst into '
                  'tears and let me stay. Petals everywhere.',
              moneyBase: -10000,
              removeFlags: ['player_cheated'],
              subjectRelation: -18,
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
            LifeOutcome(
              weight: 2,
              text: '{first} ripped the card in half and slammed the door. '
                  'The flowers are a very expensive goodbye.',
              moneyBase: -10000,
              addFlags: ['breakup_filed'],
            ),
          ],
        ),
        LifeChoice(
          id: 'deny',
          label: 'Deny everything',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: '{first} threw the phone at the wall to prove a point. '
                  'The relationship went with it.',
              addFlags: ['breakup_filed'],
            ),
            LifeOutcome(
              text: 'I lied with a straight face. {first} still stormed '
                  'out, but came back. The doubt is loud now.',
              subjectRelation: -15,
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'cheating_caught_tender',
      title: 'Caught Cheating',
      description:
          '{Name} did not shout. {He} sat down, eyes red, voice cracking: '
          '"Just tell me it is not true." That hurt more than any scream.',
      minAge: 18,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['player_cheated'],
      forbiddenFlags: ['married'],
      scripted: true,
      choices: [
        LifeChoice(
          id: 'apologize',
          label: 'Apologize sincerely',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: '{first} cried into my shoulder and forgave me. It '
                  'felt less like a win and more like a debt.',
              removeFlags: ['player_cheated'],
              subjectRelation: -12,
              stats: [StatEffect(StatKey.happiness, -4)],
            ),
            LifeOutcome(
              text: '"I wanted to believe you," whispered {first}. Then '
                  '{He} left, quietly. It was over.',
              addFlags: ['breakup_filed'],
            ),
          ],
        ),
        LifeChoice(
          id: 'flowers',
          label: 'Beg with flowers and a gift',
          requiresMoneyBase: 10000,
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: '{first} held the flowers and sobbed. "Do not ever do '
                  'this again." I will not. I swear.',
              moneyBase: -10000,
              removeFlags: ['player_cheated'],
              subjectRelation: -8,
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              text: '{first} set the flowers down gently and said, "I '
                  'cannot." That gentleness ended us.',
              moneyBase: -10000,
              addFlags: ['breakup_filed'],
            ),
          ],
        ),
        LifeChoice(
          id: 'deny',
          label: 'Deny everything',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: '{first} looked at me for a long time. "You are lying '
                  'to my face." Then {He} walked out.',
              addFlags: ['breakup_filed'],
            ),
            LifeOutcome(
              weight: 2,
              text: '{first} wanted so badly to believe me that {He} '
                  'almost did. The doubt will not leave.',
              subjectRelation: -10,
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'marriage_caught_hothead',
      title: 'Caught',
      description:
          '{Name} flung my phone across the room. "Every. Single. '
          'Message!" The neighbors were definitely listening.',
      minAge: 21,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['married', 'player_cheated'],
      scripted: true,
      choices: [
        LifeChoice(
          id: 'confess',
          label: 'Confess and apologize',
          outcomes: [
            LifeOutcome(
              text: '{first} shouted until the windows shook, then sat on '
                  'the floor and cried. {He} is staying, for now. Last '
                  'chance.',
              removeFlags: ['player_cheated'],
              subjectRelation: -25,
              stats: [StatEffect(StatKey.happiness, -6)],
            ),
            LifeOutcome(
              weight: 3,
              text: '"GET OUT!" Then, quieter: "The lawyer will call." '
                  '{first} had clearly practiced this.',
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
        LifeChoice(
          id: 'deny',
          label: 'Deny everything',
          outcomes: [
            LifeOutcome(
              text: '{first} read my messages out loud, in funny voices. '
                  'Nobody laughed. The divorce papers followed.',
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
        LifeChoice(
          id: 'counseling',
          label: 'Beg for couples counseling',
          requiresMoneyBase: 40000,
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'The counselor had to separate us twice. Somehow '
                  '{first} agreed to try again.',
              moneyBase: -40000,
              removeFlags: ['player_cheated'],
              subjectRelation: -12,
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              weight: 2,
              text: '{first} stormed out of the second session. The '
                  'counselor sent a bill, and the papers followed.',
              moneyBase: -40000,
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'marriage_caught_tender',
      title: 'Caught',
      description:
          '{Name} placed my phone on the table, very gently. "I read '
          'everything," {He} said, and the tears started before {He} '
          'finished.',
      minAge: 21,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['married', 'player_cheated'],
      scripted: true,
      choices: [
        LifeChoice(
          id: 'confess',
          label: 'Confess and apologize',
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: '{first} held my hand through the worst of it. "I am '
                  'not ready to give up on us. Do not make me regret '
                  'this."',
              removeFlags: ['player_cheated'],
              subjectRelation: -12,
              stats: [StatEffect(StatKey.happiness, -5)],
            ),
            LifeOutcome(
              text: '"I loved you so much," said {first}, in the past '
                  'tense. The papers came a week later.',
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
        LifeChoice(
          id: 'deny',
          label: 'Deny everything',
          outcomes: [
            LifeOutcome(
              text: '{first} just nodded, packed a small bag, and left '
                  'the ring by the sink. No scene. That was the scene.',
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
        LifeChoice(
          id: 'counseling',
          label: 'Beg for couples counseling',
          requiresMoneyBase: 40000,
          outcomes: [
            LifeOutcome(
              weight: 4,
              text: 'The counselor passed us the tissues. {first} '
                  'whispered, "Okay. One more try."',
              moneyBase: -40000,
              removeFlags: ['player_cheated'],
              subjectRelation: -6,
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              text: 'Halfway through the session {first} said, softly, '
                  '"I cannot be here." It is over.',
              moneyBase: -40000,
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
      ],
    ),
  ];
}
