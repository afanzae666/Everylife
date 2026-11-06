import 'package:flutter/material.dart';

/// The game's own paper for stories: a page torn from a life journal, held
/// by a strip of green tape, with a dotted grid, a margin line and a stamp.
/// Used for interaction results, life events and their outcomes.
class JournalCard extends StatelessWidget {
  const JournalCard({
    required this.child,
    this.title,
    this.stamp,
    super.key,
  });

  /// Heading written at the top of the page.
  final String? title;

  /// Rubber stamp in the corner (EVENT, RESULT, ...).
  final String? stamp;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final paper = dark ? const Color(0xFF2A2924) : const Color(0xFFFBF6E8);
    final ink = scheme.primary;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Material(
            color: Colors.transparent,
            child: Transform.rotate(
              angle: -0.012,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: paper,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 14,
                          offset: Offset(3, 6),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: _PaperPainter(
                        dot: ink.withValues(alpha: dark ? 0.25 : 0.20),
                        margin: const Color(0xFFD9534F)
                            .withValues(alpha: dark ? 0.55 : 0.45),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(46, 26, 16, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (title != null) ...[
                              Text(
                                title!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  decorationColor: ink,
                                  decorationThickness: 2,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (stamp != null)
                    Positioned(
                      top: 16,
                      right: 12,
                      child: Transform.rotate(
                        angle: 0.14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ink.withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            stamp!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: ink.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // The tape.
                  Transform.rotate(
                    angle: 0.04,
                    child: Container(
                      width: 84,
                      height: 22,
                      decoration: BoxDecoration(
                        color: ink.withValues(alpha: 0.6),
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: ink.withValues(alpha: 0.25),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  const _PaperPainter({required this.dot, required this.margin});

  final Color dot;
  final Color margin;

  @override
  void paint(Canvas canvas, Size size) {
    final dots = Paint()..color = dot;

    for (var y = 22.0; y < size.height; y += 18) {
      for (var x = 54.0; x < size.width - 6; x += 18) {
        canvas.drawCircle(Offset(x, y), 1, dots);
      }
    }

    final line = Paint()
      ..color = margin
      ..strokeWidth = 1.5;

    canvas.drawLine(const Offset(36, 0), Offset(36, size.height), line);
  }

  @override
  bool shouldRepaint(covariant _PaperPainter oldDelegate) =>
      oldDelegate.dot != dot || oldDelegate.margin != margin;
}

/// A choice written on a journal page: an empty box to tick and the text.
class JournalChoice extends StatelessWidget {
  const JournalChoice({
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

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: color.withValues(alpha: 0.35)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_box_outline_blank_rounded, size: 22, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Opacity(
                opacity: enabled ? 1 : 0.55,
                child: Text(text, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
