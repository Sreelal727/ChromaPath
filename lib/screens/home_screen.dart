import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/coin_service.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coins = await CoinService.getCoins();
    if (mounted) setState(() => _coins = coins);
  }

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
          child: Stack(
            children: [
              // Coin display top-right
              Positioned(
                top: 16,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '$_coins',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
              ),
              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
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
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LevelSelectScreen(),
                          ),
                        );
                        _loadCoins(); // refresh coins when returning
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    const colors = [
      Color(0xFFE53935),
      Color(0xFF1E88E5),
      Color(0xFF43A047),
      Color(0xFFFB8C00),
      Color(0xFF8E24AA),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < colors.length; i++)
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors[i],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colors[i].withAlpha(128),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(
                    begin: 0.8,
                    end: 1.2,
                    duration: 1200.ms,
                    delay: (100 * i).ms,
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
