import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors ──────────────────────────────────────────────
  static const Color black        = Color(0xFF000000);
  static const Color surface      = Color(0xFF0d0d0d);
  static const Color surfaceLight = Color(0xFF1a1a1a);
  static const Color border       = Color(0xFF2a2a2a);
  static const Color white        = Colors.white;
  static const Color white70      = Colors.white70;
  static const Color white38      = Colors.white38;
  static const Color white24      = Colors.white24;
  static const Color white12      = Colors.white12;
  static const Color white10      = Color(0x1AFFFFFF);
  static const Color accent       = Color(0xFFE8FF47);   // neon-yellow
  static const Color accentBlue   = Color(0xFF47C8FF);
  static const Color accentRed    = Color(0xFFFF4747);
  static const Color accentGreen  = Color(0xFF47FF9C);

  // ── Severity ─────────────────────────────────────────────
  static const Color severityCritical = Color(0xFFFF4747);
  static const Color severityHigh     = Color(0xFFFF8A47);
  static const Color severityMedium   = Color(0xFFFFD347);
  static const Color severityLow      = Color(0xFF47FF9C);

  // ── Traffic ──────────────────────────────────────────────
  static const Color trafficHeavy    = Color(0xFFFF4747);
  static const Color trafficModerate = Color(0xFFFFD347);
  static const Color trafficLight    = Color(0xFF47FF9C);
  static const Color trafficFree     = Color(0xFF47C8FF);

  // ── TextStyles ───────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: 72, fontWeight: FontWeight.w900, color: white, letterSpacing: 2,
  );

  static TextStyle get headingXL => GoogleFonts.spaceGrotesk(
    fontSize: 32, fontWeight: FontWeight.w900, color: white, letterSpacing: 1,
  );

  static TextStyle get headingL => GoogleFonts.spaceGrotesk(
    fontSize: 24, fontWeight: FontWeight.w800, color: white, letterSpacing: 0.5,
  );

  static TextStyle get headingM => GoogleFonts.spaceGrotesk(
    fontSize: 18, fontWeight: FontWeight.w800, color: white, letterSpacing: 0.5,
  );

  static TextStyle get headingS => GoogleFonts.spaceGrotesk(
    fontSize: 14, fontWeight: FontWeight.w700, color: white,
  );

  static TextStyle get label => GoogleFonts.spaceGrotesk(
    fontSize: 9, fontWeight: FontWeight.w700, color: white38, letterSpacing: 3,
  );

  static TextStyle get labelAccent => GoogleFonts.spaceGrotesk(
    fontSize: 9, fontWeight: FontWeight.w700, color: accent, letterSpacing: 3,
  );

  static TextStyle get body => GoogleFonts.spaceGrotesk(
    fontSize: 13, fontWeight: FontWeight.w500, color: white70, height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 11, fontWeight: FontWeight.w500, color: white38,
  );

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
    fontSize: 12, fontWeight: FontWeight.w500, color: white,
  );

  // ── ThemeData ────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: white,
      secondary: accent,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(
      ThemeData.dark().textTheme,
    ),
  );
}

// ── Spacing ────────────────────────────────────────────────
class Spacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

// ── Border Radii ───────────────────────────────────────────
class Radii {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 28;
}

// ── Durations ─────────────────────────────────────────────
class Durations {
  static const Duration fast   = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow   = Duration(milliseconds: 600);
}