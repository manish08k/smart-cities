import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeIn, _shrink, _exit;
  late Animation<double> _fadeAnim, _scaleAnim, _exitFade, _exitScale;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(duration: const Duration(milliseconds: 1600), vsync: this);
    _shrink = AnimationController(duration: const Duration(milliseconds: 1800), vsync: this);
    _exit   = AnimationController(duration: const Duration(milliseconds: 900),  vsync: this);

    _fadeAnim  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeIn, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _shrink, curve: Curves.easeInBack));
    _exitFade  = Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(parent: _exit,   curve: Curves.easeOut));
    _exitScale = Tween<double>(begin: 1, end: 0.9).animate(CurvedAnimation(parent: _exit, curve: Curves.easeIn));

    _run();
  }

  void _run() async {
    await _fadeIn.forward();
    await Future.delayed(const Duration(milliseconds: 1400));
    _shrink.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    await _exit.forward();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    _shrink.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeIn, _shrink, _exit]),
        builder: (_, __) => FadeTransition(
          opacity: _exitFade,
          child: Transform.scale(
            scale: _exitScale.value,
            child: Container(
              color: Colors.black,
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SMART',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 72, fontWeight: FontWeight.w900,
                            color: Colors.white, letterSpacing: 18, height: 1.0,
                          ),
                        ),
                        Text(
                          'CITIES',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 72, fontWeight: FontWeight.w900,
                            color: Colors.white, letterSpacing: 18, height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(height: 2, width: 100, color: Colors.white),
                        const SizedBox(height: 20),
                        Text(
                          'THE FUTURE IS NOW',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11, color: Colors.white54, letterSpacing: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}