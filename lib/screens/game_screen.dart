import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/levels.dart';
import '../logic/game_controller.dart';
import '../models/level.dart';
import '../services/coin_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/grid_painter.dart';

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _controller;
  bool _showSolveOverlay = false;
  int _coins = 0;
  int _coinsEarned = 0;

  @override
  void initState() {
    super.initState();
    _controller = GameController(widget.level);
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final coins = await CoinService.getCoins();
    if (mounted) setState(() => _coins = coins);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSolved() async {
    if (_showSolveOverlay) return; // prevent double-trigger
    final isFirstTime = await ProgressService.markCompleted(widget.level.id);
    int earned = 0;
    if (isFirstTime) {
      earned = CoinService.solveReward;
      final updated = await CoinService.addCoins(earned);
      _coins = updated;
    }
    if (!mounted) return;
    setState(() {
      _showSolveOverlay = true;
      _coinsEarned = earned;
    });

    // Auto-advance to next level after a short delay
    if (widget.level.id < 20) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _showSolveOverlay) {
          _nextLevel();
        }
      });
    }
  }

  void _resetLevel() {
    setState(() {
      _controller.reset();
      _showSolveOverlay = false;
      _coinsEarned = 0;
    });
  }

  // ─── Hint: reveal one random unsolved color path ───
  Future<void> _revealOnePath() async {
    final solution = allSolutions[widget.level.id];
    if (solution == null) return;

    Color? targetColor;
    List<(int, int)>? targetPath;
    for (final pair in widget.level.colorPairs) {
      if (!_isColorConnected(pair.color)) {
        targetColor = pair.color;
        targetPath = solution[pair.color];
        break;
      }
    }
    if (targetColor == null || targetPath == null) return;

    final result = await CoinService.spendCoins(CoinService.revealPathCost);
    if (result == null) {
      _showNotEnoughCoins();
      return;
    }
    _coins = result;

    _controller.applyPath(targetColor, targetPath);
    setState(() {});

    if (_controller.state.isSolved) {
      _onSolved();
    }
  }

  // ─── Hint: solve the entire puzzle ───
  Future<void> _solveEntirePuzzle() async {
    final solution = allSolutions[widget.level.id];
    if (solution == null) return;

    final result = await CoinService.spendCoins(CoinService.solvePuzzleCost);
    if (result == null) {
      _showNotEnoughCoins();
      return;
    }
    _coins = result;

    for (final entry in solution.entries) {
      _controller.applyPath(entry.key, entry.value);
    }
    setState(() {});

    if (_controller.state.isSolved) {
      _onSolved();
    }
  }

  void _showNotEnoughCoins() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Not enough coins! You have $_coins.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2A2A4A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHintMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Need Help?',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'You have $_coins coins',
                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildHintOption(
                icon: Icons.route_rounded,
                title: 'Reveal One Flow',
                subtitle: 'Shows the correct path for one color',
                cost: CoinService.revealPathCost,
                onTap: () {
                  Navigator.pop(ctx);
                  _revealOnePath();
                },
              ),
              const SizedBox(height: 12),
              _buildHintOption(
                icon: Icons.auto_fix_high_rounded,
                title: 'Solve Puzzle',
                subtitle: 'Reveals the complete solution',
                cost: CoinService.solvePuzzleCost,
                onTap: () {
                  Navigator.pop(ctx);
                  _solveEntirePuzzle();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required int cost,
    required VoidCallback onTap,
  }) {
    final canAfford = _coins >= cost;
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: canAfford
              ? const Color(0xFF6C63FF).withAlpha(38)
              : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: canAfford
                ? const Color(0xFF6C63FF).withAlpha(102)
                : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: canAfford ? const Color(0xFF6C63FF) : Colors.white24,
                size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: canAfford ? Colors.white : Colors.white38)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: canAfford ? Colors.white54 : Colors.white24)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: canAfford
                    ? Colors.amber.withAlpha(38)
                    : Colors.white.withAlpha(13),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on,
                      color: canAfford ? Colors.amber : Colors.white24,
                      size: 16),
                  const SizedBox(width: 4),
                  Text('$cost',
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: canAfford ? Colors.amber : Colors.white24)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = widget.level.gridSize;
    final filled = _controller.filledCells;
    final total = widget.level.totalCells;
    final fillPercent = filled / total;

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Coin display
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('$_coins',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded),
            onPressed: _showSolveOverlay ? null : _showHintMenu,
            tooltip: 'Hints',
            color: Colors.amber,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetLevel,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  Icons.route_rounded,
                  'Flows: ${_controller.flowsCompleted}/${widget.level.colorPairs.length}',
                ),
                _buildStatChip(
                  Icons.grid_4x4_rounded,
                  'Cells: $filled/$total',
                ),
                _buildGridSizeChip(),
              ],
            ),
          ),
          // Cell fill progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fillPercent,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF2A2A4A),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fillPercent >= 1.0
                          ? const Color(0xFF43A047)
                          : const Color(0xFF6C63FF),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (filled < total &&
                    _controller.flowsCompleted ==
                        widget.level.colorPairs.length)
                  Text(
                    'All flows connected! Fill every cell to complete.',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.amber.withAlpha(200),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(
                      duration: 800.ms),
              ],
            ),
          ),
          const Spacer(),
          // Solve overlay (shown above grid when solved)
          if (_showSolveOverlay) _buildSolveOverlay(),
          if (!_showSolveOverlay) ...[
            // Game grid
            _buildGrid(gridSize),
            const Spacer(),
            // Color legend
            _buildColorLegend(),
            const SizedBox(height: 24),
          ],
          if (_showSolveOverlay) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildGridSizeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE94560).withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${widget.level.gridSize}×${widget.level.gridSize}',
        style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE94560)),
      ),
    );
  }

  Widget _buildGrid(int gridSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.maxWidth - 32;
        final cellSize = maxSize / gridSize;
        final gridPixelSize = cellSize * gridSize;

        return Center(
          child: Container(
            width: gridPixelSize,
            height: gridPixelSize,
            decoration: BoxDecoration(
              color: AppTheme.gridBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gridLine, width: 2),
            ),
            child: GestureDetector(
              onPanStart: (d) => _handlePan(d.localPosition, cellSize),
              onPanUpdate: (d) =>
                  _handlePanUpdate(d.localPosition, cellSize, gridPixelSize),
              onPanEnd: (_) => _handlePanEnd(),
              child: CustomPaint(
                painter: GridPainter(
                  state: _controller.state,
                  cellSize: cellSize,
                ),
                size: Size(gridPixelSize, gridPixelSize),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePan(Offset position, double cellSize) {
    if (_showSolveOverlay) return;
    final col = (position.dx / cellSize).floor();
    final row = (position.dy / cellSize).floor();
    final gridSize = widget.level.gridSize;
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      setState(() => _controller.onCellDown(row, col));
    }
  }

  void _handlePanUpdate(
      Offset position, double cellSize, double gridPixelSize) {
    if (_showSolveOverlay) return;
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx >= gridPixelSize ||
        position.dy >= gridPixelSize) return;
    final col = (position.dx / cellSize).floor();
    final row = (position.dy / cellSize).floor();
    final gridSize = widget.level.gridSize;
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      final prevState = _controller.state;
      _controller.onCellEnter(row, col);
      if (_controller.state != prevState) {
        setState(() {});
        if (_controller.state.isSolved) {
          _onSolved();
        }
      }
    }
  }

  void _handlePanEnd() {
    if (_showSolveOverlay) return;
    setState(() => _controller.onCellUp());
  }

  Widget _buildColorLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: widget.level.colorPairs.map((pair) {
          final isConnected = _isColorConnected(pair.color);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: pair.color.withAlpha(isConnected ? 255 : 128),
              shape: BoxShape.circle,
              border: Border.all(
                color: isConnected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: pair.color.withAlpha(128),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: isConnected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          );
        }).toList(),
      ),
    );
  }

  bool _isColorConnected(Color color) {
    final pair = widget.level.colorPairs.firstWhere((p) => p.color == color);
    final path = _controller.state.paths[color];
    if (path == null || path.length < 2) return false;
    final start = (pair.start.row, pair.start.col);
    final end = (pair.end.row, pair.end.col);
    return (path.first == start && path.last == end) ||
        (path.first == end && path.last == start);
  }

  Widget _buildSolveOverlay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          // Big animated checkmark
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withAlpha(38),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF43A047), width: 3),
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF43A047), size: 48),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(begin: 0.3, end: 1.0, curve: Curves.elasticOut,
                  duration: 600.ms),
          const SizedBox(height: 16),
          Text(
            'Level Complete!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF43A047),
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
          if (_coinsEarned > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 24),
                const SizedBox(width: 6),
                Text(
                  '+$_coinsEarned coins earned!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Levels'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
              const SizedBox(width: 16),
              if (widget.level.id < 20)
                ElevatedButton.icon(
                  onPressed: _nextLevel,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next Level'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
            ],
          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          if (widget.level.id < 20) ...[
            const SizedBox(height: 12),
            Text(
              'Auto-advancing in 3 seconds...',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white38,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 300.ms),
          ],
        ],
      ),
    );
  }

  void _nextLevel() {
    final nextId = widget.level.id + 1;
    try {
      final nextLevel = allLevels.firstWhere((l) => l.id == nextId);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => GameScreen(level: nextLevel),
          transitionsBuilder: (_, animation, __, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeInOut)),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (_) {
      Navigator.pop(context);
    }
  }
}
