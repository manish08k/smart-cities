import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/cityscape_painter.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: const Color(0xFF0a0a0a),
              child: CustomPaint(painter: CityScapePainter()),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            Positioned(
              bottom: 24, left: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTELLIGENT\nURBAN SYSTEMS',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.w900, letterSpacing: 2, height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LIVE DATA • REAL-TIME SYNC',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white38, fontSize: 9, letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FF47),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '● LIVE',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.black, fontSize: 9,
                    fontWeight: FontWeight.w900, letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}