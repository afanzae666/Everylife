import 'package:flutter/material.dart';

/// A small section title with a line on both sides and a diamond next to
/// the text, e.g. "—— ◆ LIFE LOG ◆ ——".
class SectionDivider extends StatelessWidget {
  const SectionDivider({required this.title, this.zoom = 1, super.key});

  final String title;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    Widget line() => Expanded(
          child: Container(
            height: 1.5,
            color: primary.withValues(alpha: 0.45),
          ),
        );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: zoom * 8, vertical: zoom * 3),
      child: Row(
        children: [
          line(),
          SizedBox(width: zoom * 8),
          Text('◆', style: TextStyle(fontSize: zoom * 7, color: primary)),
          SizedBox(width: zoom * 5),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontSize: zoom * 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: primary,
            ),
          ),
          SizedBox(width: zoom * 5),
          Text('◆', style: TextStyle(fontSize: zoom * 7, color: primary)),
          SizedBox(width: zoom * 8),
          line(),
        ],
      ),
    );
  }
}

/// The frame of a person card: a green edge on the left and a thin line
/// below. Put an InkWell inside it.
class AccentCard extends StatelessWidget {
  const AccentCard({required this.child, this.zoom = 1, super.key});

  final Widget child;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: theme.colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: primary, width: zoom * 4),
            bottom: BorderSide(color: primary.withValues(alpha: 0.35)),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// A small green round arrow that shows a card can be opened.
class ChevronBadge extends StatelessWidget {
  const ChevronBadge({this.zoom = 1, super.key});

  final double zoom;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: zoom * 22,
      height: zoom * 22,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: primary, width: 1.2),
      ),
      child: Icon(Icons.chevron_right_rounded, size: zoom * 16, color: primary),
    );
  }
}

/// A rounded green tag, used for "Age 12" on the life log.
class AgePill extends StatelessWidget {
  const AgePill({required this.text, this.zoom = 1, super.key});

  final String text;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: zoom * 9, vertical: zoom * 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(zoom * 10),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
