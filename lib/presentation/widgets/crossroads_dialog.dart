import 'package:flutter/material.dart';

import '../../simulation/narrative/crossroads_narratives.dart';
import 'animated_dialog.dart';
import 'themed_cards.dart';

/// What the player does after high school.
enum CrossroadsChoice { university, work, rest }

/// The overlay shown at 18. Closing it counts as taking a break.
Future<CrossroadsChoice> showCrossroadsDialog(
  BuildContext context, {
  required int seed,
  required bool canStudy,
  String? sportsClub,
}) async {
  final choice = await showAnimatedDialog<CrossroadsChoice>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ThemedDialog(
      title: 'What Now?',
      onClose: () => Navigator.of(dialogContext).pop(CrossroadsChoice.rest),
      child: SingleChildScrollView(
        key: const Key('crossroads-dialog'),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              CrossroadsNarratives.intro(seed),
              style: Theme.of(dialogContext).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            if (canStudy)
              OptionTile(
                key: const Key('crossroads-university'),
                emoji: '🎓',
                title: 'University',
                subtitle: sportsClub == null
                    ? CrossroadsNarratives.study(seed)
                    : 'A university coach noticed me in the $sportsClub. '
                        'There is a full scholarship on the table.',
                selected: false,
                onTap: () =>
                    Navigator.of(dialogContext).pop(CrossroadsChoice.university),
              ),
            OptionTile(
              key: const Key('crossroads-work'),
              emoji: '💼',
              title: 'Work',
              subtitle: CrossroadsNarratives.work(seed),
              selected: false,
              onTap: () =>
                  Navigator.of(dialogContext).pop(CrossroadsChoice.work),
            ),
            OptionTile(
              key: const Key('crossroads-rest'),
              emoji: '🛋️',
              title: 'Take a break',
              subtitle: CrossroadsNarratives.rest(seed),
              selected: false,
              onTap: () =>
                  Navigator.of(dialogContext).pop(CrossroadsChoice.rest),
            ),
          ],
        ),
      ),
    ),
  );

  return choice ?? CrossroadsChoice.rest;
}
