import 'package:flutter/material.dart';

/// The game's standard progress bar (the one on the Education card), used by
/// every bar except the character stat bars: the Education thickness (8) and default colors,
/// square corners, and half the width of the space it is given.
class GameBar extends StatelessWidget {
  const GameBar({
    required this.value,
    this.barKey,
    super.key,
  });

  /// 0..1.
  final double value;

  /// Key of the inner indicator, for tests.
  final Key? barKey;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5,
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: LinearProgressIndicator(
          key: barKey,
          minHeight: 8,
          value: value.clamp(0.0, 1.0).toDouble(),
        ),
      ),
    );
  }
}
