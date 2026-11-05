import 'package:flutter/material.dart';

/// A compact top row used under the character card on navigation pages:
/// a green round X button on the left and the page title centered in
/// capital letters.
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(6), vertical: s(2)),
      child: SizedBox(
        height: s(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
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
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
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
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
