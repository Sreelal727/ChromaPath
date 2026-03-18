import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/levels.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await ProgressService.getCompletedLevels();
    final highest = await ProgressService.getHighestUnlocked();
    if (mounted) {
      setState(() {
        _completedLevels = completed;
        _highestUnlocked = highest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group levels by grid size
    final level5x5 = allLevels.where((l) => l.gridSize == 5).toList();
    final level6x6 = allLevels.where((l) => l.gridSize == 6).toList();
    final level7x7 = allLevels.where((l) => l.gridSize == 7).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('5×5 Grid', level5x5, 0),
          const SizedBox(height: 24),
          _buildSection('6×6 Grid', level6x6, level5x5.length),
          const SizedBox(height: 24),
          _buildSection('7×7 Grid', level7x7, level5x5.length + level6x6.length),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List levels, int animOffset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
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

            return _buildLevelTile(level, isCompleted, isUnlocked, index + animOffset);
          },
        ),
      ],
    );
  }

  Widget _buildLevelTile(dynamic level, bool isCompleted, bool isUnlocked, int animIndex) {
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
              ? const Icon(Icons.check_rounded, color: Color(0xFF43A047), size: 28)
              : isUnlocked
                  ? Text(
                      '${level.id}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_rounded, color: Colors.white24, size: 22),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (50 * animIndex).ms, duration: 300.ms)
        .scaleXY(begin: 0.8, end: 1.0);
  }
}
