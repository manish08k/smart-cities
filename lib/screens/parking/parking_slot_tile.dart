import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/parking_slot.dart';

class ParkingSlotTile extends StatelessWidget {
  final ParkingSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const ParkingSlotTile({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    IconData? icon;

    if (slot.isOccupied) {
      bg        = const Color(0xFF1a1a1a);
      border    = Colors.white10;
      textColor = Colors.white24;
      icon      = Icons.directions_car;
    } else if (slot.isReserved) {
      bg        = const Color(0xFF1a1a1a);
      border    = Colors.white30;
      textColor = Colors.white38;
      icon      = Icons.lock_outline;
    } else if (isSelected) {
      bg        = Colors.white;
      border    = Colors.white;
      textColor = Colors.black;
      icon      = null;
    } else {
      bg        = Colors.transparent;
      border    = Colors.white30;
      textColor = Colors.white;
      icon      = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: border, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: textColor, size: 14),
            if (icon == null) const SizedBox(height: 4),
            Text(
              slot.id,
              style: GoogleFonts.spaceGrotesk(
                color: textColor, fontSize: 9,
                fontWeight: FontWeight.w800, letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}