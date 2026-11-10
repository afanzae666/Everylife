import '../../core/random/seeded_random.dart';

/// Varied scenes for proposals, weddings and divorces. `{n}` is the
/// partner's name, `{they}` / `{them}` are filled by the caller.
abstract final class MarriageNarratives {
  static String _pick(SeededRandom r, List<String> pool, String name) =>
      pool[r.nextInt(pool.length)].replaceAll('{n}', name);

  // ------------------------------------------------------------ Proposal

  static const List<String> _proposalScene = [
    'I have been carrying this idea around for weeks. Tonight feels right. '
        '{n} is across the table, smiling, completely unaware that my hands '
        'are shaking.',
    'We are watching the sunset together and {n} is laughing at my terrible '
        'joke. This is the moment. If I wait any longer I will chicken out.',
    'I rehearsed this speech in the mirror twenty times. {n} just asked why '
        'I am being so weird. Showtime.',
    'The restaurant is quiet, the music is soft, and the waiter keeps '
        'winking at me. {n} has no idea. I am about to ask the big question.',
    'I planned a picnic, a playlist and a backup plan for rain. {n} is '
        'sitting next to me, happy and relaxed. It is time to ask.',
    'Everything about {n} feels like home. I do not want a "someday" any '
        'more. I want a ring, a question, and a very loud yes.',
  ];

  static String proposalScene(SeededRandom r, String name) =>
      _pick(r, _proposalScene, name);

  static const List<String> _accepted = [
    '{n} gasped, covered {their} mouth, and said "Yes!" three times. We are '
        'engaged!',
    '{n} cried, laughed, and cried again. Then said yes. I am not sure who '
        'was more emotional, me or the waiter.',
    '"Of course!" said {n}, and pulled me into a hug so tight I almost '
        'dropped the ring. We are engaged!',
    '{n} said yes before I even finished the question. I am engaged to my '
        'favorite person in the world.',
  ];

  static const List<String> _declined = [
    '{n} looked at the ring, then at me, and said, "I love you, but I am '
        'not ready." The silence was loud.',
    '{n} asked for time to think. It felt like a rejection with extra '
        'steps.',
    '"Please do not do this here," whispered {n}. It did not go the way I '
        'planned. At all.',
    '{n} said no. Gently, but still no. I put the ring back in my pocket '
        'and stared at the sky.',
  ];

  static String accepted(SeededRandom r, String name, String their) =>
      _pick(r, _accepted, name).replaceAll('{their}', their);

  static String declined(SeededRandom r, String name) =>
      _pick(r, _declined, name);

  // -------------------------------------------------------------- Prenup

  static const List<String> _prenupScene = [
    'Before the big day, there is a boring but important conversation: '
        'money. A lawyer slid a stack of papers across the table, and {n} '
        'and I looked at each other. Do we protect ourselves, or trust '
        'love?',
    'My friend whispered, "Get a prenup." My mother said, "Do not insult '
        '{n}." Now I am holding a pen and a very expensive silence.',
    'The wedding planner asked about a prenup, as casually as asking '
        'about the weather. {n} and I stared at the floor. Time to decide '
        'what we are really made of.',
    'Love is wonderful. Paperwork is forever. The lawyer waits while '
        '{n} and I decide what happens to our stuff if things go wrong.',
  ];

  static String prenupScene(SeededRandom r, String name) =>
      _pick(r, _prenupScene, name);

  // ------------------------------------------------------------- Wedding

  static const List<String> _weddingScene = [
    'The big day is here. {n} is somewhere in a dress or suit, my hands '
        'are sweating, and the cake is already leaning. How do we celebrate?',
    'Everything is ready, except me. The rings are in my pocket and my '
        'tie is crooked. {n} is waiting at the end of the aisle. What kind '
        'of wedding is this going to be?',
    'My heart is pounding and my best man lost the rings twice. Somehow '
        '{n} still wants to marry me. Let us decide how big this day '
        'should be.',
    'I have waited for this day for a long time. Flowers, music, nervous '
        'relatives. {n} squeezes my hand. What kind of wedding do we want?',
  ];

  static String weddingScene(SeededRandom r, String name) =>
      _pick(r, _weddingScene, name);

  static const List<String> _weddedCourthouse = [
    'We said "I do" in ten minutes, took photos on the courthouse steps '
        'and ate burgers after. {n} and I are married, and it was perfect.',
    'A clerk, two witnesses and one very loud pigeon. That was our '
        'wedding. {n} and I are officially married!',
  ];

  static const List<String> _weddedBackyard = [
    'The barbecue burned, the speeches ran long and my uncle danced on a '
        'table. {n} and I are married, and I would not change a thing.',
    'Fairy lights, folding chairs and a toast that made everyone cry. '
        'We are married! {n} and I danced until the neighbors complained.',
  ];

  static const List<String> _weddedGrand = [
    'Three hundred guests, a string quartet and a cake taller than the '
        'groom. {n} and I are married in the wedding of the year.',
    'Chandeliers, champagne and a first dance that went viral in the '
        'family chat. {n} and I are married, and my bank account is crying.',
  ];

  static String wedded(SeededRandom r, String id, String name) {
    final pool = switch (id) {
      'courthouse' => _weddedCourthouse,
      'backyard' => _weddedBackyard,
      _ => _weddedGrand,
    };

    return _pick(r, pool, name);
  }

  // ------------------------------------------------------------- Divorce

  static const List<String> _divorceScene = [
    'The house is quiet in the wrong way. {n} and I have said everything '
        'there is to say. I am holding the papers.',
    'We sit at the kitchen table where we once planned our whole life. '
        'Now we are planning how to end it.',
    'I have thought about this for months. The lawyer is waiting, and {n} '
        'is staring at the wedding photo on the wall.',
  ];

  static String divorceScene(SeededRandom r, String name) =>
      _pick(r, _divorceScene, name);

  static const List<String> _divorced = [
    'It is over. {n} and I signed the papers and went our separate ways.',
    'The judge stamped the papers and that was that. {n} and I are '
        'divorced.',
    'We said goodbye on the courthouse steps, the same place where it '
        'began. {n} and I are no longer married.',
  ];

  static String divorced(SeededRandom r, String name) =>
      _pick(r, _divorced, name);
}
