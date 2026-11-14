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

/// A label, a value and a bar, for example "GRADES 95/100".
class MeterFooter extends StatelessWidget {
  const MeterFooter({
    required this.label,
    required this.valueText,
    required this.value,
    this.barKey,
    this.zoom = 1,
    super.key,
  });

  final String label;
  final String valueText;

  /// 0..1.
  final double value;
  final Key? barKey;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: zoom * 3),
        PipBar(barKey: barKey, value: value, height: zoom * 8),
      ],
    );
  }
}

/// A card in the style of the school card: an icon tile, a title, a short
/// line under it and a round arrow. [footer] adds anything below the header.
/// Used for the university and job cards.
class ActionCard extends StatelessWidget {
  const ActionCard({
    required this.emoji,
    required this.title,
    this.subtitle,
    this.subtitleKey,
    this.onTap,
    this.enabled = true,
    this.showChevron = true,
    this.footer,
    this.zoom = 1,
    super.key,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final Key? subtitleKey;
  final VoidCallback? onTap;

  /// A disabled card is dimmed.
  final bool enabled;

  /// Shows the round arrow when the card can be opened.
  final bool showChevron;
  final Widget? footer;

  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: AccentCard(
        zoom: zoom,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: EdgeInsets.fromLTRB(s(8), s(6), s(8), s(7)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(s(5)),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(s(10)),
                        border: Border.all(color: primary, width: 1.5),
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: s(22))),
                    ),
                    SizedBox(width: s(8)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              key: subtitleKey,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onTap != null && enabled && showChevron) ...[
                      SizedBox(width: s(6)),
                      ChevronBadge(zoom: zoom),
                    ],
                  ],
                ),
                if (footer != null) ...[
                  SizedBox(height: s(7)),
                  footer!,
                ],
              ],
            ),
          ),
        ),
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

/// "◆ TITLE ———": a green diamond, the title, and a line to the edge.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text('◆', style: TextStyle(fontSize: 8, color: scheme.primary)),
        const SizedBox(width: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 1.5,
            color: scheme.primary.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }
}

/// Puts a thin faded line between the given widgets.
List<Widget> withThinLines(BuildContext context, List<Widget> lines) {
  final color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);

  return [
    for (var i = 0; i < lines.length; i++) ...[
      if (i > 0) Container(height: 1, color: color),
      lines[i],
    ],
  ];
}

/// A tinted panel for one number, used for the Net Worth of an NPC.
class WealthPanel extends StatelessWidget {
  const WealthPanel({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// One interaction: a rounded icon plate, a title with a description under
/// it, and a round chevron. Used for NPC interactions and school activities.
class InteractionRow extends StatelessWidget {
  const InteractionRow({
    required this.title,
    required this.emoji,
    required this.description,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String emoji;
  final String description;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.45 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primary, width: 1.5),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(description, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const ChevronBadge(),
            ],
          ),
        ),
      ),
    );
  }
}

class ThinLine extends StatelessWidget {
  const ThinLine({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
      );
}

/// A dialog with a green title strip and a round X, like the profile card.
class ThemedDialog extends StatelessWidget {
  const ThemedDialog({
    required this.title,
    required this.child,
    this.onClose,
    this.closable = true,
    super.key,
  });

  final String title;
  final Widget child;

  /// Called by the X. Defaults to closing the dialog.
  final VoidCallback? onClose;

  /// False for a choice that has to be made: no X, and the back button does
  /// nothing either.
  final bool closable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final dialog = Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: primary,
            padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                if (closable)
                Tooltip(
                  message: 'Close',
                  child: InkResponse(
                  onTap: onClose ?? () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16, color: primary),
                  ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );

    return closable ? dialog : PopScope(canPop: false, child: dialog);
  }
}

/// One option in a picker: tinted and checked when selected.
class OptionTile extends StatelessWidget {
  const OptionTile({
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.emoji,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// A small picture in front of the title (for example a club's emoji).
  final String? emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: selected ? 0.16 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary.withValues(alpha: selected ? 1 : 0.35),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, size: 20, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// A bar made of ten small blocks that fill up from the left. The block at
/// the edge of the value fills partly, so small changes still show.
class PipBar extends StatelessWidget {
  const PipBar({
    required this.value,
    this.color,
    this.height = 8,
    this.pips = 10,
    this.widthFactor = 1,
    this.barKey,
    super.key,
  });

  /// 0..1.
  final double value;

  /// Defaults to the theme's green.
  final Color? color;
  final double height;
  final int pips;

  /// Share of the available width the bar takes (0.5 is half).
  final double widthFactor;

  /// Key of the row of blocks, for tests.
  final Key? barKey;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? Theme.of(context).colorScheme.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, fraction, _) {
        final bar = Row(
          key: barKey,
          children: [
            for (var i = 0; i < pips; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Expanded(
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      fill.withValues(
                        alpha: (fraction * pips - i).clamp(0.0, 1.0).toDouble(),
                      ),
                      fill.withValues(alpha: 0.16),
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        );

        if (widthFactor >= 1) return bar;

        return FractionallySizedBox(
          widthFactor: widthFactor,
          alignment: Alignment.centerLeft,
          child: bar,
        );
      },
    );
  }
}
