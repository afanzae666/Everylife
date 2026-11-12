import '../../domain/event/life_event.dart';

/// Events of married life: anniversaries and a spouse who wants out.
///
/// A divorce started by a spouse is carried out by the game when an outcome
/// adds `divorce_filed_unclear` (no reason: the spouse pays a fine).
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
      id: 'marriage_wants_out',
      title: 'It Is Not Working',
      description:
          '{Name} sat me down. "I am not happy anymore. I cannot tell '
          'you why. I just want out."',
      minAge: 21,
      maxAge: 110,
      about: EventSubjectKind.partner,
      requiredFlags: ['married'],
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
