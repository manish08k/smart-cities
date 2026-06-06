import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/parking_provider.dart';
import '../../providers/traffic_provider.dart';
import '../../providers/road_damage_provider.dart';
import '../../providers/chat_provider.dart';
import '../../core/theme.dart';
import '../parking/parking_screen.dart';
import '../traffic/traffic_screen.dart';
import '../road_damage/road_damage_screen.dart';
import '../chatbot/chatbot_sheet.dart';
import 'widgets/hero_banner.dart';
import 'widgets/big_module_card.dart';
import 'widgets/small_module_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParkingProvider>().init();
      context.read<TrafficProvider>().init();
      context.read<RoadDamageProvider>().init();
      context.read<ChatProvider>().init();
    });
  }

  void _openParking() => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const ParkingScreen()),
      transitionDuration: const Duration(milliseconds: 400),
    ),
  );

  void _openTraffic() => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const TrafficScreen()),
      transitionDuration: const Duration(milliseconds: 400),
    ),
  );

  void _openRoadDamage() => Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, a, __) => FadeTransition(opacity: a, child: const RoadDamageScreen()),
      transitionDuration: const Duration(milliseconds: 400),
    ),
  );

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ChatProvider>(),
        child: const ChatbotSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: GestureDetector(
        onTap: _openChatbot,
        child: Container(
          width: 58, height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.black, size: 26),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── Header ────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SMART CITIES',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.w900, letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('CITY INTELLIGENCE PLATFORM',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white38, fontSize: 9, letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.menu, color: Colors.white, size: 20),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const HeroBanner(),

                const SizedBox(height: 32),

                Text('MODULES',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white38, fontSize: 10, letterSpacing: 5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Parking big card ──────────────────────────
                Consumer<ParkingProvider>(
                  builder: (_, provider, __) {
                    final avail = provider.totalAvailable;
                    final statText = provider.isLoading ? '...' : '$avail SLOTS';
                    return BigModuleCard(
                      icon:        Icons.local_parking_rounded,
                      tag:         'MODULE 01',
                      title:       'PARKING\nALLOTMENT',
                      subtitle:    'Real-time slot booking & floor management',
                      stat:        statText,
                      statLabel:   'AVAILABLE',
                      buttonLabel: 'BOOK NOW →',
                      onTap:       _openParking,
                    );
                  },
                ),

                const SizedBox(height: 14),

                // ── Traffic + Road row ────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Consumer<TrafficProvider>(
                        builder: (_, provider, __) {
                          String stat = 'LIVE';
                          Color color = Colors.white70;
                          if (provider.summary != null) {
                            final status = provider.summary!.overallStatus.toUpperCase();
                            stat  = status;
                            if (status == 'HEAVY')    color = AppTheme.accentRed;
                            if (status == 'MODERATE') color = AppTheme.severityMedium;
                            if (status == 'LIGHT')    color = AppTheme.accentGreen;
                          }
                          return SmallModuleCard(
                            icon:       Icons.traffic_rounded,
                            tag:        'MODULE 02',
                            title:      'TRAFFIC\nANALYSIS',
                            stat:       stat,
                            statColor:  color,
                            onTap:      _openTraffic,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Consumer<RoadDamageProvider>(
                        builder: (_, provider, __) {
                          final count   = provider.summary?.pending ?? 0;
                          final loading = provider.isLoading;
                          return SmallModuleCard(
                            icon:       Icons.report_problem_rounded,
                            tag:        'MODULE 03',
                            title:      'ROAD\nDAMAGE',
                            stat:       loading ? '...' : '$count ALERTS',
                            statColor:  count > 0 ? AppTheme.accentRed : AppTheme.accentGreen,
                            onTap:      _openRoadDamage,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}