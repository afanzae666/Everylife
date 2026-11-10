import '../../domain/event/life_event.dart';

/// Events of married life: anniversaries, cheating, forgiveness and the
/// divorces that follow.
///
/// A divorce started by a spouse is carried out by the game when an outcome
/// adds `divorce_filed_clear` (the player gave clear grounds, so no fine) or
/// `divorce_filed_unclear` (no reason: the spouse pays a fine).
abstract final class LifeEventCatalogMarriage {
  static const List<LifeEventDefinition> all = [
    LifeEventDefinition(
      id: 'marriage_anniversary',
      title: 'Anniversary',
      description:
          'It is our anniversary, and {name} is pretending not to care. '
          '{He} cares a lot.',
      minAge: 18,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['married'],
      weight: 14,
      cooldownYears: 2,
      choices: [
        LifeChoice(
          id: 'dinner',
          label: 'Book a fancy dinner',
          requiresMoneyBase: 20000,
          outcomes: [
            LifeOutcome(
              text: '{first} cried over the dessert. I paid the bill and '
                  'somehow felt rich.',
              moneyBase: -20000,
              subjectRelation: 9,
              stats: [StatEffect(StatKey.happiness, 5)],
            ),
          ],
        ),
        LifeChoice(
          id: 'home',
          label: 'Cook at home',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'The pasta was only slightly burnt. {first} ate it '
                  'with a smile.',
              subjectRelation: 6,
              stats: [StatEffect(StatKey.happiness, 3)],
            ),
            LifeOutcome(
              text: 'The kitchen smelled like smoke for three days, but '
                  '{first} laughed until tears came.',
              subjectRelation: 4,
              stats: [StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'forget',
          label: 'Pretend I forgot',
          outcomes: [
            LifeOutcome(
              text: 'I forgot for real. {first} noticed. The silence at '
                  'dinner was brutal.',
              subjectRelation: -14,
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'marriage_suspicious_phone',
      title: 'Suspicious Messages',
      description:
          'A late-night message lit up {name}\'s phone: "Last night was '
          'amazing. Same time tomorrow?" It was not from me.',
      minAge: 18,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['married'],
      forbiddenFlags: ['spouse_cheated'],
      weight: 6,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'confront',
          label: 'Confront {name}',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: '{first} went pale and admitted everything. I have '
                  'clear proof now, and a broken heart.',
              addFlags: ['spouse_cheated'],
              subjectRelation: -30,
              stats: [StatEffect(StatKey.happiness, -12)],
            ),
            LifeOutcome(
              text: 'It was my surprise party being planned. I now feel '
                  'terrible, and {first} is hurt that I did not trust '
                  '{him}.',
              subjectRelation: -6,
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'investigator',
          label: 'Hire a private investigator',
          requiresMoneyBase: 30000,
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'The investigator returned with photos. {first} was '
                  'cheating, and now I can prove it.',
              moneyBase: -30000,
              addFlags: ['spouse_cheated'],
              subjectRelation: -25,
              stats: [StatEffect(StatKey.happiness, -10)],
            ),
            LifeOutcome(
              text: 'The investigator found nothing but a secret pottery '
                  'class. {first} was planning to surprise me with a '
                  'mug. I paid for nothing.',
              moneyBase: -30000,
              subjectRelation: 3,
            ),
          ],
        ),
        LifeChoice(
          id: 'ignore',
          label: 'Pretend I saw nothing',
          outcomes: [
            LifeOutcome(
              text: 'I locked it away in my mind. The doubt sits in my '
                  'chest like a stone.',
              stats: [StatEffect(StatKey.happiness, -4)],
              subjectRelation: -3,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'marriage_forgiveness',
      title: 'Forgiveness',
      description:
          '{name} stands at the door, eyes red, begging for a second '
          'chance after the cheating.',
      minAge: 18,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['married', 'spouse_cheated'],
      weight: 10,
      cooldownYears: 3,
      choices: [
        LifeChoice(
          id: 'forgive',
          label: 'Forgive {name}',
          outcomes: [
            LifeOutcome(
              text: 'I forgave {first}. Trust will take years, but we are '
                  'trying.',
              removeFlags: ['spouse_cheated'],
              subjectRelation: 10,
              stats: [StatEffect(StatKey.happiness, 2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'cold',
          label: 'Keep {him} waiting',
          outcomes: [
            LifeOutcome(
              text: 'I closed the door. {first} sat outside for an hour, '
                  'which felt fair.',
              subjectRelation: -8,
              stats: [StatEffect(StatKey.happiness, -1)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'marriage_temptation',
      title: 'Temptation',
      description:
          '{Name} keeps flirting with me at work. The compliments are '
          'nice. Dangerous, but nice.',
      minAge: 21,
      maxAge: 70,
      about: EventSubjectKind.coworker,
      requiredFlags: ['married', 'employed'],
      forbiddenFlags: ['player_cheated'],
      weight: 6,
      cooldownYears: 6,
      choices: [
        LifeChoice(
          id: 'refuse',
          label: 'Shut it down',
          outcomes: [
            LifeOutcome(
              text: 'I told {first} I am happily married. Awkward, but '
                  'my conscience is clean.',
              stats: [StatEffect(StatKey.willpower, 3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'flirt',
          label: 'Flirt back, just a little',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Harmless fun, I told myself. I still felt guilty on '
                  'the way home.',
              stats: [StatEffect(StatKey.happiness, 1)],
            ),
            LifeOutcome(
              text: 'The flirting went too far. I crossed a line I cannot '
                  'uncross.',
              addFlags: ['player_cheated'],
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'affair',
          label: 'Start an affair',
          outcomes: [
            LifeOutcome(
              text: 'It started as a drink and ended with a secret. The '
                  'guilt is already heavy.',
              addFlags: ['player_cheated'],
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'marriage_caught',
      title: 'Caught',
      description:
          '{Name} slid a phone across the table. On the screen was every '
          'message I thought I deleted.',
      minAge: 21,
      maxAge: 120,
      about: EventSubjectKind.partner,
      requiredFlags: ['married', 'player_cheated'],
      weight: 20,
      cooldownYears: 1,
      choices: [
        LifeChoice(
          id: 'confess',
          label: 'Confess and apologize',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: '{first} cried, shouted, and then forgave me. Once. '
                  'It is my last chance.',
              removeFlags: ['player_cheated'],
              subjectRelation: -20,
              stats: [StatEffect(StatKey.happiness, -6)],
            ),
            LifeOutcome(
              weight: 3,
              text: '"I cannot do this anymore," said {first}. The '
                  'divorce papers were already signed.',
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
        LifeChoice(
          id: 'deny',
          label: 'Deny everything',
          outcomes: [
            LifeOutcome(
              text: '{first} laughed bitterly and showed me the photos. '
                  'I have never felt smaller.',
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
              weight: 3,
              text: 'The counselor gave us homework and tissues. {first} '
                  'agreed to try again.',
              moneyBase: -40000,
              removeFlags: ['player_cheated'],
              subjectRelation: -10,
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
            LifeOutcome(
              text: 'Three sessions in, {first} said it is over. The '
                  'counselor sent a bill.',
              moneyBase: -40000,
              addFlags: ['divorce_filed_clear'],
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: 'marriage_wants_out',
      title: 'It Is Not Working',
      description:
          '{Name} sat me down. "I am not happy anymore. I cannot tell '
          'you why. I just want out."',
      minAge: 21,
      maxAge: 110,
      about: EventSubjectKind.partner,
      requiredFlags: ['married'],
      forbiddenFlags: ['player_cheated', 'spouse_cheated'],
      weight: 3,
      cooldownYears: 8,
      choices: [
        LifeChoice(
          id: 'agree',
          label: 'Agree to the divorce',
          outcomes: [
            LifeOutcome(
              text: 'I nodded. There was nothing left to argue about. '
                  '{first} filed for divorce without a clear reason.',
              addFlags: ['divorce_filed_unclear'],
            ),
          ],
        ),
        LifeChoice(
          id: 'beg',
          label: 'Beg {him} to stay',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: '{first} sighed and stayed. Maybe it was a bad day, '
                  'maybe a bad year.',
              subjectRelation: 6,
            ),
            LifeOutcome(
              weight: 2,
              text: 'My begging only made {first} more certain. The '
                  'divorce is happening.',
              addFlags: ['divorce_filed_unclear'],
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
        LifeChoice(
          id: 'counseling',
          label: 'Suggest counseling',
          requiresMoneyBase: 40000,
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'Counseling worked better than expected. {first} is '
                  'smiling at me again.',
              moneyBase: -40000,
              subjectRelation: 12,
              stats: [StatEffect(StatKey.happiness, 4)],
            ),
            LifeOutcome(
              text: 'The counselor listened to us both and gave up. '
                  '{first} filed for divorce anyway.',
              moneyBase: -40000,
              addFlags: ['divorce_filed_unclear'],
            ),
          ],
        ),
      ],
    ),
  ];
}
