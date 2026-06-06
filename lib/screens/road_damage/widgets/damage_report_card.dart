import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/road_damage.dart';
import 'severity_badge.dart';

class DamageReportCard extends StatelessWidget {
  final RoadDamageReport report;

  const DamageReportCard({super.key, required this.report});

  IconData get _typeIcon {
    switch (report.type) {
      case DamageType.pothole:    return Icons.circle_outlined;
      case DamageType.crack:      return Icons.linear_scale;
      case DamageType.subsidence: return Icons.terrain;
      case DamageType.flooding:   return Icons.water;
      case DamageType.debris:     return Icons.delete_outline;
      case DamageType.other:      return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color:        Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_typeIcon, color: Colors.white54, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.location,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white, fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(report.type.name.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white38, fontSize: 9, letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SeverityBadge(severity: report.severity),
            ],
          ),

          const SizedBox(height: 12),

          // ── Description ───────────────────────────────
          Text(report.description,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white54, fontSize: 12, height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // ── Footer ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: report.status),
              Text(
                _formatTime(report.reportedAt),
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white24, fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours   < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return iso;
    }
  }
}