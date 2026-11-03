import '../../domain/event/life_event.dart';

/// Events that game systems start on purpose (they never come up at random).
abstract final class ScriptedEvents {
  /// A parent died and the player is an adult who arranges the funeral.
  static const String funeral = 'funeral';

  /// A parent died and the player is a child watching the grown-ups.
  static const String funeralFamily = 'funeral_family';

  static const List<LifeEventDefinition> all = [
    LifeEventDefinition(
      id: funeral,
      title: 'Saying Goodbye',
      description:
          'The phone call was short, and the silence after it was long. '
          'Now I had to decide how to say goodbye to {who}.',
      minAge: 18,
      maxAge: 150,
      scripted: true,
      choices: [
        LifeChoice(
          id: 'burial',
          label: 'Traditional burial',
          requiresMoneyBase: 600000,
          narration: 'We held a traditional burial.',
          outcomes: [
            LifeOutcome(
              text: 'We laid {who} to rest under an old tree. '
                  'It was a dignified goodbye.',
              moneyBase: -600000,
              stats: [StatEffect(StatKey.happiness, 2), StatEffect(StatKey.willpower, 1)],
              parentRelation: 3,
              siblingRelation: 3,
            ),
          ],
        ),
        LifeChoice(
          id: 'cremation',
          label: 'Cremation',
          requiresMoneyBase: 250000,
          narration: 'We chose a cremation.',
          outcomes: [
            LifeOutcome(
              text: 'We scattered the ashes of {who} somewhere they loved. '
                  'The wind carried a little of my grief away.',
              moneyBase: -250000,
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.creativity, 1)],
              parentRelation: 2,
              siblingRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'preserve',
          label: 'Embalming and a private mausoleum',
          requiresMoneyBase: 1500000,
          narration: 'We paid for embalming and a private mausoleum.',
          outcomes: [
            LifeOutcome(
              weight: 3,
              text: 'The mausoleum was grand and quiet. '
                  'Visiting {who} there feels like stopping by for tea.',
              moneyBase: -1500000,
              stats: [StatEffect(StatKey.happiness, 3), StatEffect(StatKey.charisma, 1)],
              parentRelation: 3,
              siblingRelation: 3,
            ),
            LifeOutcome(
              weight: 1,
              text: 'The mausoleum was beautiful, but the bill made me '
                  'dizzy. {who} would have said it was far too much.',
              moneyBase: -1500000,
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.willpower, -1)],
              siblingRelation: 1,
            ),
          ],
        ),
        LifeChoice(
          id: 'simple',
          label: 'Simple municipal service',
          narration: 'I kept the service as simple as I could.',
          outcomes: [
            LifeOutcome(
              text: 'A short ceremony, no flowers, and a lot of quiet. '
                  'The guilt of doing so little for {who} will visit me later.',
              stats: [StatEffect(StatKey.happiness, -3)],
              parentRelation: -2,
            ),
          ],
        ),
      ],
    ),
    LifeEventDefinition(
      id: funeralFamily,
      title: 'The Funeral',
      description:
          'The grown-ups spoke in low voices and arranged everything for {who}. '
          'I stood in my best clothes, not sure where to look.',
      minAge: 0,
      maxAge: 17,
      scripted: true,
      choices: [
        LifeChoice(
          id: 'hold_hand',
          label: 'Hold a relative\'s hand',
          narration: 'I held a relative\'s hand the whole time.',
          outcomes: [
            LifeOutcome(
              text: 'Their hand was warm and a little shaky. '
                  'We said goodbye to {who} together.',
              stats: [StatEffect(StatKey.happiness, 1), StatEffect(StatKey.willpower, 1)],
              parentRelation: 2,
              siblingRelation: 2,
            ),
          ],
        ),
        LifeChoice(
          id: 'say_words',
          label: 'Say a few words',
          narration: 'I stepped forward to say a few words.',
          outcomes: [
            LifeOutcome(
              weight: 2,
              text: 'My voice cracked, but I told everyone how much '
                  '{who} meant to me. Nobody had a dry eye.',
              stats: [StatEffect(StatKey.charisma, 2), StatEffect(StatKey.happiness, 1)],
              parentRelation: 3,
            ),
            LifeOutcome(
              weight: 1,
              text: 'The words got stuck, and I cried instead. '
                  'A cousin hugged me until it passed.',
              stats: [StatEffect(StatKey.happiness, -2)],
            ),
          ],
        ),
        LifeChoice(
          id: 'stay_silent',
          label: 'Stay quiet and watch',
          narration: 'I stayed quiet and watched everything.',
          outcomes: [
            LifeOutcome(
              text: 'I did not cry, and I did not understand why. '
                  'It hit me much later, at bedtime.',
              stats: [StatEffect(StatKey.happiness, -3)],
            ),
          ],
        ),
      ],
    ),
  ];
}
