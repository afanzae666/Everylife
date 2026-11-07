import '../../core/random/seeded_random.dart';
import '../../domain/character/life_stage.dart';

/// Who the interaction is with. It changes the little details of the story.
enum NpcKind { parent, sibling, schoolmate }

/// Builds the first-person story shown after talking, helping, arguing...
/// with someone. Every story is a sentence from a large pool plus a random
/// detail and a mood ending, so the same button rarely tells the same story.
abstract final class NpcInteractionNarratives {
  static String pick({
    required SeededRandom random,
    required String action,
    required String npcName,
    required LifeStage stage,
    required NpcKind kind,
    required int score,
  }) {
    final n = npcName;
    final group = _group(stage);

    String choose(List<String> options) =>
        options[random.nextInt(options.length)];

    final topic = choose(_topics(group, kind));
    final praise = choose(_praise);
    final place = choose(_places(group, kind));
    final task = choose(_tasks(group, kind));
    final cause = choose(_causes(group, kind));

    final String opener = switch (action) {
      'Talk' => choose([
          'I talked with $n about $topic.',
          'I sat down with $n and we ended up talking about $topic.',
          'I told $n what I thought about $topic.',
          'I asked $n about $topic and listened to the answer.',
          'I brought up $topic with $n out of nowhere.',
          'I spent a while chatting with $n about $topic.',
          'I caught $n in a good moment and we talked about $topic.',
          'I let $n ramble about $topic, and I actually enjoyed it.',
        ]),
      'Spend Time' => choose([
          'I spent the afternoon with $n $place.',
          'I hung out with $n $place.',
          'I dragged $n along with me $place.',
          'I wandered $place with $n and lost track of time.',
          'I invited $n to join me $place.',
          'I made time for $n, and we ended up $place.',
          'I shared a quiet moment with $n $place.',
          'I tagged along with $n $place.',
        ]),
      'Compliment' => choose([
          'I told $n that I really admire $praise.',
          'I complimented $n on $praise.',
          'I said something kind to $n about $praise.',
          'I surprised $n by praising $praise.',
          'I looked at $n and said, "You are doing great."',
          'I let $n know how much they mean to me.',
          'I gave $n a sincere compliment out of the blue.',
          'I told $n I notice $praise, even when they do not.',
        ]),
      'Help' => choose([
          'I helped $n $task.',
          'I rolled up my sleeves and helped $n $task.',
          'I noticed $n needed a hand, so I stepped in and helped $task.',
          'I offered to help $n $task.',
          'I helped $n $task without being asked.',
          'I spent some time helping $n $task.',
          'I showed up for $n and helped $task.',
        ]),
      'Argue' => choose([
          'I argued with $n about $cause.',
          'I lost my temper with $n over $cause.',
          'I got into a heated fight with $n about $cause.',
          'I snapped at $n over $cause.',
          'I picked a fight with $n about $cause.',
          'I raised my voice at $n over $cause.',
          'I refused to back down when $n and I clashed over $cause.',
          'I exchanged harsh words with $n about $cause.',
        ]),
      'Apologize' => choose([
          'I apologized to $n for $cause.',
          'I swallowed my pride and said sorry to $n.',
          'I told $n I was sorry about $cause.',
          'I knocked on $n\'s door to make peace.',
          'I admitted to $n that I was wrong about $cause.',
          'I wrote $n an apology because I could not find the words out loud.',
          'I looked $n in the eye and said sorry for $cause.',
          'I reached out to $n to patch things up after $cause.',
        ]),
      _ => 'I interacted with $n.',
    };

    final ending = _ending(random, action, score);

    return ending.isEmpty ? opener : '$opener $ending';
  }

  /// A short closing sentence about how it went. Sometimes there is none.
  static String _ending(SeededRandom random, String action, int score) {
    if (random.nextInt(100) < 25) return '';

    String choose(List<String> options) =>
        options[random.nextInt(options.length)];

    final bad = action == 'Argue';
    final apology = action == 'Apologize';

    if (bad) {
      return choose([
        'We both went quiet afterward.',
        'The silence afterward was heavy.',
        'I walked away, still angry.',
        'Part of me knew I should have stayed calm.',
        'It stung more than I expected.',
        'I felt the distance between us grow.',
      ]);
    }

    if (apology) {
      return score <= 0
          ? choose([
              'It was not easy, and they did not forgive me right away.',
              'They listened, but the hurt was still there.',
              'It was a start, even if it was awkward.',
            ])
          : choose([
              'They smiled and said it was okay.',
              'The air between us felt lighter right away.',
              'We hugged it out, a little awkwardly.',
              'I felt a weight lift off my chest.',
            ]);
    }

    if (score >= 70) {
      return choose([
        'We have always understood each other.',
        'Moments like this remind me how close we are.',
        'I could not stop smiling afterward.',
        'It felt like the most natural thing in the world.',
        'We laughed until our cheeks hurt.',
      ]);
    }

    if (score <= 10) {
      return choose([
        'It felt a little stiff, but we tried.',
        'It was awkward at first, but it got easier.',
        'I think we are slowly warming up to each other.',
        'There was some distance between us, but it shrank a little.',
      ]);
    }

    return choose([
      'It felt good.',
      'We both left in a better mood.',
      'It was a small moment, but I will remember it.',
      'Time with them is never wasted.',
      'I walked away feeling a little lighter.',
      'It made my day better.',
    ]);
  }

  static const List<String> _praise = [
    'their patience',
    'their sense of humor',
    'how hard they work',
    'their kindness',
    'their smile',
    'their style',
    'their courage',
    'how they look out for others',
  ];

  static int _group(LifeStage stage) {
    if (stage == LifeStage.toddler || stage == LifeStage.child) return 0;
    if (stage == LifeStage.teen) return 1;
    if (stage == LifeStage.senior) return 3;

    return 2;
  }

  static List<String> _topics(int group, NpcKind kind) {
    final school = kind == NpcKind.schoolmate;

    return switch (group) {
      0 => [
          'my favorite cartoon',
          'a funny dream I had',
          'what I want to be when I grow up',
          'the bug I found outside',
          'my favorite toy',
          if (school) 'who we want to play with at recess',
          'what we should eat tonight',
        ],
      1 => [
          'school drama',
          'my crush',
          'what I want to do after graduation',
          'the music we both like',
          'a new game everyone is playing',
          if (school) 'the homework nobody wanted to do',
          'the future and how scary it feels',
        ],
      2 => [
          'work and how tired I have been',
          'my plans for the next few years',
          'money and how fast it disappears',
          'a show we both watch',
          'how our families are doing',
          'things I want to change in my life',
        ],
      _ => [
          'the good old days',
          'my health and my aching knees',
          'a memory I had almost forgotten',
          'how fast the years have gone',
          'what really matters in the end',
          'the way the world has changed',
        ],
    };
  }

  static List<String> _places(int group, NpcKind kind) {
    final school = kind == NpcKind.schoolmate;

    return switch (group) {
      0 => [
          'playing in the yard',
          'building a blanket fort',
          'drawing silly pictures',
          'chasing each other around',
          if (school) 'on the playground',
          'watching cartoons',
        ],
      1 => [
          'at the mall',
          'listening to music in my room',
          'playing games until late',
          'walking home the long way',
          if (school) 'in the school cafeteria',
          'sharing snacks on the couch',
        ],
      2 => [
          'over coffee',
          'on a long walk',
          'cooking dinner together',
          'watching a movie',
          'running errands',
          'sitting on the porch',
        ],
      _ => [
          'sipping tea in the garden',
          'flipping through old photos',
          'on a slow walk around the block',
          'sitting together in comfortable silence',
          'sharing a quiet meal',
          'watching the sunset',
        ],
    };
  }

  static List<String> _tasks(int group, NpcKind kind) {
    final school = kind == NpcKind.schoolmate;

    return switch (group) {
      0 => [
          'tidy up their toys',
          'carry a heavy bag',
          'find something they lost',
          'set the table',
        ],
      1 => [
          if (school) 'with their homework' else 'with their chores',
          'fix a problem on their phone',
          'plan a surprise',
          'move some boxes',
        ],
      2 => [
          'move some furniture',
          'sort out some paperwork',
          'fix something that was broken',
          'prepare for a big event',
          'handle a stressful errand',
        ],
      _ => [
          'carry the groceries',
          'figure out a confusing gadget',
          'tidy up around the house',
          'write a few important letters',
        ],
    };
  }

  static List<String> _causes(int group, NpcKind kind) {
    final school = kind == NpcKind.schoolmate;

    return switch (group) {
      0 => [
          'a toy',
          'who got to go first',
          'something silly',
          'a broken promise',
        ],
      1 => [
          'a secret that got out',
          'borrowed things',
          'my attitude',
          if (school) 'a rumor in the hallway',
          'how much time we spend together',
        ],
      2 => [
          'money',
          'old grudges',
          'a plan that fell through',
          'something I said carelessly',
          'who is right',
        ],
      _ => [
          'something small that grew too big',
          'an old misunderstanding',
          'the way we never listen',
          'a stubborn disagreement',
        ],
    };
  }
}
