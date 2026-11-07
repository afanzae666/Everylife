/// Picks an emoji that fits a life event, so every event card looks
/// different. The event id (or, failing that, the title) is searched for
/// keywords; the first matching rule wins.
String lifeEventEmoji({String? id, String? title}) {
  final text = '${id ?? ''} ${title ?? ''}'.toLowerCase().replaceAll('_', ' ');

  for (final rule in _rules) {
    for (final word in rule.$1) {
      if (text.contains(word)) return rule.$2;
    }
  }

  // Unknown events still get a varied icon instead of one shared symbol.
  if (text.trim().isEmpty) return '📖';

  var hash = 0;
  for (final unit in text.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }

  return _fallback[hash % _fallback.length];
}

const List<String> _fallback = ['📖', '✨', '🌟', '🎲', '🧩', '🍀'];

const List<(List<String>, String)> _rules = [
  (['funeral', 'grief', 'rest in peace'], '🕊️'),
  (['first steps'], '👣'),
  (['first word', 'memoir', 'life story'], '🗣️'),
  (['baby'], '🍼'),
  (['tantrum'], '😤'),
  (['imaginary'], '🧸'),
  (['bully'], '😠'),
  (['cigarette', 'smok'], '🚬'),
  (['pet '], '🐶'),
  (['playground'], '🛝'),
  (['squabble', 'arguing'], '💢'),
  (['crush', 'dating', 'prom'], '💘'),
  (['party', 'sleepover', 'celebration', 'wedding'], '🎉'),
  (['viral'], '📱'),
  (['lottery', 'windfall'], '🎰'),
  (['gym', 'fitness'], '🏋️'),
  (['loan', 'debt', 'invest', 'pension', 'scam'], '💸'),
  (['business', 'side hustle', 'lemonade'], '🍋'),
  (['car ', 'driving'], '🚗'),
  (['midlife'], '🌀'),
  (['health', 'doctor', 'condition', 'checkup'], '🩺'),
  (['fall at home', 'senior fall'], '🩹'),
  (['insomnia'], '🌙'),
  (['feeling down'], '☁️'),
  (['retire'], '🏖️'),
  (['reunion', 'old friend'], '🤝'),
  (['play'], '🎭'),
  (['science'], '🔬'),
  (['report card', 'school test', 'test'], '📝'),
  (['scholarship'], '🎓'),
  (['dropout', 'all nighter', 'professor', 'uni ', 'school', 'class'], '🏫'),
  (['internship', 'job', 'work', 'promotion', 'raise', 'layoff'], '💼'),
  (['burnout'], '🔥'),
  (['home', 'burglary', 'neighbor'], '🏠'),
  (['dinner'], '🍽️'),
  (['sibling'], '👫'),
  (['parent'], '👪'),
  (['grandkid'], '👶'),
  (['memory'], '🧠'),
];
