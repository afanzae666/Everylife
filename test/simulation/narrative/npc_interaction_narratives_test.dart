import 'package:everylife/core/random/seeded_random.dart';
import 'package:everylife/domain/character/life_stage.dart';
import 'package:everylife/presentation/widgets/event_icons.dart';
import 'package:everylife/simulation/narrative/npc_interaction_narratives.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every interaction has many different first-person stories', () {
    for (final action in const [
      'Talk',
      'Spend Time',
      'Compliment',
      'Help',
      'Argue',
      'Apologize',
    ]) {
      final random = SeededRandom(7);
      final stories = <String>{
        for (var i = 0; i < 60; i++)
          NpcInteractionNarratives.pick(
            random: random,
            action: action,
            npcName: 'Olivia Hart',
            stage: LifeStage.adult,
            kind: NpcKind.sibling,
            score: 40,
          ),
      };

      expect(stories.length, greaterThan(15), reason: action);
      expect(stories.every((story) => story.startsWith('I ')), isTrue);
      expect(stories.every((story) => story.contains('Olivia Hart')), isTrue,
          reason: action);
    }
  });

  test('life events get different icons', () {
    final icons = {
      lifeEventEmoji(id: 'first_steps'),
      lifeEventEmoji(id: 'school_bully'),
      lifeEventEmoji(id: 'lottery_ticket'),
      lifeEventEmoji(id: 'work_promotion_offer'),
      lifeEventEmoji(id: 'health_scare'),
    };

    expect(icons.length, 5);
  });
}
