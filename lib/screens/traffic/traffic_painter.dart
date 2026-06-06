import 'package:flutter/material.dart';
import '../../models/traffic_data.dart';
import '../../core/theme.dart';

class TrafficMapPainter extends CustomPainter {
  final List<TrafficSegment> segments;

  TrafficMapPainter({required this.segments});

  Color _levelColor(TrafficLevel level) {
    switch (level) {
      case TrafficLevel.free:     return AppTheme.trafficFree;
      case TrafficLevel.light:    return AppTheme.trafficLight;
      case TrafficLevel.moderate: return AppTheme.trafficModerate;
      case TrafficLevel.heavy:    return AppTheme.trafficHeavy;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a stylised grid-map of city roads
    final gridPaint = Paint()
      ..color     = const Color(0xFF1a1a1a)
      ..strokeWidth = 1;

    // Vertical grid lines
    for (double x = 0; x < size.width; x += size.width / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    // Horizontal grid lines
    for (double y = 0; y < size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw segments as colored road overlays
    if (segments.isEmpty) return;

    final roadPaths = [
      // [x1%, y1%, x2%, y2%]
      [0.0, 0.33, 1.0, 0.33],
      [0.0, 0.66, 1.0, 0.66],
      [0.25, 0.0, 0.25, 1.0],
      [0.50, 0.0, 0.50, 1.0],
      [0.75, 0.0, 0.75, 1.0],
      [0.0, 0.50, 1.0, 0.50],
    ];

    for (int i = 0; i < roadPaths.length && i < segments.length; i++) {
      final seg  = segments[i];
      final path = roadPaths[i];
      final paint = Paint()
        ..color       = _levelColor(seg.level).withOpacity(0.7)
        ..strokeWidth = 6
        ..strokeCap   = StrokeCap.round;

      canvas.drawLine(
        Offset(path[0] * size.width, path[1] * size.height),
        Offset(path[2] * size.width, path[3] * size.height),
        paint,
      );
    }

    // Intersection dots
    final dotPaint = Paint()..color = const Color(0xFF0d0d0d);
    for (double x = size.width / 4; x < size.width; x += size.width / 4) {
      for (double y = size.height / 3; y < size.height; y += size.height / 3) {
        canvas.drawCircle(Offset(x, y), 5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(TrafficMapPainter old) => old.segments != segments;
}