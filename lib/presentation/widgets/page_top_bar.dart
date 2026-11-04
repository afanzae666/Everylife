import 'package:flutter/material.dart';

/// A compact back row used under the character card on navigation pages.
///
/// The back arrow hugs the title, with no wide empty space like a normal
/// AppBar has.
class PageTopBar extends StatelessWidget {
  const PageTopBar({
    required this.title,
    required this.zoom,
    this.backKey,
    super.key,
  });

  final String title;
  final double zoom;
  final Key? backKey;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(2), vertical: s(1)),
      child: Row(
        children: [
          IconButton(
            key: backKey,
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back, size: s(20)),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: BoxConstraints(
              minWidth: s(30),
              minHeight: s(30),
            ),
          ),
          SizedBox(width: s(2)),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
