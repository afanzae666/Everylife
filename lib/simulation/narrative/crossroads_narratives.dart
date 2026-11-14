/// The scenes of the choice at 18: study, work, or take a break.
/// Every pool has several lines; the seed picks one, so a life always
/// reads the same way.
abstract final class CrossroadsNarratives {
  static const List<String> _intros = [
    'The graduation cap is in the drawer, the last bell has rung, and the '
        'house is strangely quiet. For the first time nobody tells me where '
        'to be tomorrow morning. What now?',
    'I am eighteen. The diploma sits on the table, the whole map of life is '
        'unrolled, and every road looks a little scary and a little '
        'exciting. Which one do I take?',
    'School is over. My friends are already talking about plans, and '
        'everybody seems to know something I do not. Time to decide what '
        'comes next.',
    'Eighteen candles on the cake and one big question: what do I do with '
        'the rest of my life? Nobody can answer it for me.',
  ];

  static const List<String> _study = [
    'Lecture halls, late nights and a degree with my name on it.',
    'Hit the books again, this time for a career I choose myself.',
    'Pick a major, find my people, and build a future that pays off.',
  ];

  static const List<String> _work = [
    'Roll up my sleeves, start earning, and learn how the real world works.',
    'Skip the lecture hall. A first paycheck is waiting somewhere.',
    'Put on something decent and go knock on some doors.',
  ];

  static const List<String> _rest = [
    'Sleep in, clear my head and figure things out without any rush.',
    'A little breathing room first. The world will still be here later.',
    'No plans for now. Sometimes doing nothing is the plan.',
  ];

  static const List<String> _restDone = [
    'I decided to take a break. No rush, no deadlines, only me and my '
        'thoughts. I will find my way when I am ready.',
    'For now I am doing nothing at all, and it feels surprisingly good. '
        'The future can wait a little.',
    'I closed the door on all the pressure. A quiet few months, then I '
        'will see where I want to go.',
  ];

  static String intro(int seed) => _pick(_intros, seed);

  static String study(int seed) => _pick(_study, seed);

  static String work(int seed) => _pick(_work, seed);

  static String rest(int seed) => _pick(_rest, seed);

  static String restDone(int seed) => _pick(_restDone, seed);

  static String _pick(List<String> pool, int seed) =>
      pool[seed.abs() % pool.length];
}
