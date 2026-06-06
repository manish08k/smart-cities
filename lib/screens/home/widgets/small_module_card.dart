import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SmallModuleCard extends StatelessWidget {
  final IconData icon;
  final String tag;
  final String title;
  final String stat;
  final Color statColor;
  final VoidCallback onTap;

  const SmallModuleCard({
    super.key,
    required this.icon,
    required this.tag,
    required this.title,
    required this.stat,
    required this.onTap,
    this.statColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tag,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white24, fontSize: 8,
                    letterSpacing: 2, fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(icon, color: Colors.white, size: 18),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white, fontSize: 16,
                fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                stat,
                style: GoogleFonts.spaceGrotesk(
                  color: statColor, fontSize: 9,
                  fontWeight: FontWeight.w700, letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}