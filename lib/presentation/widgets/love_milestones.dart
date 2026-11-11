import 'package:flutter/material.dart';

import '../../core/result/result.dart';
import '../../domain/event/npc_interaction_outcome.dart';
import '../../domain/love/love_state.dart';
import 'animated_dialog.dart';
import 'themed_cards.dart';

/// What the NPC page needs for engagement, marriage and divorce. The game
/// screen fills it from the simulation engine.
class LoveMilestones {
  const LoveMilestones({
    required this.canEngage,
    required this.canMarry,
    required this.scene,
    required this.costLabel,
    required this.canAfford,
    required this.divorcePreview,
    required this.engage,
    required this.marry,
    required this.divorce,
    this.afterScene,
  });

  final bool Function(String npcId) canEngage;
  final bool Function(String npcId) canMarry;

  /// A varied scene: 'engage', 'prenup', 'wedding' or 'divorce'.
  final String Function(String kind, String npcId) scene;

  /// Money of a baseline cost in the player's currency.
  final String Function(int costBase) costLabel;

  /// Whether my cash covers a baseline cost (negative amount).
  final bool Function(int costBase) canAfford;
  final String Function(String npcId) divorcePreview;

  final Result<NpcInteractionOutcome> Function({
    required String npcId,
    required String ringId,
  }) engage;

  final Result<NpcInteractionOutcome> Function({
    required String npcId,
    required String prenupId,
    required String weddingId,
  }) marry;

  final Result<NpcInteractionOutcome> Function({required String npcId})
      divorce;

  /// Shows what follows a story right away: a decision after being caught,
  /// or the overlay of an ending.
  final Future<void> Function()? afterScene;
}

/// A pop-up with a scene and a list of options, each with its cost.
/// Returns the picked option id, or null when I back out.
Future<String?> showMilestoneChoice(
  BuildContext context, {
  required String title,
  required String emoji,
  required String scene,
  required List<LoveOption> options,
  required String Function(int costBase) costLabel,
  required bool Function(int costBase) canAfford,
  int reserveBase = 0,
  String cancelLabel = 'NOT YET',
  Widget? avatar,
}) {
  return showAnimatedDialog<String>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return ThemedDialog(
        title: title,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              key: const Key('milestone-dialog'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Text(emoji, style: const TextStyle(fontSize: 44))),
                if (avatar != null) ...[
                  const SizedBox(height: 6),
                  Center(
                    child: SizedBox(
                      width: 84,
                      height: 105,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(width: 112, height: 140, child: avatar),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  scene,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 14),
                for (final option in options) ...[
                  OutlinedButton(
                    key: Key('milestone-option-${option.id}'),
                    onPressed: canAfford(option.costBase + reserveBase)
                        ? () => Navigator.of(dialogContext).pop(option.id)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Text(
                            '${option.label} · ${costLabel(option.costBase)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            canAfford(option.costBase + reserveBase)
                                ? option.blurb
                                : 'Not enough cash.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                TextButton(
                  key: const Key('milestone-cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(cancelLabel),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// A yes or no pop-up with a scene and a short note on the consequences.
Future<bool> showMilestoneConfirm(
  BuildContext context, {
  required String title,
  required String emoji,
  required String scene,
  required String detail,
  required String confirmLabel,
  String cancelLabel = 'NOT NOW',
}) async {
  final yes = await showAnimatedDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);

      return ThemedDialog(
        title: title,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              key: const Key('milestone-confirm'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Text(emoji, style: const TextStyle(fontSize: 44))),
                const SizedBox(height: 10),
                Text(
                  scene,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: const Key('milestone-confirm-yes'),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(confirmLabel),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('milestone-confirm-no'),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(cancelLabel),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return yes == true;
}
