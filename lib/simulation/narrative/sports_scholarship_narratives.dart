/// The scene where a university recruits a graduating athlete. Every pool has
/// several lines; the seed picks one. `{club}` is the sport club.
abstract final class SportsScholarshipNarratives {
  static const List<String> _titles = [
    'A Coach Is Calling',
    'They Want You On The Team',
    'A Letter With A Crest',
    'Someone Was Watching',
  ];

  static const List<String> _texts = [
    'After the final whistle, a stranger in a university jacket waited by '
        'the gate. "I have watched you play for the {club} all season," he '
        'said. "Come play for us. Tuition, books, a place on the roster, all '
        'of it paid." My heart was pounding.',
    'The envelope had a university crest on it. Inside: a full scholarship, '
        'signed by the head coach of their {club}. Somebody had been in the '
        'stands all year, and I never even noticed.',
    'The phone rang during dinner. A university coach said my name like he '
        'had known it for years. "Your {club} games have been the talk of '
        'our office. We want you. Everything is covered."',
    'The coach shook my hand a little too long. "Kids like you do not come '
        'around often," he said. "Play for our {club} and we will pay for '
        'your whole degree." For a moment I forgot how to breathe.',
  ];

  static const List<String> _accept = [
    'Sign with them and choose what to study.',
    'Take the deal. Then pick a major.',
    'Say yes, and decide what comes after the game.',
  ];

  static const List<String> _decline = [
    'Thank them, but this is not the life I want.',
    'Turn it down politely and go my own way.',
    'Say no. I will find another road.',
  ];

  static const List<String> _declined = [
    'I thanked the coach and said no. It was a strange, quiet feeling to '
        'walk away from a full scholarship.',
    'I turned down the university\'s offer for the {club}. Maybe I will '
        'wonder about it someday.',
    'I told them I had other plans. The coach nodded, handed me his card, '
        'and said the door would not stay open forever.',
  ];

  static String title(int seed) => _pick(_titles, seed);

  static String text(int seed, String club) =>
      _pick(_texts, seed).replaceAll('{club}', club);

  static String accept(int seed) => _pick(_accept, seed);

  static String decline(int seed) => _pick(_decline, seed);

  static String declined(int seed, String club) =>
      _pick(_declined, seed).replaceAll('{club}', club);

  static String _pick(List<String> pool, int seed) =>
      pool[seed.abs() % pool.length];
}
