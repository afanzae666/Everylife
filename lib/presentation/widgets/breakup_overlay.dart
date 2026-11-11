import 'package:flutter/material.dart';

import '../../domain/love/breakup_summary.dart';
import 'life_event_dialogs.dart';

/// The overlay shown whenever a relationship ends: a divorce, a breakup or a
/// called-off engagement. It tells the scene, then lists what it cost.
Future<void> showBreakupOverlay(
  BuildContext context,
  BreakupSummary summary, {
  Widget? avatar,
}) {
  return showTapToCloseOverlay(
    context,
    dialogKey: const Key('breakup-overlay'),
    title: summary.title,
    text: summary.story,
    emoji: summary.kind == BreakupKind.divorce ? '📄' : '💔',
    avatar: avatar,
    body: BreakupBody(summary: summary),
  );
}

/// The scene, the facts and the closing line of a [BreakupSummary].
class BreakupBody extends StatelessWidget {
  const BreakupBody({super.key, required this.summary});

  final BreakupSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.45;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(summary.story, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 8),
            for (final fact in summary.facts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        fact.key,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        fact.value,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 10),
            Text(
              summary.quip,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
