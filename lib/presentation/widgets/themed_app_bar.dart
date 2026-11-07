import 'package:flutter/material.dart';

/// The top bar of every full page: a centered title on a soft green
/// gradient that fades from both edges to the middle. An optional green X
/// sits on the right.
class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemedAppBar({
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const [],
    this.onClose,
    this.zoom = 1,
    super.key,
  });

  final String? title;

  /// Used instead of [title], e.g. for the logo on the main page.
  final Widget? titleWidget;

  final Widget? leading;
  final List<Widget> actions;

  /// When set, a green round X is shown on the right and calls this.
  final VoidCallback? onClose;

  final double zoom;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final base = theme.scaffoldBackgroundColor;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 0.30),
              base,
              primary.withValues(alpha: 0.30),
            ],
            stops: const [0, 0.5, 1],
          ),
        ),
      ),
      leading: leading,
      title: titleWidget ??
          Text(
            title ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
      actions: [
        ...actions,
        if (onClose != null)
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 4),
            child: Center(child: CloseCircleButton(onTap: onClose!)),
          ),
      ],
    );
  }
}

/// A small green round X.
class CloseCircleButton extends StatelessWidget {
  const CloseCircleButton({required this.onTap, this.size = 28, super.key});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Close',
      child: InkResponse(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.surface, width: 1.5),
          ),
          child: Icon(
            Icons.close,
            size: size * 0.6,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

/// A rounded green-outlined square button for app bars (menu, achievements).
class BarIconButton extends StatelessWidget {
  const BarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.zoom = 1,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12 * zoom),
            child: Opacity(
              opacity: onPressed == null ? 0.4 : 1,
              child: Container(
                width: 38 * zoom,
                height: 34 * zoom,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12 * zoom),
                  border: Border.all(color: primary, width: 1.5),
                ),
                child: Icon(icon, size: 22 * zoom, color: primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
