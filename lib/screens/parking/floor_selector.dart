import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/parking_floor.dart';

class FloorSelector extends StatelessWidget {
  final List<ParkingFloor> floors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const FloorSelector({
    super.key,
    required this.floors,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:         const EdgeInsets.symmetric(horizontal: 24),
        itemCount:       floors.length,
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          final avail    = floors[i].availableCount;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin:   const EdgeInsets.only(right: 10),
              padding:  const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color:  selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? Colors.white : Colors.white24),
              ),
              child: Row(
                children: [
                  Text(
                    floors[i].name,
                    style: GoogleFonts.spaceGrotesk(
                      color: selected ? Colors.black : Colors.white,
                      fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:        selected ? Colors.black : Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$avail',
                      style: GoogleFonts.spaceGrotesk(
                        color: selected ? Colors.white : Colors.white54,
                        fontSize: 9, fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}