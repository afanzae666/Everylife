import 'package:flutter/material.dart';

/// Modal for the result of an interaction with someone: a round emoji badge
/// leads, then what happened, centered. Tap anywhere to close.
class InteractionCard extends StatelessWidget {
  const InteractionCard({
    required this.emoji,
    required this.child,
    super.key,
  });

  final String emoji;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 22),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: scheme.primary, width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(height: 12),
                DefaultTextStyle.merge(
                  textAlign: TextAlign.center,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal for life events: a green banner with the title, then the story and
/// the choices below it.
class EventCard extends StatelessWidget {
  const EventCard({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.primary, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: scheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One answer to a life event: a full-width button with a green edge.
class EventChoiceButton extends StatelessWidget {
  const EventChoiceButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;
    final color = enabled ? theme.colorScheme.primary : theme.disabledColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
