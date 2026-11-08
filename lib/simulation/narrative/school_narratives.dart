import '../../core/random/seeded_random.dart';
import '../../domain/career/education_state.dart';

/// Story lines for school activities, so no two study sessions, practices or
/// promotions read the same.
abstract final class SchoolNarratives {
  static String _pick(SeededRandom random, List<String> pool) =>
      pool[random.nextInt(pool.length)];

  static const List<String> _studyKids = [
    'I built a pillow fort and read my workbook inside it. Somehow the '
        'multiplication table finally made sense.',
    'My little desk lamp and I stayed up past bedtime. I now know every '
        'country on the map, and a few that do not exist.',
    'I turned my homework into a game and gave myself gold stars. My '
        'teacher noticed the stars and the grades.',
    'I practised reading out loud to my stuffed animals. They were a very '
        'supportive audience.',
    'I traced letters until my fingers hurt. My handwriting looks like a '
        'real adult wrote it now. Almost.',
    'I asked "why?" about everything today. The teacher sighed, then '
        'smiled, then gave me extra credit.',
    'I drew every vocabulary word as a tiny picture. Now I cannot forget '
        'them, no matter how hard I try.',
    'I did my homework before cartoons for once. The cartoons felt much '
        'better than usual.',
  ];

  static const List<String> _studyTeen = [
    'I stayed up late with my notes and a lot of snacks, and things finally '
        'started to click.',
    'I made a study schedule and actually stuck to it this time. Who even am '
        'I?',
    'I spent my free time in the library. The librarian now knows my name '
        'and my favourite table.',
    'I explained the lesson to an imaginary student. Teaching it made me '
        'learn it twice as fast.',
    'I put my phone in another room for two hours. Terrifying, but my brain '
        'thanked me.',
    'I made flashcards for every chapter. My desk looks like a confetti '
        'factory, but I know the material.',
    'I studied with headphones and a calm playlist. The formulas stuck like '
        'song lyrics.',
    'I redid every wrong answer from the last test until I understood '
        'exactly why I missed it.',
    'I found a tutorial video that explained the topic in ten minutes '
        'better than the whole week of class.',
    'I woke up at 5 a.m. to study in total silence. I am not doing that '
        'again, but my grades loved it.',
  ];

  static const List<String> _studyUniversity = [
    'I claimed a corner of the library and lived on coffee and highlighters. '
        'The reading list finally feels manageable.',
    'I organised my notes into a proper system. Future me is going to be '
        'very grateful.',
    'I went to office hours and asked the questions I was too shy to ask in '
        'lecture. The professor was delighted.',
    'I wrote a full practice exam for myself and then took it. Brutal, but '
        'it worked.',
    'I trained my focus with long study blocks and short breaks. My '
        'productivity has never looked so good.',
    'I spent the weekend on my research paper. The citations were painful, '
        'the result was glorious.',
    'I joined a study session that actually studied. A miracle.',
  ];

  /// What happens when the player studies harder.
  static String study(SeededRandom random, SchoolStage stage) {
    return _pick(
      random,
      switch (stage) {
        SchoolStage.elementary => _studyKids,
        SchoolStage.university => _studyUniversity,
        _ => _studyTeen,
      },
    );
  }

  static const List<String> _joinIntro = [
    'I signed up for the {club} at {school}.',
    'After a lot of nerves, I walked into the {club} room at {school} and '
        'joined.',
    'My name is now on the {club} list at {school}.',
    'A friend dragged me to the {club} meeting at {school}, and I decided '
        'to stay.',
    'I filled out the form for the {club} at {school} before I could talk '
        'myself out of it.',
  ];

  static const Map<String, List<String>> _joinExtra = {
    'sports': [
      'The coach looked me up and down and said, "Okay, let us see what you '
          'have got."',
      'The smell of fresh grass and old sneakers is oddly motivating.',
    ],
    'drama': [
      'Everyone was dramatic from the first minute, which felt exactly '
          'right.',
      'The director handed me a script and said, "Try not to trip on the '
          'stage."',
    ],
    'debate': [
      'Within five minutes I was arguing that pineapple on pizza is a '
          'human right.',
      'They told me to pick a side and defend it. I picked the winning '
          'one.',
    ],
    'art': [
      'The room smelled of paint and possibilities. I got my own easel.',
      'Someone handed me a brush and said, "Make a mess, that is how it '
          'starts."',
    ],
    'music': [
      'We tuned up, argued about the setlist, and sounded decent. Almost.',
      'The drummer counted us in, and I felt the whole room hum.',
    ],
    'science': [
      'On my first day I got goggles and a mysterious beaker. Nobody '
          'explained it.',
      'We argued about whether to build a rocket or a volcano. Both is the '
          'answer.',
    ],
  };

  static String join(
    SeededRandom random, {
    required String clubId,
    required String clubName,
    required String school,
  }) {
    final intro = _pick(random, _joinIntro)
        .replaceAll('{club}', clubName)
        .replaceAll('{school}', school);
    final extra = _pick(random, _joinExtra[clubId] ?? const ['It begins.']);

    return '$intro $extra';
  }

  static const Map<String, List<String>> _train = {
    'sports': [
      'We ran drills until the sun went down. My legs are jelly, but my '
          'passing is sharp.',
      'The coach made us do sprints. I wanted to complain, then I saw '
          'myself getting faster.',
      'Scrimmage day! I scored once, tripped twice, and everyone cheered '
          'anyway.',
      'I stayed after practice to work on my weak foot. Nobody noticed, '
          'except the coach.',
      'We practised set pieces in the rain. Muddy, miserable, wonderful.',
    ],
    'drama': [
      'We rehearsed the big scene fifteen times. By the end I could '
          'recite it in my sleep, and probably did.',
      'The director made me cry on cue. It worked, and I hate that it '
          'worked.',
      'I practised my monologue in the bathroom mirror. The mirror '
          'applauded.',
      'Improv night: I played a talking toaster and brought the house '
          'down.',
      'We built the set with glue and optimism. It stood. Mostly.',
    ],
    'debate': [
      'We ran a practice round on a topic I knew nothing about. I won '
          'anyway, which is either talent or luck.',
      'My rebuttal landed so hard the other team went silent.',
      'I spent the evening building a case with evidence and sass. The '
          'judges loved the sass.',
      'Cross-examination practice taught me to stay calm when someone '
          'yells "Objection!" at me.',
      'I memorised twelve statistics. I only used two, but they were '
          'devastating.',
    ],
    'art': [
      'I painted until the light changed. The result looks like a real '
          'painting, which surprised everyone.',
      'We did a life-drawing session. My hand cramped, my lines improved.',
      'I tried watercolour for the first time. Half the sheet ended up on '
          'my sleeve, the other half is gorgeous.',
      'I experimented with a bold colour palette and got a compliment from '
          'a stranger.',
      'I finished a sketch I had been avoiding for weeks. It was worth '
          'the wait.',
    ],
    'music': [
      'We practised the chorus until our harmonies finally locked in. '
          'Goosebumps.',
      'My fingers have blisters, but the solo is clean now.',
      'We jammed for two hours and accidentally wrote a new song.',
      'The drummer set a faster tempo. I kept up. Barely. Beautifully.',
      'I practised scales until the neighbours knocked on the wall. That '
          'is a compliment.',
    ],
    'science': [
      'We ran an experiment that produced a surprising amount of foam. '
          'The teacher called it "data".',
      'I debugged our robot for three hours. It finally moved and I '
          'screamed with joy.',
      'I wrote our lab report with proper graphs. The graphs were '
          'unreasonably beautiful.',
      'We built a tiny circuit that blinked an LED. It is the best light '
          'I have ever seen.',
      'I tested a hypothesis, was totally wrong, and learned more than if '
          'I had been right.',
    ],
  };

  static String train(SeededRandom random, String clubId) {
    return _pick(random, _train[clubId] ?? _train['sports']!);
  }

  static String promotion({
    required String clubName,
    required String title,
    required int rank,
    required String school,
  }) {
    if (rank == 1) {
      return 'My hard work in the $clubName did not go unnoticed. The '
          'members voted and I was named $title at $school. People already '
          'ask me for advice, and I am trying to look like I know the '
          'answers.';
    }

    return 'After all the practice, the sweat and the late nights, I was '
        'named $title of the $clubName at $school. My heart was racing '
        'when they said my name. Now it is my turn to lead.';
  }

  static const List<String> _leave = [
    'I told everyone I was leaving the {club}. It was awkward, but honest.',
    'I handed in my {club} gear and walked out with mixed feelings.',
    'The {club} will go on without me. I hope it goes well.',
    'I quit the {club}. Sometimes you have to make room for something '
        'else.',
  ];

  static String leave(SeededRandom random, String clubName) =>
      _pick(random, _leave).replaceAll('{club}', clubName);
}
