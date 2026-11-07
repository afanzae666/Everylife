import 'package:flutter/material.dart';

/// A themed title pill used under the character card on navigation pages:
/// a green round X button on the left and the page title centered in
/// capital letters between two small diamonds.
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

    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;

    Widget diamond() => Text(
          '◆',
          style: TextStyle(fontSize: s(8), color: primary),
        );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(6), vertical: s(3)),
      child: Container(
        height: s(36),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(s(18)),
          border: Border.all(color: primary, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: s(4)),
                child: Tooltip(
                  message: 'Close',
                  child: InkResponse(
                    key: backKey,
                    onTap: () => Navigator.of(context).maybePop(),
                    radius: s(20),
                    child: Container(
                      width: s(26),
                      height: s(26),
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        size: s(16),
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s(38)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                diamond(),
                SizedBox(width: s(8)),
                Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                SizedBox(width: s(8)),
                diamond(),
              ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
