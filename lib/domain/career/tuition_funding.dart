/// Who pays the tuition of a university program.
enum TuitionFunding {
  sports(
    label: 'Sports scholarship',
    emoji: '🏆',
    hint: 'The coaches watched me play and want me on their team. '
        'A full ride, as long as I keep playing.',
  ),
  scholarship(
    label: 'Scholarship',
    emoji: '🏅',
    hint: 'Let my report card and my sharp mind do the talking. If the '
        'committee is impressed, the bill is gone.',
  ),
  parents(
    label: 'My parents pay',
    emoji: '👪',
    hint: 'Swallow my pride and ask the family. It depends on what they '
        'have saved, and on how well we get along.',
  ),
  self(
    label: 'Pay it myself',
    emoji: '💵',
    hint: 'Walk in with the full amount in my own pocket. Clean, proud, '
        'no strings attached.',
  ),
  loan(
    label: 'Tuition loan',
    emoji: '🏦',
    hint: 'Sign the papers and worry later. Nobody turns me away, but the '
        'debt will follow me for years.',
  );

  const TuitionFunding({
    required this.label,
    required this.emoji,
    required this.hint,
  });

  final String label;
  final String emoji;
  final String hint;
}

/// The answer to "can I pay this way?". A refusal comes with a short scene.
class TuitionAnswer {
  const TuitionAnswer.approved()
      : approved = true,
        title = null,
        text = null;

  const TuitionAnswer.refused({required String title, required String text})
      : approved = false,
        title = title,
        text = text;

  final bool approved;
  final String? title;
  final String? text;
}
