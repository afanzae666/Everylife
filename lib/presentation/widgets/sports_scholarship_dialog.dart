import 'package:flutter/material.dart';

import '../../simulation/narrative/sports_scholarship_narratives.dart';
import 'animated_dialog.dart';
import 'themed_cards.dart';

/// The event where a university wants a graduating athlete. Returns true
/// when the player takes the offer.
Future<bool> showSportsScholarshipDialog(
  BuildContext context, {
  required int seed,
  required String club,
}) async {
  final accepted = await showAnimatedDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ThemedDialog(
      title: SportsScholarshipNarratives.title(seed),
      closable: false,
      child: SingleChildScrollView(
        key: const Key('sports-scholarship-dialog'),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: Text('🏆', style: TextStyle(fontSize: 44))),
            const SizedBox(height: 8),
            Text(
              SportsScholarshipNarratives.text(seed, club),
              style: Theme.of(dialogContext).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            OptionTile(
              key: const Key('sports-accept'),
              emoji: '✍️',
              title: 'Accept the scholarship',
              subtitle: SportsScholarshipNarratives.accept(seed),
              selected: false,
              onTap: () => Navigator.of(dialogContext).pop(true),
            ),
            OptionTile(
              key: const Key('sports-decline'),
              emoji: '🙅',
              title: 'Turn it down',
              subtitle: SportsScholarshipNarratives.decline(seed),
              selected: false,
              onTap: () => Navigator.of(dialogContext).pop(false),
            ),
          ],
        ),
      ),
    ),
  );

  return accepted ?? false;
}
