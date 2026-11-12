import '../../core/random/seeded_random.dart';

/// Lines for relationships that fade, and for people who are too hurt or too
/// distant to talk. Always varied.
abstract final class RelationshipNarratives {
  static const List<String> _refuse = [
    '{n} looked at me, sighed, and walked away without a word.',
    '{n} said, "Not now. Maybe not ever." The door closed softly, which somehow hurt more.',
    'I tried to reach out, but {n} left my message on read. Loudly.',
    '{n} crossed their arms and said they were not in the mood to talk to me.',
    '{n} shook their head. "I just do not have the energy for you right now."',
    'I knocked, and {n} pretended not to be home. The lights were on.',
    '{n} gave me a long, tired look and turned away. We are too far apart for this.',
    '"Please do not," said {n}, before I could even finish my sentence.',
  ];

  static const List<String> _refuseRepair = [
    '{n} did not want to hear my apology. Not today.',
    '{n} said sorry is cheap and kept walking. I will have to try harder.',
    '{n} listened for two seconds, then said, "Come back when you mean it."',
    '{n} was not ready to forgive me. The wound is still fresh.',
  ];

  static const List<String> _drift = [
    'Life got busy and I barely spoke to {n} this year. We are drifting apart.',
    'I realised I had not called {n} in ages. The distance is growing.',
    'It has been a long time since {n} and I really talked. Things feel colder.',
    'My phone has no new messages from {n}, and I sent none either. Oops.',
    'I forgot {n}\'s birthday-ish week entirely. The bond is wearing thin.',
  ];

  static String refuse(SeededRandom r, String name, {required bool repair}) {
    final pool = repair ? [..._refuseRepair, ..._refuse] : _refuse;

    return pool[r.nextInt(pool.length)].replaceAll('{n}', name);
  }

  /// A drifting-apart line. [salt] keeps it stable without using the dice.
  static String drift(int salt, String name) =>
      _drift[salt.abs() % _drift.length].replaceAll('{n}', name);

  static const List<String> _hookUp = [
    '{n} and I lost track of time. Things got intimate, and neither of us '
        'regretted it in the moment.',
    'One thing led to another with {n}. The evening ended very, very '
        'differently than planned.',
    'The chemistry with {n} finally won. We spent the night together.',
    'We were only supposed to talk, {n} and I. We did not talk much.',
    'A look, a smile, a quiet room. {n} and I gave in to the moment.',
  ];

  static String hookUp(SeededRandom r, String name) =>
      _hookUp[r.nextInt(_hookUp.length)].replaceAll('{n}', name);

  static const List<String> _getBack = [
    '{n} and I talked for hours, and the old spark came right back. We are together again!',
    'I asked {n} for a second chance. After a long pause, the answer was yes.',
    '{n} said we both changed, and maybe for the better. We are giving it another go.',
    'We met for coffee "just to talk" and left holding hands. {n} and I are back together.',
  ];

  static String getBack(SeededRandom r, String name) =>
      _getBack[r.nextInt(_getBack.length)].replaceAll('{n}', name);
}
