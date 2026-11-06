import 'package:flutter/material.dart';

import '../../domain/event/life_event.dart';
import '../../domain/event/life_progress.dart';
import 'animated_dialog.dart';

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
        child: AlertDialog(
          key: const Key('life-decision-dialog'),
          title: Text(event.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(description ?? event.description),
                const SizedBox(height: 16),
                for (final choice in event.choices) ...[
                  FilledButton.tonal(
                    key: Key('life-choice-${choice.id}'),
                    onPressed: canAfford(choice)
                        ? () => Navigator.of(dialogContext).pop(choice.id)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        _choiceText(
                          choice,
                          affordable: canAfford(choice),
                          cost: costLabel?.call(choice),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
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
          child: Center(
            child: Dialog(
              key: dialogKey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (title != null) ...[
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                    ],
                    body ?? Text(text, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 24),
                    Text(
                      'Tap anywhere to close',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
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
        child: AlertDialog(
          key: const Key('life-ended-dialog'),
          title: const Text('Rest in Peace'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name died at age ${ending.age}.',
              ),
              const SizedBox(height: 8),
              Text('Cause: ${ending.cause}.'),
              const SizedBox(height: 8),
              Text('Net worth: $netWorthText'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('VIEW MY LIFE'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('START A NEW LIFE'),
            ),
          ],
        ),
      );
    },
  );

  return startNew == true;
}
