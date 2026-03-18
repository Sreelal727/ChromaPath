import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/levels.dart';
import '../services/coin_service.dart';
import '../services/progress_service.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Set<int> _completedLevels = {};
  int _highestUnlocked = 1;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await ProgressService.getCompletedLevels();
    final highest = await ProgressService.getHighestUnlocked();
    final coins = await CoinService.getCoins();
    if (mounted) {
      setState(() {
        _completedLevels = completed;
        _highestUnlocked = highest;
        _coins = coins;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group levels by grid size, preserve order
    final groupKeys = <int>[];
    final groups = <int, List<dynamic>>{};
    for (final level in allLevels) {
      final gs = level.gridSize;
      if (!groups.containsKey(gs)) {
        groupKeys.add(gs);
        groups[gs] = [];
      }
      groups[gs]!.add(level);
    }

    int animOffset = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_coins',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProgressSummary(),
          const SizedBox(height: 20),
          for (final gs in groupKeys) ...[
            Builder(builder: (_) {
              final section = _buildSection(gs, groups[gs]!, animOffset);
              animOffset += groups[gs]!.length;
              return section;
            }),
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    final completed = _completedLevels.length;
    final total = totalLevelCount;
    final progress = completed / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withAlpha(40),
            const Color(0xFFE94560).withAlpha(40),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6C63FF).withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('$completed / $total',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6C63FF))),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A2A4A),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(int gridSize, List levels, int animOffset) {
    final title = '$gridSize×$gridSize Grid';
    final diffLabel = switch (gridSize) {
      5 => 'Beginner',
      6 => 'Intermediate',
      7 => 'Advanced',
      8 => 'Expert',
      9 => 'Master',
      10 => 'Grandmaster',
      _ => '',
    };
    final diffColor = switch (gridSize) {
      5 => const Color(0xFF43A047),
      6 => const Color(0xFF1E88E5),
      7 => const Color(0xFFFB8C00),
      8 => const Color(0xFFE53935),
      9 => const Color(0xFF8E24AA),
      10 => const Color(0xFFD81B60),
      _ => Colors.white,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: diffColor.withAlpha(38),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(diffLabel,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: diffColor)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            final isCompleted = _completedLevels.contains(level.id);
            final isUnlocked = level.id <= _highestUnlocked;
            return _buildLevelTile(
                level, isCompleted, isUnlocked, index + animOffset);
          },
        ),
      ],
    );
  }

  Widget _buildLevelTile(
      dynamic level, bool isCompleted, bool isUnlocked, int animIndex) {
    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GameScreen(level: level),
                ),
              );
              _loadProgress();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF43A047).withAlpha(51)
              : isUnlocked
                  ? const Color(0xFF6C63FF).withAlpha(51)
                  : const Color(0xFF2A2A4A).withAlpha(77),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF43A047)
                : isUnlocked
                    ? const Color(0xFF6C63FF)
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: isCompleted
              ? const Icon(Icons.check_rounded,
                  color: Color(0xFF43A047), size: 28)
              : isUnlocked
                  ? Text('${level.id}',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white))
                  : const Icon(Icons.lock_rounded,
                      color: Colors.white24, size: 22),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (30 * animIndex).ms, duration: 250.ms)
        .scaleXY(begin: 0.8, end: 1.0);
  }
}
