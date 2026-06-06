import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/traffic_data.dart';
import '../../../core/theme.dart';

class CongestionCard extends StatelessWidget {
  final TrafficSegment segment;

  const CongestionCard({super.key, required this.segment});

  Color get _levelColor {
    switch (segment.level) {
      case TrafficLevel.free:     return AppTheme.trafficFree;
      case TrafficLevel.light:    return AppTheme.trafficLight;
      case TrafficLevel.moderate: return AppTheme.trafficModerate;
      case TrafficLevel.heavy:    return AppTheme.trafficHeavy;
    }
  }

  String get _levelLabel => segment.level.name.toUpperCase();

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
          // Road name + level badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(segment.roadName,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:        _levelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border:       Border.all(color: _levelColor.withOpacity(0.4)),
                ),
                child: Text(_levelLabel,
                  style: GoogleFonts.spaceGrotesk(
                    color: _levelColor, fontSize: 8,
                    fontWeight: FontWeight.w900, letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Speed + direction
          Row(
            children: [
              _InfoPill(label: 'SPEED', value: '${segment.speedKmh} KM/H'),
              const SizedBox(width: 8),
              _InfoPill(label: 'USUAL', value: '${segment.usualSpeedKmh} KM/H'),
              const SizedBox(width: 8),
              _InfoPill(label: 'DIR', value: segment.direction),
            ],
          ),

          const SizedBox(height: 12),

          // Congestion bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CONGESTION',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white24, fontSize: 8, letterSpacing: 2,
                    ),
                  ),
                  Text('${segment.congestionPercent}%',
                    style: GoogleFonts.spaceGrotesk(
                      color: _levelColor, fontSize: 9, fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value:            segment.congestionPercent / 100,
                  backgroundColor:  Colors.white10,
                  valueColor:       AlwaysStoppedAnimation(_levelColor),
                  minHeight:        4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Delay
          Text('Delay: ${segment.estimatedDelay}',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white38, fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label, value;
  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border:       Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(label,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white24, fontSize: 7, letterSpacing: 1,
            ),
          ),
          Text(value,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}