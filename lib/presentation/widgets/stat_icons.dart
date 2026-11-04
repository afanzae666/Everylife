import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The four stats shown on the main screen.
enum CoreStatKind { happiness, health, smarts, looks }

extension CoreStatKindStyle on CoreStatKind {
  String get label => switch (this) {
        CoreStatKind.happiness => 'Happiness',
        CoreStatKind.health => 'Health',
        CoreStatKind.smarts => 'Smarts',
        CoreStatKind.looks => 'Looks',
      };

  /// The color of the icon, the label, and the bar.
  Color get color => switch (this) {
        CoreStatKind.happiness => const Color(0xFFFFC42E),
        CoreStatKind.health => const Color(0xFF2ED8A3),
        CoreStatKind.smarts => const Color(0xFF22D3EE),
        CoreStatKind.looks => const Color(0xFFF472B6),
      };
}

/// How good a stat is, in five steps. Icons change their expression with it.
enum StatMood { great, good, okay, poor, awful }

StatMood statMoodOf(int value) {
  if (value >= 80) return StatMood.great;
  if (value >= 60) return StatMood.good;
  if (value >= 40) return StatMood.okay;
  if (value >= 20) return StatMood.poor;

  return StatMood.awful;
}

/// A stat icon drawn in code. The picture changes with the value: a happy
/// face turns sad and then angry, a healthy heart cracks and breaks, a sharp
/// brain gets sleepy, and a shiny face gets dull.
class StatIcon extends StatelessWidget {
  const StatIcon({
    required this.kind,
    required this.value,
    this.size = 28,
    super.key,
  });

  final CoreStatKind kind;
  final int value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: StatIconPainter(
        kind: kind,
        mood: statMoodOf(value),
        cutout: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

class StatIconPainter extends CustomPainter {
  const StatIconPainter({
    required this.kind,
    required this.mood,
    required this.cutout,
  });

  final CoreStatKind kind;
  final StatMood mood;

  /// Color of the background behind the icon (used for cut-out details).
  final Color cutout;

  static const Color _ink = Color(0xFF3B2A00);

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide;

    canvas.save();
    canvas.scale(unit, unit);

    switch (kind) {
      case CoreStatKind.happiness:
        _paintHappiness(canvas);
      case CoreStatKind.health:
        _paintHealth(canvas);
      case CoreStatKind.smarts:
        _paintSmarts(canvas);
      case CoreStatKind.looks:
        _paintLooks(canvas);
    }

    canvas.restore();
  }

  Paint _fill(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  /// A four-point sparkle with curved sides (unit coordinates).
  void _sparkle(Canvas canvas, Offset c, double r, Paint paint) {
    final k = r * 0.22;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
      ..close();

    canvas.drawPath(path, paint);
  }

  // ------------------------------------------------------------ Happiness

  void _paintHappiness(Canvas canvas) {
    final angry = mood == StatMood.awful;
    final face = angry ? const Color(0xFFFF7043) : kindColor;
    final line = _stroke(_ink, 0.06);

    canvas.drawCircle(const Offset(0.5, 0.5), 0.46, _fill(face));

    switch (mood) {
      case StatMood.great:
        // Happy closed eyes and a big open smile.
        for (final x in [0.34, 0.66]) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(x, 0.42), width: 0.16, height: 0.14),
            math.pi,
            math.pi,
            false,
            line,
          );
        }
        final mouth = Path()
          ..moveTo(0.27, 0.56)
          ..quadraticBezierTo(0.5, 0.95, 0.73, 0.56)
          ..close();
        canvas.drawPath(mouth, _fill(_ink));
        canvas.drawArc(
          Rect.fromCenter(center: const Offset(0.5, 0.67), width: 0.2, height: 0.12),
          0,
          math.pi,
          false,
          _stroke(const Color(0xFFFF8A80), 0.05),
        );
      case StatMood.good:
        _eyes(canvas, 0.055);
        canvas.drawPath(
          Path()
            ..moveTo(0.3, 0.6)
            ..quadraticBezierTo(0.5, 0.82, 0.7, 0.6),
          line,
        );
      case StatMood.okay:
        _eyes(canvas, 0.055);
        canvas.drawLine(const Offset(0.36, 0.67), const Offset(0.64, 0.67), line);
      case StatMood.poor:
        _eyes(canvas, 0.055);
        canvas.drawPath(
          Path()
            ..moveTo(0.34, 0.72)
            ..quadraticBezierTo(0.5, 0.56, 0.66, 0.72),
          line,
        );
        // A tear.
        final tear = Path()
          ..moveTo(0.7, 0.5)
          ..quadraticBezierTo(0.78, 0.62, 0.7, 0.68)
          ..quadraticBezierTo(0.62, 0.62, 0.7, 0.5)
          ..close();
        canvas.drawPath(tear, _fill(const Color(0xFF4FC3F7)));
      case StatMood.awful:
        // Angry eyebrows, small eyes, and a hard frown.
        canvas.drawLine(const Offset(0.24, 0.27), const Offset(0.44, 0.38), line);
        canvas.drawLine(const Offset(0.76, 0.27), const Offset(0.56, 0.38), line);
        _eyes(canvas, 0.045, y: 0.46);
        canvas.drawPath(
          Path()
            ..moveTo(0.32, 0.76)
            ..quadraticBezierTo(0.5, 0.58, 0.68, 0.76),
          line,
        );
    }
  }

  Color get kindColor => kind.color;

  void _eyes(Canvas canvas, double r, {double y = 0.42}) {
    canvas.drawCircle(Offset(0.34, y), r, _fill(_ink));
    canvas.drawCircle(Offset(0.66, y), r, _fill(_ink));
  }

  // --------------------------------------------------------------- Health

  Path _heart() => Path()
    ..moveTo(0.5, 0.9)
    ..cubicTo(0.12, 0.62, 0.0, 0.36, 0.2, 0.2)
    ..cubicTo(0.35, 0.08, 0.5, 0.2, 0.5, 0.3)
    ..cubicTo(0.5, 0.2, 0.65, 0.08, 0.8, 0.2)
    ..cubicTo(1.0, 0.36, 0.88, 0.62, 0.5, 0.9)
    ..close();

  void _paintHealth(Canvas canvas) {
    final heart = _heart();

    switch (mood) {
      case StatMood.great:
      case StatMood.good:
        canvas.drawPath(heart, _fill(kindColor));
        final big = mood == StatMood.great;
        canvas.drawPath(
          Path()
            ..moveTo(0.14, 0.5)
            ..lineTo(0.36, 0.5)
            ..lineTo(0.44, big ? 0.3 : 0.38)
            ..lineTo(0.56, big ? 0.72 : 0.62)
            ..lineTo(0.64, 0.5)
            ..lineTo(0.86, 0.5),
          _stroke(cutout, 0.055),
        );
      case StatMood.okay:
        // Tired: a paler heart with a flat, weak pulse.
        canvas.drawPath(heart, _fill(kindColor.withValues(alpha: 0.75)));
        canvas.drawPath(
          Path()
            ..moveTo(0.16, 0.52)
            ..lineTo(0.4, 0.52)
            ..lineTo(0.47, 0.45)
            ..lineTo(0.53, 0.58)
            ..lineTo(0.6, 0.52)
            ..lineTo(0.84, 0.52),
          _stroke(cutout, 0.045),
        );
      case StatMood.poor:
        // Hurt: a pale heart with a crack.
        canvas.drawPath(heart, _fill(const Color(0xFFE9A15A)));
        canvas.drawPath(
          Path()
            ..moveTo(0.52, 0.24)
            ..lineTo(0.43, 0.42)
            ..lineTo(0.58, 0.54)
            ..lineTo(0.47, 0.8),
          _stroke(cutout, 0.05),
        );
      case StatMood.awful:
        // Critical: a broken heart, torn into two halves.
        const red = Color(0xFFFF5A5A);

        canvas.save();
        canvas.clipRect(const Rect.fromLTRB(-1, -1, 0.5, 2));
        canvas.translate(-0.04, 0.0);
        canvas.drawPath(heart, _fill(red));
        canvas.restore();

        canvas.save();
        canvas.clipRect(const Rect.fromLTRB(0.5, -1, 2, 2));
        canvas.translate(0.04, 0.03);
        canvas.drawPath(heart, _fill(red));
        canvas.restore();
    }
  }

  // --------------------------------------------------------------- Smarts

  void _paintSmarts(Canvas canvas) {
    final base = mood == StatMood.awful || mood == StatMood.poor
        ? kindColor.withValues(alpha: 0.7)
        : kindColor;
    final fill = _fill(base);

    // The brain is a cloud of rounded lobes (seen from the side) ...
    for (final lobe in const [
      Rect.fromLTRB(0.10, 0.22, 0.46, 0.58), // upper left
      Rect.fromLTRB(0.32, 0.12, 0.68, 0.48), // top
      Rect.fromLTRB(0.54, 0.22, 0.90, 0.58), // upper right
      Rect.fromLTRB(0.04, 0.38, 0.38, 0.72), // left
      Rect.fromLTRB(0.62, 0.38, 0.96, 0.72), // right
      Rect.fromLTRB(0.18, 0.50, 0.52, 0.84), // lower left
      Rect.fromLTRB(0.48, 0.50, 0.82, 0.84), // lower right
    ]) {
      canvas.drawOval(lobe, fill);
    }

    // ... with a little stem under it.
    canvas.drawRRect(
      RRect.fromLTRBR(0.42, 0.74, 0.58, 0.94, const Radius.circular(0.06)),
      fill,
    );

    // Wrinkles: a centre line and wiggly folds on both sides.
    final fold = _stroke(cutout, 0.04);

    canvas.drawPath(
      Path()
        ..moveTo(0.5, 0.16)
        ..cubicTo(0.42, 0.3, 0.58, 0.42, 0.5, 0.55)
        ..cubicTo(0.44, 0.64, 0.54, 0.72, 0.5, 0.82),
      fold,
    );

    for (final side in [1.0, -1.0]) {
      double x(double v) => side > 0 ? v : 1 - v;

      canvas.drawPath(
        Path()
          ..moveTo(x(0.16), 0.44)
          ..cubicTo(x(0.24), 0.36, x(0.30), 0.52, x(0.40), 0.44),
        fold,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x(0.14), 0.62)
          ..cubicTo(x(0.24), 0.54, x(0.30), 0.70, x(0.42), 0.62),
        fold,
      );
      canvas.drawPath(
        Path()
          ..moveTo(x(0.28), 0.30)
          ..cubicTo(x(0.34), 0.24, x(0.38), 0.34, x(0.44), 0.28),
        fold,
      );
    }

    switch (mood) {
      case StatMood.great:
        _sparkle(canvas, const Offset(0.12, 0.12), 0.1, _fill(const Color(0xFFFFE066)));
        _sparkle(canvas, const Offset(0.88, 0.1), 0.08, _fill(const Color(0xFFFFE066)));
      case StatMood.good:
        _sparkle(canvas, const Offset(0.88, 0.12), 0.09, _fill(const Color(0xFFFFE066)));
      case StatMood.okay:
        break;
      case StatMood.poor:
        _sleepyZ(canvas, 0.82, 0.14, 0.11);
      case StatMood.awful:
        _sleepyZ(canvas, 0.74, 0.18, 0.11);
        _sleepyZ(canvas, 0.9, 0.06, 0.07);
    }
  }

  void _sleepyZ(Canvas canvas, double x, double y, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(x - r, y - r)
        ..lineTo(x + r, y - r)
        ..lineTo(x - r, y + r)
        ..lineTo(x + r, y + r),
      _stroke(kindColor, 0.045),
    );
  }

  // ---------------------------------------------------------------- Looks

  void _paintLooks(Canvas canvas) {
    final dull = mood == StatMood.awful || mood == StatMood.poor;
    final skin = dull ? kindColor.withValues(alpha: 0.75) : kindColor;
    const hair = Color(0xFFBE185D);
    final face = Rect.fromCircle(center: const Offset(0.5, 0.58), radius: 0.34);
    final line = _stroke(const Color(0xFF5B0F36), 0.05);

    canvas.drawOval(face, _fill(skin));
    // Hair: a cap over the top of the face.
    canvas.drawPath(
      Path()
        ..addArc(face, math.pi, math.pi)
        ..quadraticBezierTo(0.5, 0.4, 0.16, 0.58)
        ..close(),
      _fill(hair),
    );

    canvas.drawCircle(const Offset(0.38, 0.6), 0.035, _fill(const Color(0xFF5B0F36)));
    canvas.drawCircle(const Offset(0.62, 0.6), 0.035, _fill(const Color(0xFF5B0F36)));

    switch (mood) {
      case StatMood.great:
        canvas.drawPath(
          Path()
            ..moveTo(0.38, 0.72)
            ..quadraticBezierTo(0.5, 0.86, 0.62, 0.72),
          line,
        );
        canvas.drawCircle(const Offset(0.31, 0.7), 0.04, _fill(const Color(0xFFFF8FB8)));
        canvas.drawCircle(const Offset(0.69, 0.7), 0.04, _fill(const Color(0xFFFF8FB8)));
        _sparkle(canvas, const Offset(0.15, 0.2), 0.12, _fill(Colors.white));
        _sparkle(canvas, const Offset(0.86, 0.3), 0.1, _fill(Colors.white));
        _sparkle(canvas, const Offset(0.84, 0.82), 0.07, _fill(Colors.white));
      case StatMood.good:
        canvas.drawPath(
          Path()
            ..moveTo(0.4, 0.73)
            ..quadraticBezierTo(0.5, 0.82, 0.6, 0.73),
          line,
        );
        _sparkle(canvas, const Offset(0.84, 0.22), 0.1, _fill(Colors.white));
      case StatMood.okay:
        canvas.drawLine(const Offset(0.42, 0.75), const Offset(0.58, 0.75), line);
      case StatMood.poor:
        canvas.drawLine(const Offset(0.42, 0.77), const Offset(0.58, 0.77), line);
        _spots(canvas);
      case StatMood.awful:
        canvas.drawPath(
          Path()
            ..moveTo(0.4, 0.8)
            ..quadraticBezierTo(0.5, 0.7, 0.6, 0.8),
          line,
        );
        _spots(canvas);
    }
  }

  void _spots(Canvas canvas) {
    final spot = _fill(const Color(0xFF9D2A63));

    canvas.drawCircle(const Offset(0.33, 0.68), 0.025, spot);
    canvas.drawCircle(const Offset(0.69, 0.66), 0.025, spot);
    canvas.drawCircle(const Offset(0.62, 0.72), 0.02, spot);
  }

  @override
  bool shouldRepaint(StatIconPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.mood != mood ||
        oldDelegate.cutout != cutout;
  }
}
