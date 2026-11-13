/// Who pays the tuition of a university program.
enum TuitionFunding {
  scholarship(
    label: 'Scholarship',
    emoji: '🏅',
    hint: 'Depends on my grades and my mind.',
  ),
  parents(
    label: 'My parents pay',
    emoji: '👪',
    hint: 'Depends on whether they can and want to help.',
  ),
  self(
    label: 'Pay it myself',
    emoji: '💵',
    hint: 'Everything at once, from my own cash.',
  ),
  loan(
    label: 'Tuition loan',
    emoji: '🏦',
    hint: 'Borrow it and pay it back later.',
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
