import 'package:flutter/material.dart';

import '../../domain/event/life_event.dart';
import '../../domain/event/life_progress.dart';

/// Shows an event and returns the id of the choice the player picked.
///
/// The dialog cannot be dismissed: the player must decide, because the
/// next year cannot start while a decision is pending.
Future<String?> showLifeDecisionDialog(
  BuildContext context, {
  required LifeEventDefinition event,
  required bool Function(LifeChoice choice) canAfford,
}) {
  return showDialog<String>(
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
                Text(event.description),
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
                        canAfford(choice)
                            ? choice.label
                            : '${choice.label} (not enough money)',
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

/// Shows what happened after a decision.
Future<void> showLifeResultDialog(
  BuildContext context,
  LifeChoiceResult result,
) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        key: const Key('life-result-dialog'),
        title: Text(result.eventTitle),
        content: Text(result.resultText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CONTINUE'),
          ),
        ],
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
  final startNew = await showDialog<bool>(
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
                '$name died in ${ending.year} at age ${ending.age}.',
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
