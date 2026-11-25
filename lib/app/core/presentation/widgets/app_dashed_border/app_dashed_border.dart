import 'package:flutter/material.dart';

/// Dashed rounded outline used by upload/drop surfaces.
class AppDashedBorder extends StatelessWidget {
  const AppDashedBorder({
    super.key,
    required this.color,
    required this.fill,
    required this.borderRadius,
    required this.child,
  });

  final Color color;
  final Color fill;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _DashedPainter(color, borderRadius),
    child: DecoratedBox(
      decoration: BoxDecoration(color: fill, borderRadius: borderRadius),
      child: child,
    ),
  );
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(this.color, this.borderRadius);

  static const _stroke = 1.5, _dash = 6.0, _gap = 4.0;
  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
