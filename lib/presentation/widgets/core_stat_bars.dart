import 'package:flutter/material.dart';

import '../../domain/character/character_stats.dart';
import 'stat_icons.dart';

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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cell(CoreStatKind.happiness, stats.happiness, 'happiness'),
                SizedBox(width: s(8)),
                cell(CoreStatKind.health, stats.health, 'health'),
              ],
            ),
            SizedBox(height: s(6)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cell(CoreStatKind.smarts, stats.intelligence, 'intelligence'),
                SizedBox(width: s(8)),
                cell(CoreStatKind.looks, stats.looks, 'looks'),
              ],
            ),
          ],
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

    return Container(
      padding: EdgeInsets.fromLTRB(s(7), s(5), s(7), s(6)),
      decoration: BoxDecoration(
        color: kind.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(s(10)),
        border: Border.all(color: kind.color.withValues(alpha: 0.65), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatIcon(kind: kind, value: percent, size: s(24)),
              SizedBox(width: s(6)),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(s(6)),
            child: SizedBox(
              height: s(9),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: percent / 100),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOutCubic,
                builder: (context, fraction, _) {
                  return LinearProgressIndicator(
                    value: fraction,
                    minHeight: s(9),
                    color: kind.color,
                    backgroundColor: kind.color.withValues(alpha: 0.18),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
