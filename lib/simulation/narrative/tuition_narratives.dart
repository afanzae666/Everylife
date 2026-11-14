/// Why a way of paying tuition was turned down.
enum TuitionRefusal {
  /// The grades and mind are not enough for a scholarship.
  scholarshipLow,

  /// The scholarship went to somebody else.
  scholarshipDenied,

  /// The parents do not have the savings.
  parentsCannot,

  /// The parents can pay but do not want to.
  parentsWontHelp,

  /// There is no living parent to ask.
  noParents,

  /// The player does not have the cash.
  noMoney,

  /// No university has made a sports offer.
  noOffer,
}

/// Scenes for choosing how to pay for university. Every pool has several
/// lines; the seed picks one, so the same moment always reads the same.
/// In a line `{m}` is the major, `{t}` the total tuition and `{p}` the parent.
abstract final class TuitionNarratives {
  static const List<String> _prompts = [
    '{m} costs {t} in total, paid once before the first lecture. Now I have '
        'to figure out who is going to cover it.',
    'The registrar slid the fee sheet across the desk: {t} for all of {m}, '
        'due up front. There is more than one way to pay it.',
    'No yearly bills, just one big number: {t}. All I have to decide is how '
        'to face it.',
    '{t} for the whole degree in {m}. My wallet went very quiet. Time to '
        'think about my options.',
  ];

  static const Map<TuitionRefusal, (String, List<String>)> _refusals = {
    TuitionRefusal.scholarshipLow: (
      'No Scholarship',
      [
        'The scholarship office read my file and politely said the numbers '
            'were not strong enough. Maybe another way.',
        'I filled in the scholarship form with great hope. The reply was one '
            'kind sentence and zero money.',
        'They only fund the top of the class, and I am not there yet. The '
            'clerk did look sorry.',
      ],
    ),
    TuitionRefusal.scholarshipDenied: (
      'Scholarship Denied',
      [
        'My file made the shortlist, but another student got the last spot. '
            'I was this close.',
        'The committee liked my application and then funded someone else. '
            'Close pays nothing.',
        'The interview went fine. The letter that followed did not.',
      ],
    ),
    TuitionRefusal.parentsCannot: (
      'Not Enough Savings',
      [
        '{p} sat me down and showed me the numbers. The savings simply are '
            'not there, and it hurt {p} more than it hurt me.',
        '{p} wanted to say yes. The bank account said no.',
        'We counted what the family could spare. It was not enough, and '
            'nobody pretended otherwise.',
      ],
    ),
    TuitionRefusal.parentsWontHelp: (
      'They Said No',
      [
        '{p} said I should earn my own way. It was calm, final, and a little '
            'disappointing.',
        '{p} asked why I could not manage alone. The conversation went '
            'downhill from there.',
        'I asked, and {p} changed the subject. That was the answer.',
        '{p} said this was a big decision, and not one they were ready to '
            'pay for. I left the kitchen quietly.',
      ],
    ),
    TuitionRefusal.noParents: (
      'Nobody to Ask',
      [
        'There is nobody who could pay for this. I have to think of another '
            'way.',
        'I have no parent who could cover it. That door is simply closed.',
      ],
    ),
    TuitionRefusal.noOffer: (
      'No Offer',
      [
        'No coach has called. The sports scholarship is not for me this '
            'year.',
        'Nobody from the university teams has noticed me yet.',
      ],
    ),
    TuitionRefusal.noMoney: (
      'Not Enough Cash',
      [
        'I counted my savings twice, then once more. It is nowhere near '
            '{t}.',
        'My wallet is a lot lighter than {t}. Paying it all myself is not '
            'possible yet.',
        'The cashier smiled politely at my balance. I will need another '
            'plan.',
      ],
    ),
  };

  /// The line that asks how to pay.
  static String prompt({
    required int seed,
    required String major,
    required String total,
  }) {
    return _prompts[seed.abs() % _prompts.length]
        .replaceAll('{m}', major)
        .replaceAll('{t}', total);
  }

  /// The scene for a refusal: a title and a text.
  static (String, String) refusal(
    TuitionRefusal reason, {
    required int seed,
    String parent = 'My parent',
    String total = 'the tuition',
  }) {
    final (title, pool) = _refusals[reason]!;
    final text = pool[seed.abs() % pool.length]
        .replaceAll('{p}', parent)
        .replaceAll('{t}', total);

    return (title, text);
  }
}
