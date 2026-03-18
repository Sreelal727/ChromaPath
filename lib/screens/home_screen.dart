import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'level_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo / Title
                _buildLogo(context),
                const SizedBox(height: 16),
                Text(
                  'Connect the colors. Fill the grid.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                const Spacer(flex: 2),
                // Play button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LevelSelectScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 18,
                    ),
                  ),
                  child: const Text('PLAY'),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        // Animated colored dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final color in [
              const Color(0xFFE53935),
              const Color(0xFF1E88E5),
              const Color(0xFF43A047),
              const Color(0xFFFB8C00),
              const Color(0xFF8E24AA),
            ])
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(128),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  )
                  .scaleXY(
                    begin: 0.8,
                    end: 1.2,
                    duration: 1200.ms,
                    delay: (100 * [
                      const Color(0xFFE53935),
                      const Color(0xFF1E88E5),
                      const Color(0xFF43A047),
                      const Color(0xFFFB8C00),
                      const Color(0xFF8E24AA),
                    ].indexOf(color))
                        .ms,
                  ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'ChromaPath',
          style: GoogleFonts.poppins(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF6C63FF),
                  Color(0xFFE94560),
                ],
              ).createShader(
                const Rect.fromLTWH(0, 0, 250, 70),
              ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0),
      ],
    );
  }
}
