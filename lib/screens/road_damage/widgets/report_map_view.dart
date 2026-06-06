import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/road_damage.dart';
import '../../../core/theme.dart';
import 'severity_badge.dart';

/// A custom-painted pseudo-map view that plots damage reports as
/// interactive pins on a dark grid canvas.  No external map SDK is
/// required — all rendering is done with Flutter's Canvas API,
/// keeping the same zero-dependency approach as TrafficPainter.
class ReportMapView extends StatefulWidget {
  final List<RoadDamageReport> reports;

  const ReportMapView({super.key, required this.reports});

  @override
  State<ReportMapView> createState() => _ReportMapViewState();
}

class _ReportMapViewState extends State<ReportMapView>
    with SingleTickerProviderStateMixin {
  RoadDamageReport? _selected;
  late AnimationController _pulseController;
  late Animation<double>   _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200), vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Normalise lat/lng to canvas coordinates ────────────────
  Offset _project(RoadDamageReport r, Size size) {
    if (widget.reports.isEmpty) return Offset(size.width / 2, size.height / 2);

    final lats = widget.reports.map((e) => e.latitude);
    final lngs = widget.reports.map((e) => e.longitude);

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    final latRange = (maxLat - minLat).abs();
    final lngRange = (maxLng - minLng).abs();

    // Add 20 % padding on each side
    const pad = 0.2;
    final x = latRange < 0.0001
        ? size.width  / 2
        : pad * size.width + (r.longitude - minLng) / lngRange * size.width  * (1 - 2 * pad);
    final y = lngRange < 0.0001
        ? size.height / 2
        : pad * size.height + (1 - (r.latitude - minLat) / latRange) * size.height * (1 - 2 * pad);

    return Offset(x, y);
  }

  Color _pinColor(DamageSeverity s) {
    switch (s) {
      case DamageSeverity.critical: return AppTheme.severityCritical;
      case DamageSeverity.high:     return AppTheme.severityHigh;
      case DamageSeverity.medium:   return AppTheme.severityMedium;
      case DamageSeverity.low:      return AppTheme.severityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reports.isEmpty) {
      return Center(
        child: Text('NO REPORTS TO DISPLAY',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white24, fontSize: 12, letterSpacing: 2,
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── Canvas ──────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color:        const Color(0xFF0d0d0d),
                  borderRadius: BorderRadius.circular(16),
                  border:       Border.all(color: Colors.white10),
                ),
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    return AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, __) => GestureDetector(
                        onTapUp: (details) => _onTap(details.localPosition, size),
                        child: CustomPaint(
                          size: size,
                          painter: _MapPainter(
                            reports:    widget.reports,
                            selected:   _selected,
                            pulse:      _pulse.value,
                            project:    (r) => _project(r, size),
                            pinColor:   _pinColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // ── Detail card ──────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
          child: _selected == null
              ? _MapLegend()
              : _DetailCard(
            report: _selected!,
            onClose: () => setState(() => _selected = null),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  void _onTap(Offset pos, Size size) {
    const hitRadius = 24.0;
    for (final r in widget.reports) {
      final pin = _project(r, size);
      if ((pin - pos).distance < hitRadius) {
        setState(() => _selected = _selected?.id == r.id ? null : r);
        return;
      }
    }
    setState(() => _selected = null);
  }
}

// ── Painter ────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  final List<RoadDamageReport>             reports;
  final RoadDamageReport?                  selected;
  final double                             pulse;
  final Offset Function(RoadDamageReport)  project;
  final Color  Function(DamageSeverity)    pinColor;

  _MapPainter({
    required this.reports,
    required this.selected,
    required this.pulse,
    required this.project,
    required this.pinColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Grid ──────────────────────────────────────────────
    final gridPaint = Paint()
      ..color       = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;

    const steps = 10;
    for (int i = 0; i <= steps; i++) {
      final x = size.width  * i / steps;
      final y = size.height * i / steps;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y),  gridPaint);
    }

    // ── Pins ──────────────────────────────────────────────
    for (final r in reports) {
      final pos    = project(r);
      final color  = pinColor(r.severity);
      final isSel  = selected?.id == r.id;
      final radius = isSel ? 9.0 : 7.0;

      // Pulse ring for critical
      if (r.severity == DamageSeverity.critical) {
        canvas.drawCircle(
          pos,
          radius + 8 * pulse,
          Paint()..color = color.withOpacity(0.15 * pulse),
        );
      }

      // Selection ring
      if (isSel) {
        canvas.drawCircle(
          pos,
          radius + 5,
          Paint()
            ..color       = color.withOpacity(0.3)
            ..style       = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // Pin body
      canvas.drawCircle(pos, radius,   Paint()..color = color.withOpacity(0.9));
      canvas.drawCircle(pos, radius - 3, Paint()..color = Colors.black.withOpacity(0.5));
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.pulse    != pulse    ||
          old.selected != selected ||
          old.reports  != reports;
}

// ── Detail card ────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final RoadDamageReport report;
  final VoidCallback     onClose;

  const _DetailCard({required this.report, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:     const EdgeInsets.fromLTRB(24, 10, 24, 0),
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SeverityBadge(severity: report.severity),
                    const SizedBox(width: 8),
                    Text(report.type.name.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white38, fontSize: 9, letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(report.location,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(report.description,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white54, fontSize: 11, height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                StatusBadge(status: report.status),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.white24, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Map legend ─────────────────────────────────────────────────

class _MapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Row(
        children: [
          Text('TAP A PIN FOR DETAILS',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white24, fontSize: 8, letterSpacing: 2,
            ),
          ),
          const Spacer(),
          ..._items.map((e) => Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: e.$2, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(e.$1,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white24, fontSize: 8,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static const _items = [
    ('LOW',      AppTheme.severityLow),
    ('MED',      AppTheme.severityMedium),
    ('HIGH',     AppTheme.severityHigh),
    ('CRITICAL', AppTheme.severityCritical),
  ];
}