// ════════════════════════════════════════════════════════════
//  presentation/widgets/shared/home_painters.dart
//  CustomPainters that are reused across banner & bg layers
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Grid texture overlay
// ─────────────────────────────────────────────

class HomeGridOverlay extends StatelessWidget {
  const HomeGridOverlay({super.key});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.035)
      ..strokeWidth = 0.5;
    const step = 42.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
//  Radial glow blob
// ─────────────────────────────────────────────

class HomeRadialGlow extends StatelessWidget {
  const HomeRadialGlow({
    super.key,
    required this.radius,
    required this.color,
  });

  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}