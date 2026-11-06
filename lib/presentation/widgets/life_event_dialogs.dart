import 'package:flutter/material.dart';

import '../../domain/event/life_event.dart';
import '../../domain/event/life_progress.dart';
import 'animated_dialog.dart';
import 'journal_card.dart';

/// Shows an event and returns the id of the choice the player picked.
///
/// The dialog cannot be dismissed: the player must decide, because the
/// next year cannot start while a decision is pending.
///
/// [description] is the scene text with placeholders already filled in, and
/// [costLabel] returns the price to show under a choice (or null).
Future<String?> showLifeDecisionDialog(
  BuildContext context, {
  required LifeEventDefinition event,
  required bool Function(LifeChoice choice) canAfford,
  String? description,
  String? Function(LifeChoice choice)? costLabel,
}) {
  return showAnimatedDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope<String>(
        canPop: false,
        child: JournalCard(
          key: const Key('life-decision-dialog'),
          stamp: 'EVENT',
          title: event.title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                description ?? event.description,
                style: Theme.of(dialogContext).textTheme.bodyLarge,
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < event.choices.length; i++) ...[
                JournalChoice(
                  key: Key('life-choice-${event.choices[i].id}'),
                  text: _choiceText(
                    event.choices[i],
                    affordable: canAfford(event.choices[i]),
                    cost: costLabel?.call(event.choices[i]),
                  ),
                  onPressed: canAfford(event.choices[i])
                      ? () => Navigator.of(dialogContext).pop(event.choices[i].id)
                      : null,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String _choiceText(
  LifeChoice choice, {
  required bool affordable,
  String? cost,
}) {
  final priced = cost == null ? choice.label : '${choice.label}\n$cost';

  return affordable ? priced : '$priced\n(not enough money)';
}

/// Shows what happened after a decision. Tapping anywhere closes it.
Future<void> showLifeResultDialog(
  BuildContext context,
  LifeChoiceResult result,
) {
  return showTapToCloseOverlay(
    context,
    dialogKey: const Key('life-result-dialog'),
    title: result.eventTitle,
    text: result.resultText,
  );
}

/// A small overlay that closes when the player taps anywhere on the screen.
Future<void> showTapToCloseOverlay(
  BuildContext context, {
  required String text,
  String? title,
  Key? dialogKey,
  Widget? body,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: animatedDialogTransition,
    pageBuilder: (dialogContext, _, __) {
      final theme = Theme.of(dialogContext);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(dialogContext).pop(),
        child: Material(
          color: Colors.transparent,
          child: JournalCard(
            key: dialogKey,
            stamp: title == null ? null : 'RESULT',
            title: title,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                body ?? Text(text, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 14),
                Text(
                  'Tap anywhere to close',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Shown when the life is over. Returns true when the player wants to
/// start a new life.
Future<bool> showLifeEndedDialog(
  BuildContext context, {
  required String name,
  required LifeEnding ending,
  required String netWorthText,
}) async {
  final startNew = await showAnimatedDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope<bool>(
        canPop: false,
        child: JournalCard(
          key: const Key('life-ended-dialog'),
          stamp: 'THE END',
          title: 'Rest in Peace',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('$name died at age ${ending.age}.'),
              const SizedBox(height: 6),
              Text('Cause: ${ending.cause}.'),
              const SizedBox(height: 6),
              Text('Net worth: $netWorthText'),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('VIEW MY LIFE'),
              ),
              const SizedBox(height: 6),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('START A NEW LIFE'),
              ),
            ],
          ),
        ),
      );
    },
  );

  return startNew == true;
}
