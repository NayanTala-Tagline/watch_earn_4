import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../gen/fonts.gen.dart';

// ── Segment model ────────────────────────────────────────────────────────────

class SpinSegment {
  const SpinSegment({
    required this.coins,
    required this.label,
    required this.color,
  });

  final int coins;
  final String label;
  final Color color;

  bool get isLoss => label == 'TRY';
  bool get isXp => label == '+XP';
}

// ── Default 8-segment layout matching the Figma design ───────────────────────

const List<SpinSegment> defaultSegments = [
  SpinSegment(coins: 50, label: 'JKP', color: Color(0xFFFFB3C8)),   // pink
  SpinSegment(coins: 2, label: '2¢', color: Color(0xFFFFD84D)),     // gold
  SpinSegment(coins: 5, label: '5¢', color: Color(0xFFFFB3C8)),     // pink
  SpinSegment(coins: 0, label: '+XP', color: Color(0xFFDCE8FF)),    // lavender
  SpinSegment(coins: 20, label: '20¢', color: Color(0xFFFFD84D)),   // gold
  SpinSegment(coins: 0, label: 'TRY', color: Color(0xFFFFB3C8)),    // pink
  SpinSegment(coins: 10, label: '10¢', color: Color(0xFFDCE8FF)),   // lavender
  SpinSegment(coins: 1, label: '1¢', color: Color(0xFFFFD84D)),     // gold
];

// ── CustomPainter ────────────────────────────────────────────────────────────

class SpinWheelPainter extends CustomPainter {
  const SpinWheelPainter(this.segments);
  final List<SpinSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / segments.length;

    for (var i = 0; i < segments.length; i++) {
      final startAngle = i * sweepAngle - pi / 2;
      final midAngle = startAngle + sweepAngle / 2;
      final segment = segments[i];

      // Segment fill
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = segment.color
          ..style = PaintingStyle.fill,
      );

      // White separator line
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(startAngle),
          center.dy + radius * sin(startAngle),
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Text label
      _drawLabel(canvas, center, radius, midAngle, segment.label);
    }

    // Center hub: white disc → navy ring → pink dot
    canvas
      ..drawCircle(center, radius * 0.16, Paint()..color = Colors.white)
      ..drawCircle(
        center,
        radius * 0.16,
        Paint()
          ..color = const Color(0xFF1C2359)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      )
      ..drawCircle(center, radius * 0.07, Paint()..color = const Color(0xFFE0006E));
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double midAngle,
    String text,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: const Color(0xFF1C2359),
          fontFamily: FontFamily.kommonGrotesk,
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final x = center.dx + radius * 0.62 * cos(midAngle);
    final y = center.dy + radius * 0.62 * sin(midAngle);

    canvas
      ..save()
      ..translate(x, y)
      ..rotate(midAngle + pi / 2);
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SpinWheelPainter old) => old.segments != segments;
}

// ── Rotatable widget ─────────────────────────────────────────────────────────

class SpinWheelWidget extends StatelessWidget {
  const SpinWheelWidget({
    super.key,
    required this.angle,
    required this.size,
    this.segments = defaultSegments,
  });

  final double angle;
  final double size;
  final List<SpinSegment> segments;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: SpinWheelPainter(segments)),
      ),
    );
  }
}

// ── Outer gradient ring ───────────────────────────────────────────────────────

class GradientRingPainter extends CustomPainter {
  const GradientRingPainter();

  static const _colors = [
    Color(0xFFFF6B00), // orange
    Color(0xFFFFD84D), // yellow
    Color(0xFF4A90E2), // sky-blue
    Color(0xFF7B52D9), // purple
    Color(0xFFE0006E), // magenta
    Color(0xFFFF6B00), // back to orange
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = SweepGradient(colors: _colors).createShader(
          Rect.fromCircle(center: center, radius: radius),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Downward pointer triangle ─────────────────────────────────────────────────

class PointerTrianglePainter extends CustomPainter {
  const PointerTrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas
      ..drawPath(path, Paint()..color = const Color(0xFFE0006E))
      ..drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
