import '../../core/random/seeded_random.dart';
import '../../domain/character/gender.dart';

/// Story lines for dating, breakups, babies and little ones. Tasteful, with
/// a little humour.
abstract final class LoveNarratives {
  static String _pick(SeededRandom random, List<String> pool, String name) =>
      pool[random.nextInt(pool.length)].replaceAll('{n}', name);

  static const List<String> _startDating = [
    'I asked {n} out with the confidence of a man holding a tiny '
        'flashlight in a storm. {n} said yes. We are officially dating!',
    '{n} and I held hands for the first time today. My heart is doing '
        'gymnastics. We are a couple now.',
    'I finally said it: "Would you like to be my partner?" {n} smiled and '
        'said yes before I even finished.',
    'We shared fries, then a laugh, then a very awkward silence, then a '
        'yes. {n} is my partner now.',
  ];

  static const List<String> _date = [
    'We had a picnic with way too many snacks. {n} laughed at my jokes, '
        'which proves true love.',
    '{n} and I watched the sunset together. Neither of us said a word, '
        'and it was perfect.',
    'We tried a cooking date. The kitchen survived. Mostly.',
    'A long walk, a cheap ice cream, and {n}\'s hand in mine. Best day of '
        'the month.',
    'We went to the cinema and missed half the movie because we kept '
        'whispering. Worth it.',
    '{n} surprised me with a handwritten card. I am keeping it forever.',
  ];

  static const List<String> _intimate = [
    'The evening with {n} was warm, close and just ours. I fell asleep '
        'smiling.',
    '{n} and I spent the night together. Some things are better left as '
        'a quiet, happy secret.',
    'Candles, soft music and {n}. I think we both needed that.',
  ];

  static const List<String> _breakUp = [
    'I told {n} it was over. We both cried, and it hurt a lot more than I '
        'expected.',
    '{n} and I agreed to go separate ways. No villains, just two people '
        'who stopped fitting.',
    'I ended things with {n}. The silence afterwards was the loudest sound '
        'ever.',
  ];

  static String startDating(SeededRandom r, String name) =>
      _pick(r, _startDating, name);

  static String date(SeededRandom r, String name) => _pick(r, _date, name);

  static String intimate(SeededRandom r, String name) =>
      _pick(r, _intimate, name);

  static String breakUp(SeededRandom r, String name) =>
      _pick(r, _breakUp, name);

  static String pregnancy({required bool playerCarries, required String name}) {
    return playerCarries
        ? 'I took the test twice, then sat down on the bathroom floor. I am '
            'pregnant with $name\'s baby!'
        : '$name came to me holding a test with two lines and a very shaky '
            'smile. We are going to have a baby!';
  }

  static String noBaby(String name) =>
      'We cannot have a baby together, but being with $name is still the '
      'best part of my days.';

  static String birth({
    required String childName,
    required Gender gender,
    required String otherParent,
  }) {
    final word = gender == Gender.female ? 'girl' : 'boy';

    return 'It is a $word! $childName was born today. $otherParent and I '
        'cried, laughed and counted the tiny fingers three times.';
  }

  static const Map<String, List<String>> _child = {
    'Talk': [
      '{n} told me a very long story about a dragon who hates broccoli.',
      'I asked {n} about the day. The answer took twenty minutes and had '
          'plot twists.',
      '{n} whispered a secret to me. It was about a snack, naturally.',
    ],
    'Spend Time': [
      '{n} and I built a blanket fort. The living room is now a kingdom.',
      'We played together all afternoon. I lost every game, on purpose. '
          'Mostly.',
      'A walk with {n}: ten minutes of distance, an hour of puddles.',
    ],
    'Compliment': [
      'I told {n} how proud I am. The grin lasted all evening.',
      '{n} got a big "well done" from me and straightened up like a '
          'little champion.',
    ],
    'Help': [
      'I helped {n} with something tricky. We solved it together, and '
          'high-fived.',
      '{n} needed a hand, and I was glad to give one.',
    ],
    'Argue': [
      '{n} and I argued over bedtime. Nobody won, everybody was tired.',
      'I lost my patience with {n}. I felt awful right after.',
    ],
    'Apologize': [
      'I said sorry to {n}. We hugged it out.',
      '{n} accepted my apology with a very serious nod and a snack '
          'request.',
    ],
  };

  static String child(SeededRandom r, String action, String name) =>
      _pick(r, _child[action] ?? _child['Talk']!, name);

  static const List<String> femaleNames = [
    'Aria', 'Luna', 'Maya', 'Nora', 'Zoe', 'Mira', 'Lila', 'Sofia',
    'Hana', 'Ivy', 'Nadia', 'Alma',
  ];

  static const List<String> maleNames = [
    'Leo', 'Noah', 'Eli', 'Rian', 'Theo', 'Arlo', 'Kai', 'Ezra',
    'Daniel', 'Finn', 'Omar', 'Adam',
  ];
}
