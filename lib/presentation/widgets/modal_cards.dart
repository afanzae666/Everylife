import 'package:flutter/material.dart';

/// Fits a whole avatar (never cropped) into a box of [width] x [height].
Widget fitAvatar(Widget avatar, {required double width, required double height}) {
  return SizedBox(
    width: width,
    height: height,
    child: FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(width: 112, height: 140, child: avatar),
    ),
  );
}

/// Modal for the result of an interaction with someone: a round emoji badge
/// leads, then what happened, centered. Tap anywhere to close.
class InteractionCard extends StatelessWidget {
  const InteractionCard({
    required this.emoji,
    required this.child,
    this.avatar,
    super.key,
  });

  final String emoji;
  final Widget child;

  /// Shown instead of the emoji when there is one (the person involved).
  final Widget? avatar;

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
                    width: avatar == null ? 64 : 70,
                    height: avatar == null ? 64 : 84,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: avatar == null
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius:
                          avatar == null ? null : BorderRadius.circular(16),
                      color: scheme.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: avatar == null
                        ? Text(emoji, style: const TextStyle(fontSize: 32))
                        : fitAvatar(avatar!, width: 58, height: 72),
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
    this.emoji = '📖',
    this.avatar,
    super.key,
  });

  final String title;
  final Widget child;

  /// The small icon in the banner; each event picks one that fits it.
  final String emoji;

  /// Shown in the banner instead of the emoji when there is one.
  final Widget? avatar;

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
                      if (avatar == null)
                        Text(emoji, style: const TextStyle(fontSize: 18))
                      else
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: fitAvatar(avatar!, width: 34, height: 42),
                        ),
                      const SizedBox(width: 10),
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
