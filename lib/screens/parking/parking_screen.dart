import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../providers/parking_provider.dart';
import '../../providers/parking_provider.dart' show LoadState;
import '../../core/theme.dart';
import 'floor_selector.dart';
import 'parking_slot_tile.dart';
import 'booking_bottom_sheet.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _confirmController;
  late Animation<double>   _confirmScale;

  final List<String> _timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM', '11:00 AM',
    '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM',
    '04:00 PM', '05:00 PM', '06:00 PM', '07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _confirmController = AnimationController(
      duration: const Duration(milliseconds: 600), vsync: this,
    );
    _confirmScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _confirmController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParkingProvider>(
      builder: (_, provider, __) {
        // Play animation when reservation succeeds
        if (provider.reservationSuccess) {
          _confirmController.forward(from: 0);
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
                            Text('PARKING',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white, fontSize: 18,
                                fontWeight: FontWeight.w900, letterSpacing: 4,
                              ),
                            ),
                            Text('ALLOTMENT SYSTEM',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white38, fontSize: 9, letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // WS status dot
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border:       Border.all(color: Colors.white12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                color:  AppTheme.accentGreen,
                                shape:  BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('LIVE',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white38, fontSize: 8, letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Floor selector ───────────────────────────
                if (provider.state == LoadState.loaded)
                  FloorSelector(
                    floors:        provider.floors,
                    selectedIndex: provider.selectedFloorIndex,
                    onSelect:      provider.selectFloor,
                  ),

                const SizedBox(height: 20),

                // ── Stats bar ────────────────────────────────
                if (provider.selectedFloor != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _StatChip(label: 'AVAILABLE', value: '${provider.selectedFloor!.availableCount}', color: Colors.white),
                        const SizedBox(width: 10),
                        _StatChip(label: 'OCCUPIED',  value: '${provider.selectedFloor!.occupiedCount}',  color: Colors.white38),
                        const SizedBox(width: 10),
                        _StatChip(label: 'RESERVED',  value: '${provider.selectedFloor!.reservedCount}',  color: AppTheme.accentBlue),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // ── Legend ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _Legend(color: Colors.white,    label: 'FREE'),
                      const SizedBox(width: 14),
                      _Legend(color: Colors.white24,  label: 'OCCUPIED'),
                      const SizedBox(width: 14),
                      _Legend(color: Colors.white,    label: 'SELECTED', filled: true),
                      const SizedBox(width: 14),
                      _Legend(color: Colors.white38,  label: 'RESERVED', dashed: true),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Slot grid ────────────────────────────────
                Expanded(
                  child: _buildGrid(provider),
                ),

                // ── Booking sheet ────────────────────────────
                if (provider.selectedSlot != null)
                  BookingBottomSheet(timeSlots: _timeSlots),

                // ── Success banner ───────────────────────────
                if (provider.reservationSuccess)
                  ScaleTransition(
                    scale: _confirmScale,
                    child: Container(
                      width:   double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color:   Colors.white,
                      child:   Center(
                        child: Text(
                          '✓  SLOT ${provider.lastReservationSlotId} RESERVED SUCCESSFULLY',
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
                    child:   Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.accentRed, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error ?? 'Error loading parking data',
                            style: GoogleFonts.spaceGrotesk(
                              color: AppTheme.accentRed, fontSize: 11,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: provider.loadFloors,
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

  Widget _buildGrid(ParkingProvider provider) {
    if (provider.state == LoadState.loading && provider.floors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Shimmer.fromColors(
          baseColor:     const Color(0xFF1a1a1a),
          highlightColor: const Color(0xFF2a2a2a),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemCount: 16,
            itemBuilder: (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    if (provider.selectedFloor == null) return const SizedBox();

    final floor = provider.selectedFloor!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('← ENTRY',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white24, fontSize: 9, letterSpacing: 2,
                ),
              ),
              Text('EXIT →',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white24, fontSize: 9, letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:  4,
                crossAxisSpacing: 8,
                mainAxisSpacing:  8,
                childAspectRatio: 1.3,
              ),
              itemCount: floor.slots.length,
              itemBuilder: (_, i) {
                final slot     = floor.slots[i];
                final selected = provider.selectedSlot?.id == slot.id;
                return ParkingSlotTile(
                  slot:       slot,
                  isSelected: selected,
                  onTap:      () => provider.selectSlot(slot),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Local widgets ──────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border:       Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(value,
            style: GoogleFonts.spaceGrotesk(
              color: color, fontSize: 13, fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 6),
          Text(label,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white24, fontSize: 8, letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  final bool filled;
  const _Legend({required this.color, required this.label, this.dashed = false, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width:  14, height: 10,
          decoration: BoxDecoration(
            color:        dashed  ? Colors.transparent
                : filled ? color
                :          Colors.transparent,
            borderRadius: BorderRadius.circular(2),
            border:       Border.all(color: color),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white38, fontSize: 8, letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}