import '../../core/random/seeded_random.dart';
import '../../domain/love/breakup_summary.dart';

/// Why a relationship ended, from the player's point of view.
enum BreakupCause {
  /// I ended it.
  iEndedIt,

  /// My partner left and gave no reason.
  theyLeftNoReason,
}

/// Scenes and headlines for the end of a relationship. Always varied. In
/// every line `{n}` is the other person's name.
abstract final class BreakupNarratives {
  static String _pick(SeededRandom r, List<String> pool, String name) =>
      pool[r.nextInt(pool.length)].replaceAll('{n}', name);

  // ------------------------------------------------------------ Headlines

  static const List<String> _divorceTitles = [
    'Divorced',
    'The Papers Are Signed',
    'Marriage Over',
    'Till Lawyers Do Us Part',
    'Separate Ways',
  ];

  static const List<String> _engagementTitles = [
    'Engagement Off',
    'The Ring Comes Off',
    'Wedding Cancelled',
    'No Big Day After All',
  ];

  static const List<String> _breakupTitles = [
    'Heartbreak',
    'It Is Over',
    'The End of Us',
    'Single Again',
    'We Are Done',
  ];

  static String title(SeededRandom r, BreakupKind kind) {
    final pool = switch (kind) {
      BreakupKind.divorce => _divorceTitles,
      BreakupKind.engagement => _engagementTitles,
      BreakupKind.breakup => _breakupTitles,
    };

    return pool[r.nextInt(pool.length)];
  }

  // -------------------------------------------------------------- Stories

  static const List<String> _divorceIEndedIt = [
    'I called a lawyer on a Tuesday and by Friday the papers were signed. '
        '{n} did not fight it. Somewhere along the way we had stopped '
        'being a team.',
    'I put my ring on the kitchen table and told {n} I was done. The '
        'silence that followed was the most honest conversation we had had '
        'in years.',
    'There was no shouting, no thrown plates. I simply told {n} I could '
        'not do this any longer. The courthouse did the rest.',
    '{n} cried in the hallway while I signed. I cried in the car. We both '
        'knew it was the right call and hated it anyway.',
    'I filed first. {n} said I was making a mistake. Maybe so, but it is '
        'my mistake to make.',
  ];

  static const List<String> _divorceTheyLeftNoReason = [
    '{n} said there was no one else, no fight, no reason. "It is just '
        'over." The papers were already filled in.',
    'One morning {n} packed a suitcase and said the marriage had run its '
        'course. I am still waiting for the reason.',
    '"It is not you, it is not me, it is us," said {n}. A lawyer, a '
        'stamp, and the marriage was gone.',
    '{n} woke up one day and simply did not want this life any more. No '
        'villain, no twist, just a quiet ending.',
    'I never saw it coming. {n} asked for a divorce over dinner, and '
        'somehow still asked me to pass the salt.',
  ];

  static const List<String> _datingIEndedIt = [
    'I told {n} it was over. We both cried, and it hurt a lot more than I '
        'expected.',
    '{n} and I agreed to go separate ways. No villains, just two people '
        'who stopped fitting.',
    'I ended things with {n}. The silence afterwards was the loudest sound '
        'ever.',
    'I looked at {n} and realised I was staying out of habit. So I said '
        'the words. {n} nodded slowly.',
    '"I think we want different things," I told {n}. It sounded like a '
        'line from a movie, and it felt even worse in real life.',
  ];

  static const List<String> _engagementIEndedIt = [
    'I gave the ring back to {n}. Nobody shouted, nobody slammed a door. '
        'Somehow that was the hardest part.',
    'The wedding was in my head every night, and every night I felt less '
        'sure. I told {n} the truth before it got more expensive.',
    '{n} cried, then asked for the ring back. The cancelled wedding plans '
        'are going to be awkward at every family dinner.',
    'I called off the engagement. Better a sad "no" now than a sadder '
        '"I do" later.',
  ];

  static const List<String> _datingTheyLeftNoReason = [
    '{n} said the spark was gone. No drama, no third person, just a quiet '
        'goodbye.',
    '{n} told me we were better as memories. Rude, but poetic.',
  ];

  static const List<String> _engagementTheyLeftNoReason = [
    '{n} took off the ring and said they were not ready. I never asked '
        'why, and they never said.',
    '{n} cancelled the wedding without a reason. I am left with a '
        'planner\'s notes and a very confused family.',
  ];

  /// The scene for a relationship that ended.
  static String story(
    SeededRandom r,
    String name, {
    required BreakupKind kind,
    required BreakupCause cause,
  }) {
    final pool = switch (kind) {
      BreakupKind.divorce => switch (cause) {
          BreakupCause.iEndedIt => _divorceIEndedIt,
          BreakupCause.theyLeftNoReason => _divorceTheyLeftNoReason,
        },
      BreakupKind.engagement => switch (cause) {
          BreakupCause.iEndedIt => _engagementIEndedIt,
          BreakupCause.theyLeftNoReason => _engagementTheyLeftNoReason,
        },
      BreakupKind.breakup => switch (cause) {
          BreakupCause.iEndedIt => _datingIEndedIt,
          BreakupCause.theyLeftNoReason => _datingTheyLeftNoReason,
        },
    };

    return _pick(r, pool, name);
  }

  // -------------------------------------------------------------- Quips

  static const List<String> _divorceQuips = [
    'Fun fact: the hardest part of a divorce is deciding who keeps the '
        'good mug.',
    'Somewhere, a wedding photographer is sighing.',
    'The ring is now a very expensive paperweight.',
    'Both of you will tell this story differently for the rest of your '
        'lives.',
    'Your friends picked sides within an hour. Group chats are ruthless.',
  ];

  static const List<String> _breakupQuips = [
    'Your playlist just became extremely emotional.',
    'The shared photos are still on your phone. Brave of you.',
    'Ice cream sales are about to go up by one.',
    'Time heals. Eventually. Possibly with snacks.',
    'Your next three songs will all be about this. Sorry in advance.',
  ];

  /// A short, light closing line for the overlay.
  static String quip(SeededRandom r, BreakupKind kind) {
    final pool = kind == BreakupKind.divorce ? _divorceQuips : _breakupQuips;

    return pool[r.nextInt(pool.length)];
  }
}
