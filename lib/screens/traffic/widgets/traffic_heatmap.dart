import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';

class TrafficHeatmap extends StatelessWidget {
  final List<Map<String, dynamic>> hourlyData;

  const TrafficHeatmap({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) return const SizedBox();

    final spots = hourlyData.asMap().entries.map((e) {
      final val = (e.value['congestion'] as num).toDouble();
      return FlSpot(e.key.toDouble(), val);
    }).toList();

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
          Text('CONGESTION (24H)',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white38, fontSize: 9, letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData:     FlGridData(
                  show:          true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color:       Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                borderData:   FlBorderData(show: false),
                titlesData:   FlTitlesData(
                  leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles:   true,
                      interval:     4,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) {
                        final hour = v.toInt();
                        if (hour % 4 != 0) return const SizedBox();
                        return Text('${hour}h',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white24, fontSize: 8,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots:              spots,
                    isCurved:           true,
                    color:              AppTheme.accent,
                    barWidth:           2,
                    dotData:            FlDotData(show: false),
                    belowBarData:       BarAreaData(
                      show:  true,
                      color: AppTheme.accent.withOpacity(0.08),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}