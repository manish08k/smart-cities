import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/parking_provider.dart';

class BookingBottomSheet extends StatelessWidget {
  final List<String> timeSlots;

  const BookingBottomSheet({super.key, required this.timeSlots});

  @override
  Widget build(BuildContext context) {
    return Consumer<ParkingProvider>(
      builder: (_, provider, __) {
        final slot = provider.selectedSlot;
        if (slot == null) return const SizedBox.shrink();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve:    Curves.easeOut,
          decoration: const BoxDecoration(
            color:  Color(0xFF0d0d0d),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Slot label + close ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SLOT ${slot.id}',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white, fontSize: 18,
                            fontWeight: FontWeight.w900, letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'SELECT YOUR TIME SLOT',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white38, fontSize: 9, letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: provider.clearSelection,
                      child: const Icon(Icons.close, color: Colors.white38, size: 20),
                    ),
                  ],
                ),
              ),

              // ── Time chips ────────────────────────────────
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:         const EdgeInsets.symmetric(horizontal: 24),
                  itemCount:       timeSlots.length,
                  itemBuilder: (_, i) {
                    final t        = timeSlots[i];
                    final selected = t == provider.selectedTime;
                    return GestureDetector(
                      onTap: () => provider.selectTime(t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin:   const EdgeInsets.only(right: 8),
                        padding:  const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color:        selected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border:       Border.all(color: selected ? Colors.white : Colors.white24),
                        ),
                        child: Center(
                          child: Text(
                            t,
                            style: GoogleFonts.spaceGrotesk(
                              color: selected ? Colors.black : Colors.white54,
                              fontSize: 11, fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ── Confirm button ────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: GestureDetector(
                  onTap: provider.selectedTime != null
                      ? () => provider.reserve()
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width:    double.infinity,
                    height:   52,
                    decoration: BoxDecoration(
                      color:        provider.selectedTime != null
                          ? Colors.white
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: provider.isLoading
                        ? const Center(
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2,
                        ),
                      ),
                    )
                        : Center(
                      child: Text(
                        provider.selectedTime != null
                            ? 'RESERVE SLOT ${slot.id} AT ${provider.selectedTime} →'
                            : 'SELECT A TIME TO CONTINUE',
                        style: GoogleFonts.spaceGrotesk(
                          color: provider.selectedTime != null
                              ? Colors.black
                              : Colors.white24,
                          fontSize: 11, fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}