import '../../core/random/seeded_random.dart';

/// Lines for the very youngest: a baby who can only play and cry, and a
/// baby the player plays with. Always varied.
abstract final class InfantNarratives {
  static const List<String> _playAsBaby = [
    '{n} shook a rattle and I stared at it like it was a wizard\'s staff.',
    'I played peek-a-boo with {n}. Every time the face came back, it was the best surprise of my life.',
    '{n} stacked soft blocks and I knocked them over. We both cheered.',
    'I chewed on a toy while {n} sang a silly song. Perfect afternoon.',
    '{n} rolled a ball to me. I rolled my whole body in the wrong direction.',
    'Tickle time with {n}! I laughed so hard I got the hiccups.',
    '{n} made a funny face and I answered with a loud "ba-ba-ba".',
  ];

  static const List<String> _playAsBabyFamily = [
    '{n} held my hands and bounced me gently. Giggles everywhere.',
    '{n} blew bubbles and I tried to catch every one with my mouth.',
  ];

  static const List<String> _cryAsBaby = [
    'I cried loudly, and {n} came running to see what was wrong.',
    'I howled at {n} for no reason I could explain. It felt great anyway.',
    'My tummy was empty and I let {n} know. Loudly. Repeatedly.',
    'I cried until {n} picked me up. Then I stopped, very pleased with myself.',
    'I wailed because the world was too bright. {n} dimmed the lights and hummed to me.',
    'I cried about a sock. {n} understood completely.',
    'A big sad cry, a warm hug from {n}, and everything was fine again.',
  ];

  static const List<String> _playWithBaby = [
    'I made silly faces at {n}, who laughed like it was the best show ever.',
    '{n} grabbed my finger with a tiny, very strong hand. My heart melted.',
    'We played peek-a-boo. {n} was shocked every single time.',
    'I shook a rattle for {n}, who stared at it with total respect.',
    'I sang a made-up song to {n}, who answered with happy baby noises.',
    '{n} tried to eat my sleeve. I let it happen.',
  ];

  static String pick(
    SeededRandom random, {
    required String action,
    required String name,
    required bool playerIsBaby,
  }) {
    final pool = action == 'Cry'
        ? _cryAsBaby
        : playerIsBaby
            ? [..._playAsBaby, ..._playAsBabyFamily]
            : _playWithBaby;

    return pool[random.nextInt(pool.length)].replaceAll('{n}', name);
  }

  static const List<String> everyone = [
    'I spent time with the people closest to me. Simple, warm, and exactly what I needed.',
    'I gathered my favourite people for a day together. We talked, laughed, and ate far too many snacks.',
    'I made time for everyone who matters to me this year. It felt like a hug that lasted all day.',
    'I checked in on everyone I care about. Nobody was left out.',
    'A little time with each person I love, and my heart is full.',
    'I went around and spent time with my people. Tired, but happy.',
    'I spent the day with everyone close to me. Some stories were told twice, and nobody minded.',
    'I put my phone away and gave my people my full attention. They noticed.',
  ];

  static String togetherWithAll(SeededRandom random, int people) {
    final base = everyone[random.nextInt(everyone.length)];

    return '$base ($people ${people == 1 ? 'person' : 'people'})';
  }
}
