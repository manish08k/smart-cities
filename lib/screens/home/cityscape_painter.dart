import 'package:flutter/material.dart';

class CityScapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1c1c1c);

    final buildings = [
      [0.05, 0.55, 0.10, 0.45], [0.16, 0.35, 0.10, 0.65],
      [0.27, 0.50, 0.08, 0.50], [0.36, 0.25, 0.12, 0.75],
      [0.49, 0.40, 0.09, 0.60], [0.59, 0.20, 0.13, 0.80],
      [0.73, 0.38, 0.10, 0.62], [0.84, 0.52, 0.09, 0.48],
      [0.94, 0.42, 0.06, 0.58],
    ];

    for (final b in buildings) {
      final rect = Rect.fromLTWH(
        b[0] * size.width, b[1] * size.height,
        b[2] * size.width, b[3] * size.height,
      );
      canvas.drawRect(rect, paint);

      // Windows
      final winPaint = Paint()..color = Colors.white.withOpacity(0.15);
      for (double wy = rect.top + 10; wy < rect.bottom - 10; wy += 14) {
        for (double wx = rect.left + 6; wx < rect.right - 6; wx += 10) {
          // Randomly dim some windows
          final opacity = (wx + wy) % 3 == 0 ? 0.05 : 0.15;
          canvas.drawRect(
            Rect.fromLTWH(wx, wy, 4, 5),
            Paint()..color = Colors.white.withOpacity(opacity),
          );
        }
      }
    }

    // Ground line
    canvas.drawLine(
      Offset(0, size.height * 0.88),
      Offset(size.width, size.height * 0.88),
      Paint()..color = Colors.white12..strokeWidth = 1,
    );

    // Road
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12),
      Paint()..color = const Color(0xFF141414),
    );

    // Road dashes
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(
        Offset(x, size.height * 0.94),
        Offset(x + 16, size.height * 0.94),
        Paint()..color = Colors.white24..strokeWidth = 1.5,
      );
    }

    // Antenna on tallest building
    final antX = 0.59 * size.width + (0.13 * size.width / 2);
    canvas.drawLine(
      Offset(antX, size.height * 0.20),
      Offset(antX, size.height * 0.10),
      Paint()..color = Colors.white24..strokeWidth = 1,
    );
    canvas.drawCircle(
      Offset(antX, size.height * 0.10),
      2,
      Paint()..color = const Color(0xFFE8FF47),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}