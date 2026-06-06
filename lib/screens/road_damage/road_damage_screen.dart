import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/road_damage_provider.dart';
import '../../models/road_damage.dart';
import '../../core/theme.dart';
import 'widgets/damage_report_card.dart';
import 'widgets/severity_badge.dart';
import 'widgets/report_map_view.dart';
import 'report_form_sheet.dart';

class RoadDamageScreen extends StatefulWidget {
  const RoadDamageScreen({super.key});

  @override
  State<RoadDamageScreen> createState() => _RoadDamageScreenState();
}

class _RoadDamageScreenState extends State<RoadDamageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _successController;
  late Animation<double>   _successScale;
  bool _mapView = false;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600), vsync: this,
    );
    _successScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoadDamageProvider>().init();
    });
  }

  @override
  void dispose() {
    _successController.dispose();
    super.dispose();
  }

  void _openReportForm(BuildContext context) {
    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   Colors.transparent,
      builder:           (_) => const ReportFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoadDamageProvider>(
      builder: (_, provider, __) {
        // Success animation
        if (provider.submitSuccess) {
          _successController.forward(from: 0);
          HapticFeedback.heavyImpact();
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) provider.dismissSuccess();
          });
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────
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
                            Text('ROAD DAMAGE',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white, fontSize: 18,
                                fontWeight: FontWeight.w900, letterSpacing: 4,
                              ),
                            ),
                            Text('MONITORING & REPORTS',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white38, fontSize: 9, letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // View toggle
                      GestureDetector(
                        onTap: () => setState(() => _mapView = !_mapView),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border:       Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _mapView ? Icons.list : Icons.map_outlined,
                                color: Colors.white54, size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(_mapView ? 'LIST' : 'MAP',
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.white38, fontSize: 8, letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Summary stats ────────────────────────────
                if (provider.state == LoadState.loaded && provider.summary != null)
                  _SummaryBar(summary: provider.summary!),

                const SizedBox(height: 16),

                // ── Filter row ───────────────────────────────
                if (provider.state == LoadState.loaded)
                  _FilterRow(provider: provider),

                const SizedBox(height: 12),

                // ── Content ──────────────────────────────────
                Expanded(
                  child: _mapView
                      ? ReportMapView(reports: provider.filteredReports)
                      : _buildList(provider),
                ),

                // ── FAB area ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: GestureDetector(
                    onTap: () => _openReportForm(context),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color:        AppTheme.accent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '+ REPORT NEW DAMAGE',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.black, fontSize: 12,
                            fontWeight: FontWeight.w900, letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Success banner ───────────────────────────
                if (provider.submitSuccess)
                  ScaleTransition(
                    scale: _successScale,
                    child: Container(
                      width:   double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color:   Colors.white,
                      child: Center(
                        child: Text(
                          '✓  REPORT SUBMITTED SUCCESSFULLY',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.black, fontSize: 11,
                            fontWeight: FontWeight.w900, letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Error banner ─────────────────────────────
                if (provider.state == LoadState.error)
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    color:   AppTheme.accentRed.withOpacity(0.15),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.accentRed, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error ?? 'Error loading road damage data',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.accentRed, fontSize: 11,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: provider.load,
                          child: Text('RETRY',
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white, fontSize: 10,
                              fontWeight: FontWeight.w900, letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(RoadDamageProvider provider) {
    // Shimmer loading
    if (provider.state == LoadState.loading && provider.summary == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Shimmer.fromColors(
          baseColor:      const Color(0xFF1a1a1a),
          highlightColor: const Color(0xFF2a2a2a),
          child: ListView.separated(
            itemCount:     6,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => Container(
              height: 100,
              decoration: BoxDecoration(
                color:        Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      );
    }

    final reports = provider.filteredReports;

    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppTheme.accentGreen, size: 40),
            const SizedBox(height: 12),
            Text('NO DAMAGE REPORTS',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white38, fontSize: 13,
                fontWeight: FontWeight.w800, letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text('All clear or adjust filters',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white24, fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ListView.separated(
        itemCount:    reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => DamageReportCard(report: reports[i]),
      ),
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  final RoadDamageSummary summary;
  const _SummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _StatChip(label: 'TOTAL',    value: '${summary.total}',    color: Colors.white),
          const SizedBox(width: 8),
          _StatChip(label: 'CRITICAL', value: '${summary.critical}', color: AppTheme.severityCritical),
          const SizedBox(width: 8),
          _StatChip(label: 'PENDING',  value: '${summary.pending}',  color: AppTheme.severityMedium),
          const SizedBox(width: 8),
          _StatChip(label: 'RESOLVED', value: '${summary.resolved}', color: AppTheme.accentGreen),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border:       Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
              style: GoogleFonts.spaceGrotesk(
                color: color, fontSize: 16, fontWeight: FontWeight.w900,
              ),
            ),
            Text(label,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white24, fontSize: 7, letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter row ────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final RoadDamageProvider provider;
  const _FilterRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _FilterChip(
            label:    'ALL',
            selected: provider.filterSeverity == null && provider.filterStatus == null,
            onTap:    provider.clearFilters,
          ),
          const SizedBox(width: 8),
          ...DamageSeverity.values.map((s) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child:   _FilterChip(
              label:    s.name.toUpperCase(),
              selected: provider.filterSeverity == s,
              color:    _severityColor(s),
              onTap:    () => provider.setSeverityFilter(
                provider.filterSeverity == s ? null : s,
              ),
            ),
          )),
          _FilterChip(
            label:    'RESOLVED',
            selected: provider.filterStatus == DamageStatus.resolved,
            color:    AppTheme.accentGreen,
            onTap:    () => provider.setStatusFilter(
              provider.filterStatus == DamageStatus.resolved ? null : DamageStatus.resolved,
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(DamageSeverity s) {
    switch (s) {
      case DamageSeverity.critical: return AppTheme.severityCritical;
      case DamageSeverity.high:     return AppTheme.severityHigh;
      case DamageSeverity.medium:   return AppTheme.severityMedium;
      case DamageSeverity.low:      return AppTheme.severityLow;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String   label;
  final bool     selected;
  final Color?   color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:        selected ? c.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border:       Border.all(color: selected ? c.withOpacity(0.5) : Colors.white12),
        ),
        child: Text(label,
          style: GoogleFonts.spaceGrotesk(
            color:         selected ? c : Colors.white38,
            fontSize:      9,
            fontWeight:    FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}