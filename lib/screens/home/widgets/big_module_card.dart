import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BigModuleCard extends StatelessWidget {
  final IconData icon;
  final String tag;
  final String title;
  final String subtitle;
  final String stat;
  final String statLabel;
  final String buttonLabel;
  final VoidCallback onTap;
  final Color? accentColor;

  const BigModuleCard({
    super.key,
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.stat,
    required this.statLabel,
    required this.onTap,
    this.buttonLabel = 'OPEN →',
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                    color: Colors.black45, fontSize: 9,
                    letterSpacing: 3, fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: accentColor ?? Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.black, fontSize: 28,
                fontWeight: FontWeight.w900, letterSpacing: 1.5, height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.black45, fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.black, fontSize: 22,
                        fontWeight: FontWeight.w900, letterSpacing: 1,
                      ),
                    ),
                    Text(
                      statLabel,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.black38, fontSize: 9, letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: accentColor ?? Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    buttonLabel,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.w900, letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}