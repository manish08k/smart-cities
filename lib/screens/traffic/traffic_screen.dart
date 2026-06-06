import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/traffic_provider.dart';
import '../../providers/traffic_provider.dart' show LoadState;
import '../../models/traffic_data.dart';
import '../../core/theme.dart';
import 'traffic_painter.dart';
import 'widgets/congestion_card.dart';
import 'widgets/route_status_bar.dart';
import 'widgets/traffic_heatmap.dart';

class TrafficScreen extends StatelessWidget {
  const TrafficScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrafficProvider>(
      builder: (_, provider, __) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            border:       Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TRAFFIC ANALYSIS',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white, fontSize: 18,
                                fontWeight: FontWeight.w900, letterSpacing: 4,
                              ),
                            ),
                            Text(
                              provider.summary != null
                                  ? 'UPDATED ${provider.summary!.updatedAt}'
                                  : 'LOADING...',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white38, fontSize: 9, letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: provider.load,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            border:       Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.refresh, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Filter chips ──────────────────────────────
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _FilterChip(label: 'ALL',      level: null,                   provider: provider),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'FREE',     level: TrafficLevel.free,      provider: provider),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'LIGHT',    level: TrafficLevel.light,     provider: provider),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'MODERATE', level: TrafficLevel.moderate,  provider: provider),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'HEAVY',    level: TrafficLevel.heavy,     provider: provider),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: provider.isLoading && provider.summary == null
                      ? _buildShimmer()
                      : provider.state == LoadState.error
                      ? _buildError(provider)
                      : _buildContent(provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(TrafficProvider provider) {
    final summary = provider.summary;
    if (summary == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Map view
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF0a0a0a)),
                CustomPaint(
                  painter: TrafficMapPainter(segments: summary.segments),
                ),
                Positioned(
                  top: 12, right: 12,
                  child: Container(
                    padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:        Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('LIVE MAP',
                      style: GoogleFonts.spaceGrotesk(
                        color: AppTheme.accent, fontSize: 9,
                        fontWeight: FontWeight.w900, letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        RouteStatusBar(summary: summary),

        const SizedBox(height: 16),

        TrafficHeatmap(hourlyData: provider.hourlyData),

        const SizedBox(height: 20),

        Text('ROAD SEGMENTS',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white38, fontSize: 9, letterSpacing: 3,
          ),
        ),

        const SizedBox(height: 12),

        ...provider.filteredSegments.map((seg) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:   CongestionCard(segment: seg),
        )),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor:      const Color(0xFF1a1a1a),
      highlightColor: const Color(0xFF2a2a2a),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Container(height: 200, decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
          )),
          const SizedBox(height: 12),
          Container(height: 80, decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
          )),
          const SizedBox(height: 12),
          ...List.generate(4, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child:   Container(height: 120, decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16),
            )),
          )),
        ],
      ),
    );
  }

  Widget _buildError(TrafficProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white24, size: 48),
          const SizedBox(height: 16),
          Text('Failed to load traffic data',
            style: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap:  provider.load,
            child:  Container(
              padding:    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                border:       Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('RETRY',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w900, letterSpacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final TrafficLevel? level;
  final TrafficProvider provider;

  const _FilterChip({required this.label, required this.level, required this.provider});

  @override
  Widget build(BuildContext context) {
    final selected = provider.filterLevel == level;
    return GestureDetector(
      onTap: () => provider.setFilter(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:        selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: selected ? Colors.white : Colors.white24),
        ),
        child: Center(
          child: Text(label,
            style: GoogleFonts.spaceGrotesk(
              color: selected ? Colors.black : Colors.white54,
              fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}