import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Hand-drawn glyphs missing from icon fonts, drawn with Fluent's 1.5 px
/// stroke so they sit with the other tab icons: a Latin cross and a rosary.
class CrossIcon extends StatelessWidget {
  const CrossIcon({
    super.key,
    this.size = 24,
    required this.color,
    this.filled = false,
  });

  final double size;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _CrossPainter(color, filled),
  );
}

class _CrossPainter extends CustomPainter {
  _CrossPainter(this.color, this.filled);

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 24;
    // Latin cross: vertical beam 3.5 wide, crossbar at 1/3 height.
    final cross = Path.combine(
      PathOperation.union,
      Path()..addRRect(
        RRect.fromLTRBR(
          10.25 * u,
          2.5 * u,
          13.75 * u,
          21.5 * u,
          Radius.circular(1.2 * u),
        ),
      ),
      Path()..addRRect(
        RRect.fromLTRBR(
          5 * u,
          7 * u,
          19 * u,
          10.5 * u,
          Radius.circular(1.2 * u),
        ),
      ),
    );
    canvas.drawPath(
      cross,
      Paint()
        ..color = color
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.5 * u
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter old) =>
      old.color != color || old.filled != filled;
}

/// Rosary glyph matching the icon set's stroke weight; [filled] for the
/// selected state (solid beads), outline otherwise.
class RosaryIcon extends StatelessWidget {
  const RosaryIcon({
    super.key,
    this.size = 24,
    required this.color,
    this.filled = false,
  });

  final double size;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _RosaryPainter(color, filled),
  );
}

class _RosaryPainter extends CustomPainter {
  _RosaryPainter(this.color, this.filled);

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    // A loop of separate beads with a small cross hanging below: reads as a
    // rosary, never as the ♀ symbol a solid ring would suggest.
    final w = size.width;
    final stroke = w * 0.0625; // 1.5 px at 24, like Fluent regular
    final bead =
        Paint()
          ..color = color
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = stroke;
    final center = Offset(w / 2, w * 0.36);
    final r = w * 0.3;
    const count = 10;
    for (var i = 0; i < count; i++) {
      // Leave a gap at the bottom where the pendant hangs.
      final a =
          math.pi / 2 + (i + 1) * (2 * math.pi - 0.9) / (count + 1) + 0.45;
      canvas.drawCircle(
        center + Offset(r * math.cos(a), r * math.sin(a)),
        filled ? w * 0.06 : w * 0.045,
        bead,
      );
    }
    final line =
        Paint()
          ..color = color
          ..strokeWidth = filled ? w * 0.085 : stroke
          ..strokeCap = StrokeCap.round;
    final top = Offset(w / 2, center.dy + r + w * 0.02);
    canvas
      ..drawCircle(top, w * 0.06, bead)
      ..drawLine(top + Offset(0, w * 0.1), Offset(w / 2, w * 0.98), line)
      ..drawLine(Offset(w * 0.39, w * 0.8), Offset(w * 0.61, w * 0.8), line);
  }

  @override
  bool shouldRepaint(_RosaryPainter old) =>
      old.color != color || old.filled != filled;
}
