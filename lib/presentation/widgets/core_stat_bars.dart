import 'package:flutter/material.dart';

import '../../domain/character/character_stats.dart';
import 'stat_icons.dart';
import 'themed_cards.dart';

/// The four main stats as colored bars with expressive icons:
/// Happiness, Health, Smarts, and Looks.
class CoreStatBars extends StatelessWidget {
  const CoreStatBars({
    required this.stats,
    required this.zoom,
    this.onTap,
    super.key,
  });

  final CharacterStats stats;
  final double zoom;

  /// Called when the player taps the panel (used to show the other traits).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    Widget cell(CoreStatKind kind, int value, String keyName) {
      return Expanded(
        child: _StatBarCell(
          key: Key('core-stat-$keyName'),
          kind: kind,
          value: value,
          zoom: zoom,
        ),
      );
    }

    final primary = Theme.of(context).colorScheme.primary;

    Widget divider() => Container(
          width: 1,
          margin: EdgeInsets.symmetric(vertical: s(2)),
          color: primary.withValues(alpha: 0.25),
        );

    Widget row(Widget left, Widget right) => IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, divider(), right],
          ),
        );

    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 0.10),
              Theme.of(context).colorScheme.surface,
            ],
          ),
          border: Border(left: BorderSide(color: primary, width: s(6))),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s(4), vertical: s(3)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              row(
                cell(CoreStatKind.happiness, stats.happiness, 'happiness'),
                cell(CoreStatKind.health, stats.health, 'health'),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: s(6)),
                color: primary.withValues(alpha: 0.25),
              ),
              row(
                cell(CoreStatKind.smarts, stats.intelligence, 'intelligence'),
                cell(CoreStatKind.looks, stats.looks, 'looks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBarCell extends StatelessWidget {
  const _StatBarCell({
    required this.kind,
    required this.value,
    required this.zoom,
    super.key,
  });

  final CoreStatKind kind;
  final int value;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final percent = value.clamp(0, 100).toInt();

    return Padding(
      padding: EdgeInsets.fromLTRB(s(7), s(5), s(7), s(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatIcon(kind: kind, value: percent, size: s(22)),
              SizedBox(width: s(5)),
              Expanded(
                child: Text(
                  kind.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                '$percent%',
                maxLines: 1,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: kind.color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: s(4)),
          PipBar(
            value: percent / 100,
            color: kind.color,
            height: s(8),
          ),
        ],
      ),
    );
  }
}
