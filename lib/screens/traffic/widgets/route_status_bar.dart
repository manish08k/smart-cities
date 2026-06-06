import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/traffic_data.dart';
import '../../../core/theme.dart';

class RouteStatusBar extends StatelessWidget {
  final TrafficSummary summary;

  const RouteStatusBar({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final total = summary.totalSegments.toDouble();
    if (total == 0) return const SizedBox();

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
          Text('CITY TRAFFIC OVERVIEW',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white38, fontSize: 9, letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 12),

          // Stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  _BarSegment(flex: summary.freeCount,     color: AppTheme.trafficFree),
                  _BarSegment(flex: summary.lightCount,    color: AppTheme.trafficLight),
                  _BarSegment(flex: summary.moderateCount, color: AppTheme.trafficModerate),
                  _BarSegment(flex: summary.heavyCount,    color: AppTheme.trafficHeavy),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legend counts
          Row(
            children: [
              _Count(label: 'FREE',     count: summary.freeCount,     color: AppTheme.trafficFree),
              const SizedBox(width: 12),
              _Count(label: 'LIGHT',    count: summary.lightCount,    color: AppTheme.trafficLight),
              const SizedBox(width: 12),
              _Count(label: 'MODERATE', count: summary.moderateCount, color: AppTheme.trafficModerate),
              const SizedBox(width: 12),
              _Count(label: 'HEAVY',    count: summary.heavyCount,    color: AppTheme.trafficHeavy),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarSegment extends StatelessWidget {
  final int flex;
  final Color color;
  const _BarSegment({required this.flex, required this.color});

  @override
  Widget build(BuildContext context) {
    if (flex == 0) return const SizedBox();
    return Expanded(
      flex: flex,
      child: Container(color: color),
    );
  }
}

class _Count extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _Count({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$count $label',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white38, fontSize: 8, letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}